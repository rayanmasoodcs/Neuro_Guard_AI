from flask import Flask, request, jsonify
import sys
import os
import numpy as np

# Add the parent directory to the path so we can import production_inference
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from production_inference import get_engine, InferenceInputError, ModelArtifactError

app = Flask(__name__)

# Initialize the engine at startup to fail loudly if artifacts are missing
try:
    print("Loading NeuroGuardInferenceEngine...")
    engine = get_engine()
    print("NeuroGuardInferenceEngine loaded successfully.")
except Exception as e:
    print(f"CRITICAL ERROR: Failed to load NeuroGuardInferenceEngine: {e}")
    sys.exit(1)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy", "model": "NeuroGuard Inference Engine", "info": engine.info()})

@app.route('/predict', methods=['POST'])
def predict():
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
