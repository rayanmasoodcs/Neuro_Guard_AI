import os
import urllib.request
import urllib.error
import re
from pathlib import Path

def download_chbmit(max_patients=5):
    base_url = "https://physionet.org/files/chbmit/1.0.0/"
    target_dir = Path("data/chbmit")
    target_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"Downloading first {max_patients} patients from CHB-MIT to {target_dir}...")
    try:
        records_url = base_url + "RECORDS"
        response = urllib.request.urlopen(records_url)
        records = response.read().decode('utf-8').strip().split('\n')
    except Exception as e:
        print(f"Error fetching RECORDS: {e}")
        return

    # Filter records to only include the first max_patients
    patient_dirs = sorted(list(set([r.split('/')[0] for r in records if r.startswith('chb')])))[:max_patients]
    print(f"Target patients: {patient_dirs}")

    for record in records:
        patient_dir = record.split('/')[0]
        if patient_dir in patient_dirs:
            file_url = base_url + record
            out_path = target_dir / record
            out_path.parent.mkdir(parents=True, exist_ok=True)
            if not out_path.exists():
                print(f"Downloading {record}...")
                try:
                    urllib.request.urlretrieve(file_url, out_path)
                except Exception as e:
                    print(f"Failed to download {record}: {e}")
            else:
                print(f"Exists: {record}")
                
    # Also get the summary text files for these patients
    for p in patient_dirs:
        summary_file = f"{p}/{p}-summary.txt"
        file_url = base_url + summary_file
        out_path = target_dir / summary_file
        if not out_path.exists():
             print(f"Downloading {summary_file}...")
             try:
                 urllib.request.urlretrieve(file_url, out_path)
             except Exception as e:
                 print(f"Failed to download {summary_file}: {e}")
                 
def download_siena():
    base_url = "https://physionet.org/files/siena-scalp-eeg/1.0.0/"
    target_dir = Path("data/siena")
    target_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"Downloading Siena Scalp EEG dataset to {target_dir}...")
    try:
        records_url = base_url + "RECORDS"
        response = urllib.request.urlopen(records_url)
        records = response.read().decode('utf-8').strip().split('\n')
    except Exception as e:
        print(f"Error fetching RECORDS: {e}")
        return

    # For siena, just download everything or the first few patients for testing? The user asked to "acquire the Siena dataset". Let's get the whole thing if it's small, or maybe just first patient for now to save time in this pass?
    # The prompt: "acquire Siena dataset now for generalization testing". 14 adult patients.
    # It might be very large. Let's just download the first patient for testing the pipeline if needed, or I can try to download all. Let's download all.
    for record in records:
        if record.endswith('.edf') or record.endswith('.txt'):
            file_url = base_url + record
            out_path = target_dir / record
            out_path.parent.mkdir(parents=True, exist_ok=True)
            if not out_path.exists():
                print(f"Downloading {record}...")
                try:
                    urllib.request.urlretrieve(file_url, out_path)
                except Exception as e:
                    print(f"Failed to download {record}: {e}")

if __name__ == '__main__':
    download_chbmit(5)
    download_siena()
