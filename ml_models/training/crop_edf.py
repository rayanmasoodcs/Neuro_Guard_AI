"""Crop an EDF file to [start_s, end_s) by whole data records (CHB-MIT uses 1 s records).
Usage: python crop_edf.py <in.edf> <out.edf> <start_s> <end_s>"""
import sys

src, dst, start_s, end_s = sys.argv[1], sys.argv[2], float(sys.argv[3]), float(sys.argv[4])
with open(src, "rb") as f:
    raw = f.read()
hdr_bytes = int(raw[184:192].decode().strip())
n_records = int(raw[236:244].decode().strip())
rec_dur = float(raw[244:252].decode().strip())
ns = int(raw[252:256].decode().strip())
spr = [int(raw[256 + ns * 216 + i * 8: 256 + ns * 216 + (i + 1) * 8].decode().strip()) for i in range(ns)]
rec_bytes = sum(spr) * 2
first, last = int(start_s // rec_dur), min(n_records, int(end_s // rec_dur))
header = bytearray(raw[:hdr_bytes])
header[236:244] = f"{last - first:<8}".encode()
data = raw[hdr_bytes + first * rec_bytes: hdr_bytes + last * rec_bytes]
with open(dst, "wb") as f:
    f.write(header + data)
print(f"{dst}: records {first}-{last} ({(last - first) * rec_dur:.0f} s), {len(header) + len(data)} bytes")
