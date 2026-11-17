"""Train the selected model on all patients and save the artifact loaded by ml_models/eeg_inference.py.
Usage: python export_model.py <features_csv> <lopo_report.json> <model_name> <out.joblib>"""
import json
import sys
from datetime import date

import joblib
import pandas as pd
from sklearn.ensemble import HistGradientBoostingClassifier, RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

csv, report_path, name, out = sys.argv[1:5]
report = json.load(open(report_path))
df = pd.read_csv(csv)
feats = report["features"]

est = {
    "LogReg": LogisticRegression(class_weight="balanced", max_iter=3000),
    "RandomForest": RandomForestClassifier(200, class_weight="balanced_subsample", min_samples_leaf=5,
                                           n_jobs=-1, random_state=0),
    "HistGB": HistGradientBoostingClassifier(class_weight="balanced", random_state=0),
}[name]
pipe = make_pipeline(SimpleImputer(strategy="median"), StandardScaler(), est).fit(df[feats].values, df["label"].values)

r = report["results"][name]
joblib.dump({
    "pipeline": pipe,
    "feature_names": feats,
    "threshold": report["threshold"],
    "consecutive_windows": report["alarm_consecutive_windows"],
    "model_version": f"chbmit-{name.lower()}-{date.today():%Y%m%d}",
    "evaluation": {
        "protocol": "leave-one-patient-out on CHB-MIT",
        "patients": report["patients"],
        "n_windows": report["n_windows"],
        "n_seizure_windows": report["n_seizure_windows"],
        "window_metrics": r["window"],
        "event_metrics": r["event"],
        "limitations": "8 paediatric patients from one dataset; not clinically validated; "
                       "performance varies strongly by patient.",
    },
}, out)
print(f"saved {name} -> {out}")
