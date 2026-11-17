from flask import Flask, request, jsonify
import sys
import os
import numpy as np

# Add the parent directory to the path so we can import production_inference
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from production_inference import get_engine, InferenceInputError, ModelArtifactError
import base64
import eeg_inference

app = Flask(__name__)

# The legacy feature-vector engine is optional; EEG file analysis uses eeg_inference.
try:
    print("Loading NeuroGuardInferenceEngine...")
    engine = get_engine()
    print("NeuroGuardInferenceEngine loaded successfully.")
except Exception as e:
    engine = None
    print(f"WARNING: legacy feature-vector engine unavailable: {e}")

# Fail loudly if the EEG model is missing: without it the service has nothing to serve.
try:
    eeg_inference.load_model()
    print(f"EEG model loaded: {eeg_inference.load_model()['model_version']}")
except Exception as e:
    print(f"CRITICAL ERROR: Failed to load EEG model: {e}")
    sys.exit(1)


@app.route('/dataset_summary', methods=['POST'])
def dataset_summary():
    data = request.get_json(silent=True) or {}
    try:
        raw = base64.b64decode(data.get('eeg_file') or '', validate=False)
    except Exception:
        raw = b''
    rate = data.get('sampling_rate')
    summary = eeg_inference.summarize(raw, data.get('eeg_filename') or 'upload', float(rate) if rate else None)
    return jsonify({"status": "success", "summary": summary})


@app.route('/predict_eeg', methods=['POST'])
def predict_eeg():
    data = request.get_json(silent=True) or {}
    encoded = data.get('eeg_file')
    if not encoded:
        return jsonify({"status": "CANNOT_ASSESS", "result": "cannot_assess",
                        "reason": "No EEG file was provided."}), 400
    try:
        raw = base64.b64decode(encoded, validate=False)
    except Exception:
        return jsonify({"status": "CANNOT_ASSESS", "result": "cannot_assess",
                        "reason": "eeg_file is not valid base64."}), 400
    rate = data.get('sampling_rate')
    result = eeg_inference.analyse(raw, data.get('eeg_filename') or 'upload', float(rate) if rate else None)
    return jsonify(result), (200 if result["status"] == "SUCCESS" else 422)

@app.route('/health', methods=['GET'])
def health():
    art = eeg_inference.load_model()
    return jsonify({"status": "healthy", "eeg_model": art["model_version"], "evaluation": art.get("evaluation", {}),
                    "legacy_engine": engine.info() if engine else None})

@app.route('/predict', methods=['POST'])
def predict():
    if engine is None:
        return jsonify({"error": "Legacy feature-vector model is not installed; use /predict_eeg."}), 503
    try:
        data = request.json
        if not data:
            return jsonify({"error": "No JSON payload provided"}), 400
        
        feature_vector = data.get('feature_vector')
        if not feature_vector:
            return jsonify({"error": "Missing 'feature_vector' in payload"}), 400

        result = engine.predict_single(np.array(feature_vector))
        # Add source tag
        result["source"] = "ml_model"
        
        return jsonify(result)

    except InferenceInputError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": f"Internal inference error: {str(e)}"}), 500

if __name__ == '__main__':
    # Run on port 5005
    app.run(host='0.0.0.0', port=5005)
