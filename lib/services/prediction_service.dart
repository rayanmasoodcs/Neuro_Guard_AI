import 'dart:convert';
import 'package:neuroguard_ai/services/api_http.dart' as http;
import 'package:neuroguard_ai/models/seizure_prediction_model.dart';
import 'package:neuroguard_ai/models/sensor_data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:neuroguard_ai/config/app_config.dart';

class PredictionService {
  static final PredictionService _instance = PredictionService._internal();
  static final String _baseUrl = AppConfig.baseUrl;

  factory PredictionService() {
    return _instance;
  }

  PredictionService._internal();

  /// Predict seizure type from EEG file data (CSV or other formats)
  Future<SeizurePredictionResult?> predictFromEEGFile({
    required int userId,
    required Uint8List fileBytes,
    required String fileName,
    List<List<num>>? eegData,
    List<SensorDataModel>? sensorData,
  }) async {
    try {
      final base64Content = base64Encode(fileBytes);

      final requestData = {
        'user_id': userId,
        'eeg_file': base64Content,
        'eeg_filename': fileName,
        'patient_name': 'Uploaded EEG',
        'sensor_data': sensorData?.map((s) => s.toJson()).toList(),
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/seizure/predict_seizure_from_eeg'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['prediction'] != null) {
          final pred = data['prediction'];
          final allScores = pred['all_scores'] as Map<String, dynamic>? ?? {};
          return SeizurePredictionResult(
            seizureType: pred['seizure_type'] ?? 'Unknown',
            confidence: (pred['confidence'] ?? 0.5).toDouble(),
            riskLevel: pred['risk_level'] ?? 'Low',
            eegPatterns: (pred['eeg_patterns'] as List?)?.cast<String>() ?? [],
            featureImportance: [0.2, 0.2, 0.15, 0.15, 0.15, 0.1, 0.05],
            rawAnalysis: pred['analysis_summary'] ?? '',
            predictionTime: DateTime.now(),
            fileAnalyzed: fileName,
            seizureTypeScores: allScores.map((k, v) => MapEntry(k, (v as num).toDouble())),
          );
        }
      }
      debugPrint('Prediction error: ${response.statusCode} - ${response.body}');
      return _heuristicPrediction(fileBytes: fileBytes, fileName: fileName, sensorData: sensorData);
    } catch (e) {
      debugPrint('Prediction service error: $e');
      return _heuristicPrediction(fileBytes: fileBytes, fileName: fileName, sensorData: sensorData);
    }
  }

  /// Batch prediction for multi-patient EEG datasets
  Future<Map<String, dynamic>?> predictBatch({
    required int userId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final base64Content = base64Encode(fileBytes);

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/seizure/predict_batch'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'eeg_file': base64Content,
              'eeg_filename': fileName,
            }),
          )
          .timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data;
        }
      }
      debugPrint('Batch prediction error: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Batch prediction service error: $e');
      return null;
    }
  }

  /// Get dataset summary from an uploaded EEG file
  Future<DatasetSummary?> getDatasetSummary({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final base64Content = base64Encode(fileBytes);

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/seizure/dataset_summary'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'eeg_file': base64Content,
              'eeg_filename': fileName,
            }),
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['summary'] != null) {
          return DatasetSummary.fromJson(data['summary']);
        }
      }
      debugPrint('Dataset summary error: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Dataset summary service error: $e');
      return null;
    }
  }

  /// Generate EEG waveform graph for a specific patient
  Future<String?> generateEEGGraph({
    required Uint8List fileBytes,
    required String fileName,
    int patientIndex = 0,
  }) async {
    try {
      final base64Content = base64Encode(fileBytes);

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/seizure/generate_eeg_graph_for_patient'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'eeg_file': base64Content,
              'eeg_filename': fileName,
              'patient_index': patientIndex,
            }),
          )
          .timeout(Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['png_base64'] as String?;
      }
      debugPrint('EEG graph error: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('EEG graph service error: $e');
      return null;
    }
  }

  /// Generate professional PDF report for a prediction
  Future<String?> generateReport({
    required int userId,
    required Uint8List fileBytes,
    required String fileName,
    String? patientName,
    String? patientAge,
    String? patientGender,
  }) async {
    try {
      final base64Content = base64Encode(fileBytes);

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/seizure/generate_seizure_report'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'eeg_file': base64Content,
              'eeg_filename': fileName,
              'patient_name': patientName ?? 'Uploaded EEG',
              'patient_age': patientAge,
              'patient_gender': patientGender,
            }),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['pdf_base64'] as String?;
      }
      debugPrint('Report generation error: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Report generation service error: $e');
      return null;
    }
  }

  /// Real-time prediction from live sensor data
  /// Gracefully handles missing EEG data (sensors-only mode)
  Future<SeizurePredictionResult?> predictFromLiveSensorData({
    required List<SensorDataModel> sensorReadings,
    String? eegBuffer,
  }) async {
    try {
      if (sensorReadings.isEmpty) return null;

      final requestData = {
        'sensor_readings': sensorReadings.map((s) => s.toJson()).toList(),
        'eeg_buffer': eegBuffer,
        'use_eeg': eegBuffer != null && eegBuffer.isNotEmpty,
        'prediction_type': 'real_time',
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/seizure/predict_seizure_realtime'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SeizurePredictionResult.fromJson(data);
      } else {
        // Fallback to heuristic prediction without EEG
        return _heuristicPrediction(eegData: [], fileName: 'real_time_sensors', sensorData: sensorReadings);
      }
    } catch (e) {
      debugPrint('Real-time prediction error: $e');
      // Fallback to heuristic prediction without EEG
      return _heuristicPrediction(eegData: [], fileName: 'real_time_sensors', sensorData: sensorReadings);
    }
  }

  /// Heuristic fallback prediction when backend is unavailable
  /// Uses local analysis of sensor data and EEG patterns
  SeizurePredictionResult _heuristicPrediction({
    List<List<num>> eegData = const [],
    String fileName = '',
    List<SensorDataModel>? sensorData,
    Uint8List? fileBytes,
  }) {
    String seizureType = 'Normal';
    double confidence = 0.5;
    String riskLevel = 'Low';
    List<String> patterns = [];
    Map<String, double> scores = {
      'Normal': 0.4,
      'Focal Seizure': 0.2,
      'Generalized Seizure': 0.15,
      'Absence Seizure': 0.1,
      'Tonic-Clonic Seizure': 0.1,
      'Myoclonic Seizure': 0.05,
    };

    // Analyze EEG data if available
    if (eegData.isNotEmpty) {
      final eegAnalysis = _analyzeEEGPatterns(eegData);
      seizureType = eegAnalysis['type'] as String;
      confidence = eegAnalysis['confidence'] as double;
      patterns = List<String>.from(eegAnalysis['patterns'] as List);
      riskLevel = eegAnalysis['risk'] as String;
      scores = Map<String, double>.from(eegAnalysis['scores'] as Map);
    }

    // If EEG unavailable, analyze sensor data
    if (sensorData != null && sensorData.isNotEmpty) {
      final sensorAnalysis = _analyzeSensorData(sensorData);
      if (eegData.isEmpty) {
        // Use sensor data as primary if no EEG
        seizureType = sensorAnalysis['type'] as String;
        confidence = (sensorAnalysis['confidence'] as double) * 0.7; // Lower confidence for sensor-only
        patterns.addAll(List<String>.from(sensorAnalysis['patterns'] as List));
        riskLevel = sensorAnalysis['risk'] as String;
      } else {
        // Fuse with EEG data
        confidence = (confidence + (sensorAnalysis['confidence'] as double)) / 2;
      }
    }

    return SeizurePredictionResult(
      seizureType: seizureType,
      confidence: confidence.clamp(0.0, 1.0),
      riskLevel: riskLevel,
      eegPatterns: patterns,
      featureImportance: [0.25, 0.20, 0.15, 0.15, 0.10, 0.08, 0.07],
      rawAnalysis: _generateAnalysisText(seizureType, confidence, patterns),
      predictionTime: DateTime.now(),
      fileAnalyzed: fileName,
      seizureTypeScores: scores,
    );
  }

  /// Analyze EEG patterns for seizure indicators
  Map<String, dynamic> _analyzeEEGPatterns(List<List<num>> eegData) {
    String type = 'Normal';
    double confidence = 0.3;
    String risk = 'Low';
    List<String> patterns = [];
    Map<String, double> scores = {
      'Normal': 0.7,
      'Focal Seizure': 0.1,
      'Generalized Seizure': 0.1,
      'Absence Seizure': 0.05,
      'Tonic-Clonic Seizure': 0.04,
      'Myoclonic Seizure': 0.01,
    };

    if (eegData.isEmpty) {
      return {
        'type': type,
        'confidence': confidence,
        'risk': risk,
        'patterns': patterns,
        'scores': scores,
      };
    }

    // Simple heuristic: check amplitude variance, spike patterns
    double avgAmplitude = 0;
    double maxAmplitude = 0;
    int spikeCount = 0;

    for (final channel in eegData) {
      for (final value in channel) {
        final abs = (value).toDouble().abs();
        avgAmplitude += abs;
        if (abs > maxAmplitude) maxAmplitude = abs;
        if (abs > 100) spikeCount++; // Arbitrary spike threshold
      }
    }

    avgAmplitude /= (eegData.length * eegData.first.length);

    // Decision logic
    if (maxAmplitude > 200 && spikeCount > 50) {
      type = 'Generalized Seizure';
      confidence = 0.75;
      risk = 'High';
      patterns = [
        'High amplitude spikes detected',
        'Generalized recruitment pattern',
        'Post-ictal slowing',
      ];
      scores = {
        'Normal': 0.05,
        'Focal Seizure': 0.1,
        'Generalized Seizure': 0.75,
        'Absence Seizure': 0.05,
        'Tonic-Clonic Seizure': 0.04,
        'Myoclonic Seizure': 0.01,
      };
    } else if (maxAmplitude > 150 && spikeCount > 30) {
      type = 'Focal Seizure';
      confidence = 0.65;
      risk = 'Medium';
      patterns = [
        'Localized spike activity',
        'Temporal lobe involvement',
        'Consistent focal onset',
      ];
      scores = {
        'Normal': 0.15,
        'Focal Seizure': 0.65,
        'Generalized Seizure': 0.1,
        'Absence Seizure': 0.05,
        'Tonic-Clonic Seizure': 0.04,
        'Myoclonic Seizure': 0.01,
      };
    } else if (maxAmplitude > 100 && avgAmplitude > 50) {
      type = 'Tonic-Clonic Seizure';
      confidence = 0.55;
      risk = 'High';
      patterns = [
        'Rhythmic jerking pattern',
        'Bilateral muscle involvement',
        'Post-ictal recovery phase',
      ];
      scores = {
        'Normal': 0.1,
        'Focal Seizure': 0.2,
        'Generalized Seizure': 0.15,
        'Absence Seizure': 0.05,
        'Tonic-Clonic Seizure': 0.55,
        'Myoclonic Seizure': 0.05,
      };
    } else if (maxAmplitude > 80 && spikeCount > 10) {
      type = 'Myoclonic Seizure';
      confidence = 0.45;
      risk = 'Medium';
      patterns = [
        'Polyspike-wave complexes',
        'Rapid spike frequency',
        'Myoclonic jerk pattern',
      ];
      scores = {
        'Normal': 0.3,
        'Focal Seizure': 0.15,
        'Generalized Seizure': 0.1,
        'Absence Seizure': 0.1,
        'Tonic-Clonic Seizure': 0.1,
        'Myoclonic Seizure': 0.45,
      };
    }

    return {
      'type': type,
      'confidence': confidence,
      'risk': risk,
      'patterns': patterns,
      'scores': scores,
    };
  }

  /// Analyze sensor data for seizure indicators
  Map<String, dynamic> _analyzeSensorData(List<SensorDataModel> sensorData) {
    String type = 'Normal';
    double confidence = 0.2;
    String risk = 'Low';
    List<String> patterns = [];

    if (sensorData.isEmpty) {
      return {
        'type': type,
        'confidence': confidence,
        'risk': risk,
        'patterns': patterns,
      };
    }

    // Analyze heart rate trends
    final heartRates = sensorData
        .where((s) => s.heartRate != null && s.heartRate! > 0)
        .map((s) => s.heartRate!)
        .toList();

    // Analyze motion/accelerometer
    final motions = sensorData
        .where((s) => s.accelerometerX != null)
        .map((s) => ((s.accelerometerX ?? 0).abs() +
            (s.accelerometerY ?? 0).abs() +
            (s.accelerometerZ ?? 0).abs()) /
            3)
        .toList();

    // Detect abnormal heart rate patterns
    if (heartRates.isNotEmpty) {
      final avgHR = heartRates.reduce((a, b) => a + b) / heartRates.length;
      final maxHR = heartRates.reduce((a, b) => a > b ? a : b);

      if (maxHR > 120 && avgHR > 100) {
        confidence += 0.15;
        patterns.add('Elevated heart rate detected');
      }
      if (maxHR > 150) {
        confidence += 0.1;
        patterns.add('Severe tachycardia');
        risk = 'High';
      }
    }

    // Detect abnormal motion patterns
    if (motions.isNotEmpty) {
      final maxMotion = motions.reduce((a, b) => a > b ? a : b);

      if (maxMotion > 50) {
        confidence += 0.15;
        patterns.add('Abnormal motion/jerking detected');
        risk = 'Medium';
      }
      if (maxMotion > 100) {
        confidence += 0.1;
        patterns.add('Severe abnormal movement');
        risk = 'High';
        type = 'Tonic-Clonic Seizure';
      }
    }

    // Check for fall detection
    if (sensorData.any((s) => s.fallDetected == true)) {
      confidence += 0.2;
      patterns.add('Fall detected - possible loss of consciousness');
      risk = 'High';
      type = 'Generalized Seizure';
    }

    return {
      'type': type,
      'confidence': confidence.clamp(0.0, 1.0),
      'risk': risk,
      'patterns': patterns,
    };
  }

  String _generateAnalysisText(
    String seizureType,
    double confidence,
    List<String> patterns,
  ) {
    return '''
Analysis Result: $seizureType

Confidence: ${(confidence * 100).toStringAsFixed(1)}%

Key Findings:
${patterns.map((p) => '• $p').join('')}

Recommendation:
${_getRecommendation(seizureType, confidence)}
''';
  }

  String _getRecommendation(String seizureType, double confidence) {
    if (confidence > 0.7) {
      return 'High probability of $seizureType. Seek immediate medical attention.';
    } else if (confidence > 0.5) {
      return 'Moderate indication of $seizureType. Consult with a neurologist for evaluation.';
    } else {
      return 'Low probability of seizure activity. Continue monitoring and report any symptoms to your healthcare provider.';
    }
  }

  /// Store a sensor reading in the database
  Future<bool> storeSensorReading({
    required int userId,
    String? patientId,
    required String dataSource,
    double? heartRate,
    double? bodyTemperature,
    double? accelerometerX,
    double? accelerometerY,
    double? accelerometerZ,
    double? gyroscopeX,
    double? gyroscopeY,
    double? gyroscopeZ,
    bool? fallDetected,
    String? motionIntensity,
  }) async {
    try {
      final requestData = {
        'user_id': userId,
        'patient_id': patientId,
        'data_source': dataSource,
        'heart_rate': heartRate,
        'body_temperature': bodyTemperature,
        'accelerometer_x': accelerometerX,
        'accelerometer_y': accelerometerY,
        'accelerometer_z': accelerometerZ,
        'gyroscope_x': gyroscopeX,
        'gyroscope_y': gyroscopeY,
        'gyroscope_z': gyroscopeZ,
        'fall_detected': fallDetected ?? false,
        'motion_intensity': motionIntensity,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/seizure/store_sensor_reading'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 201) {
        debugPrint('[PredictionService] Sensor reading stored successfully');
        return true;
      } else {
        debugPrint('[PredictionService] Failed to store sensor reading: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('[PredictionService] Error storing sensor reading: $e');
      return false;
    }
  }

  /// Store a seizure alert in the database
  Future<bool> storeAlert({
    required int userId,
    String? patientId,
    int? predictionId,
    required String alertType,
    String? seizureType,
    double confidence = 0.0,
    String? riskLevel,
    String? severity,
    String? alertMessage,
  }) async {
    try {
      final requestData = {
        'user_id': userId,
        'patient_id': patientId,
        'prediction_id': predictionId,
        'alert_type': alertType,
        'seizure_type': seizureType,
        'confidence_score': confidence,
        'risk_level': riskLevel,
        'severity': severity,
        'alert_message': alertMessage,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/seizure/store_alert'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 201) {
        debugPrint('[PredictionService] Alert stored successfully');
        return true;
      } else {
        debugPrint('[PredictionService] Failed to store alert: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('[PredictionService] Error storing alert: $e');
      return false;
    }
  }

  /// Get sensor reading history for a user
  Future<List<Map<String, dynamic>>> getSensorHistory({
    required int userId,
    int limit = 100,
    int hours = 24,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/api/seizure/get_sensor_history?user_id=$userId&limit=$limit&hours=$hours',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final readings = data['readings'] as List? ?? [];
        return readings.cast<Map<String, dynamic>>();
      } else {
        debugPrint('[PredictionService] Failed to get sensor history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('[PredictionService] Error getting sensor history: $e');
      return [];
    }
  }

  /// Get alerts for a user
  Future<List<Map<String, dynamic>>> getAlerts({
    required int userId,
    int limit = 50,
    int days = 7,
    String? severity,
  }) async {
    try {
      String url = '$_baseUrl/api/seizure/get_alerts?user_id=$userId&limit=$limit&days=$days';
      if (severity != null) {
        url += '&severity=$severity';
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final alerts = data['alerts'] as List? ?? [];
        return alerts.cast<Map<String, dynamic>>();
      } else {
        debugPrint('[PredictionService] Failed to get alerts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('[PredictionService] Error getting alerts: $e');
      return [];
    }
  }

  /// Get prediction history for a user
  Future<List<SeizurePredictionResult>> getPredictionHistory({
    required int userId,
    int limit = 10,
    int days = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/seizure/get_prediction_history?user_id=$userId&limit=$limit&days=$days'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['predictions'] as List? ?? [];
        return items.map((e) => SeizurePredictionResult.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        debugPrint('[PredictionService] Failed to get prediction history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('[PredictionService] Error getting prediction history: $e');
      return [];
    }
  }

  /// Acknowledge an alert as handled
  Future<bool> acknowledgeAlert({
    required int alertId,
    String? acknowledgedBy,
    String? actionTaken,
    String? actionDetails,
  }) async {
    try {
      final requestData = {
        'acknowledged_by': acknowledgedBy ?? 'mobile_app',
        'action_taken': actionTaken,
        'action_details': actionDetails,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/seizure/acknowledge_alert/$alertId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('[PredictionService] Alert acknowledged successfully');
        return true;
      } else {
        debugPrint('[PredictionService] Failed to acknowledge alert: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('[PredictionService] Error acknowledging alert: $e');
      return false;
    }
  }
}



