"""Patient-independent evaluation (leave-one-patient-out) per spec §7.2/§7.3.
Window = 4 s, step = 2 s. Imputer/scaler are fit on training patients only.
Alarm post-processing: an alarm needs K consecutive positive windows (spec §6.3 temporal logic).
Usage: python train_lopo.py <features_csv> <out_dir>"""
import json
import sys
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.ensemble import HistGradientBoostingClassifier, RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import average_precision_score, roc_auc_score
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

STEP_S = 2.0
K = 3            # consecutive positive windows required to raise an alarm
THRESH = 0.5

df = pd.read_csv(sys.argv[1])
out = Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=True)
META = ["label", "patient_id", "recording_id", "dataset"]
FEATS = [c for c in df.columns if c not in META]
df["t"] = df.groupby("recording_id").cumcount() * STEP_S
X, y, pid = df[FEATS].values, df["label"].values, df["patient_id"].values

MODELS = {
    "LogReg": lambda: make_pipeline(SimpleImputer(strategy="median"), StandardScaler(),
                                    LogisticRegression(class_weight="balanced", max_iter=3000)),
    "RandomForest": lambda: make_pipeline(SimpleImputer(strategy="median"), StandardScaler(),
                                          RandomForestClassifier(200, class_weight="balanced_subsample",
                                                                 min_samples_leaf=5, n_jobs=-1, random_state=0)),
    "HistGB": lambda: make_pipeline(SimpleImputer(strategy="median"), StandardScaler(),
                                    HistGradientBoostingClassifier(class_weight="balanced", random_state=0)),
}


def alarms(prob):
    """Boolean per window: True where the last K windows were all >= THRESH."""
    pos = (prob >= THRESH).astype(int)
    run = np.convolve(pos, np.ones(K, int), "full")[: len(pos)]
    return run >= K


def events(lbl):
    """Contiguous seizure runs -> list of (start_idx, end_idx)."""
    ev, start = [], None
    for i, v in enumerate(lbl):
        if v and start is None: start = i
        if not v and start is not None: ev.append((start, i - 1)); start = None
    if start is not None: ev.append((start, len(lbl) - 1))
    return ev


report = {}
for name, make in MODELS.items():
    prob = np.zeros(len(y))
    for p in np.unique(pid):
        tr, te = pid != p, pid == p
        prob[te] = make().fit(X[tr], y[tr]).predict_proba(X[te])[:, 1]

    per_patient, tot = {}, dict(ev=0, det=0, fa=0, hours=0.0, lat=[])
    for p in np.unique(pid):
        sub = df[pid == p]
        pr = prob[pid == p]
        p_ev = p_det = p_fa = 0; p_lat = []
        for rec, g in sub.groupby("recording_id", sort=False):
            idx = g.index.values - sub.index.values[0]
            a, lbl = alarms(pr[idx]), g["label"].values
            evs = events(lbl)
            for s, e in evs:
                hit = np.where(a[s:e + 1 + K])[0]   # allow alarm up to K windows after offset
                p_ev += 1
                if len(hit): p_det += 1; p_lat.append(hit[0] * STEP_S)
            # false alarm = alarm onset (rising edge) outside any seizure (with K-window margin)
            ictal = np.zeros(len(lbl), bool)
            for s, e in evs: ictal[max(0, s - K):e + 1 + K] = True
            onsets = np.where(a & ~np.r_[False, a[:-1]])[0]
            p_fa += int(np.sum(~ictal[onsets]))
        hours = len(sub) * STEP_S / 3600
        yt = sub["label"].values
        per_patient[p] = dict(seizures=p_ev, detected=p_det, false_alarms=p_fa, hours=round(hours, 2),
                              fa_per_h=round(p_fa / hours, 2),
                              window_auc=round(roc_auc_score(yt, pr), 3) if 0 < yt.sum() < len(yt) else None,
                              median_latency_s=float(np.median(p_lat)) if p_lat else None)
        tot["ev"] += p_ev; tot["det"] += p_det; tot["fa"] += p_fa; tot["hours"] += hours; tot["lat"] += p_lat

    pw = (prob >= THRESH).astype(int)
    tp, fn = int(((pw == 1) & (y == 1)).sum()), int(((pw == 0) & (y == 1)).sum())
    tn, fp = int(((pw == 0) & (y == 0)).sum()), int(((pw == 1) & (y == 0)).sum())
    sens, spec = tp / (tp + fn), tn / (tn + fp)
    prec = tp / (tp + fp) if tp + fp else 0.0
    report[name] = dict(
        window=dict(accuracy=round((tp + tn) / len(y), 4), sensitivity=round(sens, 3), specificity=round(spec, 4),
                    precision=round(prec, 3), f1=round(2 * prec * sens / (prec + sens), 3) if prec + sens else 0.0,
                    balanced_accuracy=round((sens + spec) / 2, 3),
                    roc_auc=round(roc_auc_score(y, prob), 3), pr_auc=round(average_precision_score(y, prob), 3)),
        event=dict(seizures=tot["ev"], detected=tot["det"], event_sensitivity=round(tot["det"] / tot["ev"], 3),
                   false_alarms=tot["fa"], fa_per_hour=round(tot["fa"] / tot["hours"], 3),
                   median_latency_s=float(np.median(tot["lat"])) if tot["lat"] else None),
        per_patient=per_patient)
    w, e = report[name]["window"], report[name]["event"]
    print(f"\n=== {name} (leave-one-patient-out) ===")
    print(f"window: acc={w['accuracy']} sens={w['sensitivity']} spec={w['specificity']} prec={w['precision']} "
          f"F1={w['f1']} bal_acc={w['balanced_accuracy']} ROC-AUC={w['roc_auc']} PR-AUC={w['pr_auc']}")
    print(f"event : detected {e['detected']}/{e['seizures']} seizures (sens {e['event_sensitivity']}), "
          f"false alarms {e['false_alarms']} = {e['fa_per_hour']}/h, median latency {e['median_latency_s']} s")
    for p, r in per_patient.items():
        print(f"   {p}: {r['detected']}/{r['seizures']} seizures, {r['false_alarms']} FA in {r['hours']} h "
              f"({r['fa_per_h']}/h), AUC {r['window_auc']}, latency {r['median_latency_s']}")

json.dump(dict(protocol="leave-one-patient-out", window_s=4, step_s=STEP_S, alarm_consecutive_windows=K,
               threshold=THRESH, features=FEATS, n_windows=len(y), n_seizure_windows=int(y.sum()),
               patients=sorted(np.unique(pid).tolist()), results=report),
          open(out / "lopo_report.json", "w"), indent=2)
print(f"\nreport -> {out / 'lopo_report.json'}")
