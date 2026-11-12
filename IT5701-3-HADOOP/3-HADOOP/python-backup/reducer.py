import sys

op = sys.argv[1] if len(sys.argv) > 1 else "sum"

groups = {}
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    key, value = line.split("\t")
    groups.setdefault(key, []).append(float(value))

for key in sorted(groups):
    v = groups[key]
    if op == "avg":
        result = sum(v) / len(v)
    elif op == "count":
        result = len(v)
    elif op == "max":
        result = max(v)
    elif op == "min":
        result = min(v)
    else:
        result = sum(v)
    print(key + "\t" + str(result))
