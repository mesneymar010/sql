// MongoDB : Shell CRUD (works in both mongosh and old mongo shell)
// Start shell in cmd:  mongosh      (or)  mongo
// Paste these one by one. ("use" works only when typed in the shell, not in load())

// CREATE / SWITCH DATABASE
use mydb
db

// CREATE COLLECTION
db.createCollection("users")
show collections

// INSERT ONE
db.users.insertOne({ name: "Alice", age: 30, city: "New York" })

// INSERT MANY
db.users.insertMany([
  { name: "Bob", age: 25, city: "San Francisco" },
  { name: "Charlie", age: 35, city: "Los Angeles" },
  { name: "Dave", age: 28, city: "Chicago" },
  { name: "Eva", age: 22, city: "Miami" }
])

// FIND ALL
db.users.find()
db.users.find().pretty()

// FIND ONE
db.users.findOne({ name: "Alice" })

// FIND WITH CONDITION (equal)
db.users.find({ city: "Chicago" })

// COMPARISON : $gt $gte $lt $lte $ne
db.users.find({ age: { $gt: 25 } })
db.users.find({ age: { $gte: 25, $lte: 30 } })
db.users.find({ city: { $ne: "Miami" } })

// $in
db.users.find({ city: { $in: ["Miami", "Chicago"] } })

// AND / OR
db.users.find({ age: { $gt: 20 }, city: "Miami" })
db.users.find({ $or: [ { age: { $lt: 25 } }, { city: "Chicago" } ] })

// PATTERN MATCH (like SQL LIKE 'A%')
db.users.find({ name: /^A/ })

// PROJECTION (show only some fields)
db.users.find({}, { name: 1, age: 1, _id: 0 })

// SORT (1 = asc, -1 = desc) + LIMIT
db.users.find().sort({ age: -1 })
db.users.find().sort({ age: 1 }).limit(2)

// COUNT
db.users.countDocuments({})
db.users.countDocuments({ age: { $gt: 25 } })
// old mongo shell (below 4.0): db.users.find({ age: { $gt: 25 } }).count()

// DISTINCT
db.users.distinct("city")

// UPDATE ONE ($set)
db.users.updateOne({ name: "Alice" }, { $set: { city: "Chicago" } })

// UPDATE MANY
db.users.updateMany({ age: { $lt: 30 } }, { $set: { city: "Boston" } })

// INCREMENT ($inc)
db.users.updateOne({ name: "Bob" }, { $inc: { age: 1 } })

// ADD NEW FIELD / REMOVE FIELD ($unset)
db.users.updateMany({}, { $set: { status: "active" } })
db.users.updateMany({}, { $unset: { status: "" } })

// UPSERT (update if exists, else insert)
db.users.updateOne({ name: "Frank" }, { $set: { age: 26, city: "Houston" } }, { upsert: true })

// DELETE ONE
db.users.deleteOne({ name: "Charlie" })

// DELETE MANY
db.users.deleteMany({ age: { $lt: 25 } })

// AGGREGATE : GROUP BY + COUNT / AVG (like SQL GROUP BY)
db.users.aggregate([
  { $group: { _id: "$city", total: { $sum: 1 }, avgAge: { $avg: "$age" } } }
])

// AGGREGATE : MATCH + GROUP + SORT
db.users.aggregate([
  { $match: { age: { $gt: 20 } } },
  { $group: { _id: "$city", total: { $sum: 1 } } },
  { $sort: { total: -1 } }
])

// FINAL CHECK
db.users.find()

// DROP COLLECTION / DATABASE
db.users.drop()
db.dropDatabase()
show dbs
