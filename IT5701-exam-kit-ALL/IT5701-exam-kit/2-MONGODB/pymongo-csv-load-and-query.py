# PyMongo : load ANY CSV into MongoDB and run common queries (pymongo 3.7+ / 4.x)
# Usage (cmd):
#   py pymongo-csv-load-and-query.py <csv_file> <group_field> <number_field>
# Examples:
#   py pymongo-csv-load-and-query.py retail_sales.csv Category Quantity
#   py pymongo-csv-load-and-query.py bank_transactions.csv Branch Amount
#   py pymongo-csv-load-and-query.py student_attendance.csv Department Attended_Classes

import csv
import os
import sys
from pymongo import MongoClient


def convert(v):
    v = v.strip()
    if v == "":
        return None
    if len(v) > 1 and v[0] == "0" and v[1] != ".":
        return v
    try:
        return float(v) if "." in v else int(v)
    except ValueError:
        return v


csv_file = sys.argv[1]
group_field = sys.argv[2]
num_field = sys.argv[3]
name = os.path.splitext(os.path.basename(csv_file))[0]

# CONNECT
client = MongoClient("mongodb://localhost:27017/")
db = client["examdb"]
col = db[name]

# LOAD CSV (insert_many)
col.delete_many({})
with open(csv_file, newline="", encoding="utf-8-sig") as f:
    docs = [dict((k, convert(v)) for k, v in row.items()) for row in csv.DictReader(f)]
col.insert_many(docs)
print("Inserted", col.count_documents({}), "documents into", name)

# FIND ALL
print("\n--- All documents ---")
for d in col.find({}, {"_id": 0}):
    print(d)

# AGGREGATE : SUM, AVG, MIN, MAX, COUNT per group
print("\n--- Group by", group_field, "on", num_field, "---")
pipeline = [
    {"$group": {"_id": "$" + group_field,
                "total": {"$sum": "$" + num_field},
                "avg": {"$avg": "$" + num_field},
                "min": {"$min": "$" + num_field},
                "max": {"$max": "$" + num_field},
                "count": {"$sum": 1}}},
    {"$sort": {"total": -1}}
]
for r in col.aggregate(pipeline):
    print(r)

# FIND WITH CONDITION : above average
avg = list(col.aggregate([{"$group": {"_id": None, "a": {"$avg": "$" + num_field}}}]))[0]["a"]
print("\n---", num_field, "above average", round(avg, 2), "---")
for d in col.find({num_field: {"$gt": avg}}, {"_id": 0}):
    print(d)

# SORT + LIMIT : top 3
print("\n--- Top 3 by", num_field, "---")
for d in col.find({}, {"_id": 0}).sort(num_field, -1).limit(3):
    print(d)

# COUNT + DISTINCT
print("\nDistinct", group_field, ":", col.distinct(group_field))
first_group = col.distinct(group_field)[0]
print("Count where", group_field, "=", first_group, ":", col.count_documents({group_field: first_group}))

# UPDATE
r = col.update_many({group_field: first_group}, {"$inc": {num_field: 1}})
print("\nUpdated", r.modified_count, "documents (", num_field, "+1 for", first_group, ")")

# DELETE
r = col.delete_one({group_field: first_group})
print("Deleted", r.deleted_count, "document. Remaining:", col.count_documents({}))

client.close()
