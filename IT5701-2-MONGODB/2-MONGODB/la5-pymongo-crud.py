# PyMongo : CRUD from Python (works with pymongo 3.7+ and 4.x)
# Install:  py -m pip install pymongo
# Run:      py la5-pymongo-crud.py      (MongoDB server must be running)

from pymongo import MongoClient

# CONNECT
client = MongoClient("mongodb://localhost:27017/")
db = client["mydb"]
users = db["users"]

users.delete_many({})   # start empty every run

# INSERT ONE
users.insert_one({"name": "Alice", "age": 30, "city": "New York"})

# INSERT MANY
users.insert_many([
    {"name": "Bob", "age": 25, "city": "San Francisco"},
    {"name": "Charlie", "age": 35, "city": "Los Angeles"},
    {"name": "Dave", "age": 28, "city": "Chicago"},
    {"name": "Eva", "age": 22, "city": "Miami"}
])

# FIND ALL
print("All users:")
for u in users.find():
    print(u)

# FIND WITH CONDITION ($gt)
print("\nAge > 25:")
for u in users.find({"age": {"$gt": 25}}):
    print(u)

# FIND ONE
print("\nFind one:", users.find_one({"name": "Alice"}))

# PROJECTION + SORT + LIMIT
print("\nTop 2 oldest (name, age):")
for u in users.find({}, {"name": 1, "age": 1, "_id": 0}).sort("age", -1).limit(2):
    print(u)

# COUNT
print("\nTotal users:", users.count_documents({}))

# UPDATE ONE
users.update_one({"name": "Alice"}, {"$set": {"city": "Chicago"}})

# UPDATE MANY
users.update_many({"age": {"$lt": 30}}, {"$set": {"city": "Boston"}})

# INCREMENT
users.update_one({"name": "Bob"}, {"$inc": {"age": 1}})

print("\nAfter update:")
for u in users.find():
    print(u)

# DELETE ONE
users.delete_one({"name": "Charlie"})

# DELETE MANY
users.delete_many({"age": {"$lt": 25}})

print("\nAfter delete:")
for u in users.find():
    print(u)

# AGGREGATE : GROUP BY city
print("\nCount per city:")
for r in users.aggregate([{"$group": {"_id": "$city", "total": {"$sum": 1}}}]):
    print(r)

client.close()
