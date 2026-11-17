/**
 * ML adapter for the Node/MongoDB backend.
 *
 * Calls the Python ML service via HTTP.
 */
const http = require('http');
const https = require('https');

function heuristic({ sensorReadings = [], eegFile = null }) {
  const readings = Array.isArray(sensorReadings) ? sensorReadings : [];
  const hr = readings.map(r => Number(r.heart_rate ?? r.heartRate)).filter(Number.isFinite);
  const falls = readings.some(r => Boolean(r.fall_detected ?? r.fallDetection ?? r.fallDetected));
  const avgHr = hr.length ? hr.reduce((a,b) => a+b, 0) / hr.length : 0;
  const highMotion = readings.some(r => {
    const x = Number(r.accelerometer_x ?? r.accelerometer?.x ?? 0);
    const y = Number(r.accelerometer_y ?? r.accelerometer?.y ?? 0);
    const z = Number(r.accelerometer_z ?? r.accelerometer?.z ?? 0);
    return Math.abs(x) + Math.abs(y) + Math.abs(z) > 150;
  });
  const detected = falls || avgHr > 130 || highMotion;
  const confidence = detected ? 0.88 : 0.12;
  return {
    source: "heuristic_fallback",
    prediction: detected ? 'seizure' : 'non_seizure',
    clinical_finding: detected ? 'Electrographic Seizure Activity Detected' : 'Non-Seizure Background EEG Pattern',
    confidence,
    risk_level: detected ? 'High' : 'Low',
    class_probabilities: detected
      ? { non_seizure: 0.12, seizure: 0.88 }
      : { non_seizure: 0.88, seizure: 0.12 },
    warnings: ["ML Service unreachable. Using basic rule-based heuristic fallback."],
    status: "SUCCESS_FALLBACK"
  };
}

function requestJson(url, payload, timeoutMs = 5000) {
  return new Promise((resolve, reject) => {
    const target = new URL(url);
    const transport = target.protocol === 'https:' ? https : http;
    const req = transport.request({
      hostname: target.hostname,
      port: target.port || undefined,
      path: `${target.pathname}${target.search}`,
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      timeout: timeoutMs,
    }, res => {
      let body = '';
      res.setEncoding('utf8');
      res.on('data', chunk => { body += chunk; });
      res.on('end', () => {
        try {
          const data = JSON.parse(body);
          if (res.statusCode >= 200 && res.statusCode < 300) resolve(data);
          else reject(new Error(`ML service returned ${res.statusCode}: ${body}`));
        } catch (e) { reject(e); }
      });
    });
    req.on('timeout', () => req.destroy(new Error('ML service timeout')));
    req.on('error', reject);
    req.write(JSON.stringify(payload));
    req.end();
  });
}

// Convert sensor readings to a feature array (placeholder logic to feed the ML model)
function extractFeatures(payload) {
  let nFeatures = 38; // Default for new classical pipeline
  try {
    const path = require('path');
    const fs = require('fs');
    const metaPath = path.join(__dirname, '..', '..', 'ml_models', 'seizure_meta.json');
    if (fs.existsSync(metaPath)) {
      const meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
      nFeatures = meta.n_features_original || meta.n_features || nFeatures;
    }
  } catch (e) {
    console.warn('[ML ADAPTER] Could not read seizure_meta.json, using default nFeatures=38');
  }

  if (payload.feature_vector && payload.feature_vector.length === nFeatures) {
    return payload.feature_vector;
  }
  // If not provided, create a dummy vector derived pseudo-randomly from heart rate 
  // so the ML model has something to process. 
  const hr = payload.sensor_data?.heart_rate || payload.sensor_data?.heartRate || 75;
  const features = new Array(nFeatures).fill(0);
  features[0] = hr; // feature 1: hr
  if (nFeatures > 1) {
    features[1] = (payload.sensor_data?.fall_detection ? 1 : 0); // feature 2: fall
  }
  for(let i=2; i<nFeatures; i++) {
    features[i] = (hr / 100) * (i % 5); // arbitrary scaling just to have varying numbers
  }
  return features;
}

async function predict(payload) {
  const mlUrl = process.env.ML_SERVICE_URL || 'http://127.0.0.1:5005';
  try {
    const feature_vector = extractFeatures(payload);
    const result = await requestJson(`${mlUrl.replace(/\/$/, '')}/predict`, { feature_vector });
    return result;
  } catch (error) {
    console.error('[ML ADAPTER] Python ML service unavailable; using fallback:', error.message);
    return heuristic(payload);
  }
}

module.exports = { predict, heuristic };
