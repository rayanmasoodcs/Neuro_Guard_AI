"""Build the windowed feature matrix with the repo's own extractor (build_feature_matrix.process_file),
using only the nested data/chbmit/<patient>/ layout so the duplicate top-level chb01_03.edf is not double-counted.
Usage: python build_features.py <repo_root> <out_csv>"""
import sys
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

import numpy as np
import pandas as pd

REPO = Path(sys.argv[1]).resolve()
OUT = Path(sys.argv[2])
sys.path.insert(0, str(REPO))
from build_feature_matrix import process_file  # noqa: E402

CHB = REPO / "data" / "chbmit"


def work(path):
    return process_file(str(path), "chbmit", str(CHB))


if __name__ == "__main__":
    listed = CHB / "seizure_files.txt"
    if listed.exists():
        edfs = [CHB / line.strip() for line in listed.read_text().splitlines() if line.strip()]
    else:
        edfs = sorted(p for p in CHB.glob("chb*/*.edf"))
    print(f"{len(edfs)} EDF files (nested layout only)", flush=True)
    rows = []
    with ProcessPoolExecutor(6) as pool:
        for r in pool.map(work, edfs):
            rows.extend(r)
    df = pd.DataFrame(rows).replace([np.inf, -np.inf], np.nan)
    df.to_csv(OUT, index=False)  # NaNs kept; imputation happens inside each training fold
    per = df.groupby("patient_id")["label"].agg(windows="size", seizure_windows="sum")
    print(per.to_string())
    print(f"TOTAL windows={len(df)} seizure={int(df.label.sum())} patients={df.patient_id.nunique()} -> {OUT}")
