# CSV -> MongoDB insertMany commands (no pymongo needed)
# Usage (cmd):  py csv_to_mongo_js.py data.csv > data.js
#               py csv_to_mongo_js.py data.csv my_collection > data.js
# Then open data.js, copy everything, paste into mongosh / mongo (after "use examdb")

import csv
import json
import os
import re
import sys


def convert(v):
    v = v.strip()
    if v == "":
        return None
    if re.match(r"^-?\d+$", v) and not (len(v.lstrip("-")) > 1 and v.lstrip("-")[0] == "0"):
        return int(v)
    if re.match(r"^-?\d*\.\d+$", v):
        return float(v)
    return v


def main():
    if len(sys.argv) < 2:
        print("Usage: py csv_to_mongo_js.py file.csv [collection]")
        return
    path = sys.argv[1]
    name = sys.argv[2] if len(sys.argv) > 2 else os.path.splitext(os.path.basename(path))[0]
    name = re.sub(r"[^A-Za-z0-9_]", "_", name).lower()

    with open(path, newline="", encoding="utf-8-sig") as f:
        rows = [r for r in csv.reader(f) if any(c.strip() for c in r)]
    header = [h.strip() for h in rows[0]]
    docs = []
    for r in rows[1:]:
        doc = {}
        for i, h in enumerate(header):
            doc[h] = convert(r[i]) if i < len(r) else None
        docs.append(doc)

    print("db.%s.drop()" % name)
    print("db.%s.insertMany([" % name)
    print(",\n".join("  " + json.dumps(d) for d in docs))
    print("])")
    print("db.%s.countDocuments({})" % name)
    print("db.%s.find()" % name)


main()
