import sys

key_col = int(sys.argv[1]) if len(sys.argv) > 1 else 2
val_col = int(sys.argv[2]) if len(sys.argv) > 2 else 3

for line in sys.stdin:
    data = line.strip().split(",")
    try:
        key = "Total" if key_col < 0 else data[key_col].strip()
        value = float(data[val_col])
        print(key + "\t" + str(value))
    except:
        pass
