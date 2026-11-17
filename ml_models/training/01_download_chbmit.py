"""Download only seizure-containing CHB-MIT recordings (plus summaries) into data/chbmit/<patient>/.
Resumable: finished files are skipped, partial downloads use a .part file.
Usage: python ml_models/training/01_download_chbmit.py data/chbmit chb01,chb02,chb03,chb04,chb05,chb06,chb07,chb08"""
import re
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

BASE = "https://physionet.org/files/chbmit/1.0.0/"
ROOT = Path(sys.argv[1])
PATIENTS = sys.argv[2].split(",")


def fetch(url, out: Path):
    if out.exists():
        return f"skip {out.name}"
    part = out.with_suffix(out.suffix + ".part")
    for attempt in range(3):
        try:
            urllib.request.urlretrieve(url, part)
            part.replace(out)
            return f"ok   {out.name} ({out.stat().st_size / 1e6:.0f} MB)"
        except Exception as e:  # retry transient network errors
            err = e
    return f"FAIL {out.name}: {err}"


jobs = []
for p in PATIENTS:
    d = ROOT / p
    d.mkdir(parents=True, exist_ok=True)
    summary = d / f"{p}-summary.txt"
    print(fetch(f"{BASE}{p}/{p}-summary.txt", summary), flush=True)
    text = summary.read_text(errors="ignore")
    for block in re.split(r"\n(?=File Name:)", text):
        m = re.search(r"File Name:\s*(\S+\.edf)", block)
        n = re.search(r"Number of Seizures in File:\s*(\d+)", block)
        if m and n and int(n.group(1)) > 0:
            jobs.append((f"{BASE}{p}/{m.group(1)}", d / m.group(1)))

listing = ROOT / "seizure_files.txt"
listing.write_text("\n".join(f"{out.parent.name}/{out.name}" for _, out in jobs) + "\n")
print(f"{len(jobs)} seizure-containing recordings queued (list written to {listing})", flush=True)
with ThreadPoolExecutor(4) as pool:
    for i, msg in enumerate(pool.map(lambda j: fetch(*j), jobs), 1):
        print(f"[{i}/{len(jobs)}] {msg}", flush=True)
print("DONE", flush=True)
