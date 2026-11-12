// DATASET : library_transactions   (from library_transactions.csv)
// Fields  : Transaction_ID, Member_ID, Book_ID, Category, Issue_Date, Return_Date, Fine_Amount
// Start shell: mongosh  (or mongo)  -> paste block by block

use examdb

// LOAD DATA
db.library_transactions.drop()
db.library_transactions.insertMany([
  {"Transaction_ID": "L001", "Member_ID": "MB101", "Book_ID": "B101", "Category": "Computer Science", "Issue_Date": "2026-09-01", "Return_Date": "2026-09-10", "Fine_Amount": 0},
  {"Transaction_ID": "L002", "Member_ID": "MB102", "Book_ID": "B102", "Category": "Literature", "Issue_Date": "2026-09-02", "Return_Date": "2026-09-15", "Fine_Amount": 10},
  {"Transaction_ID": "L003", "Member_ID": "MB101", "Book_ID": "B103", "Category": "Data Science", "Issue_Date": "2026-09-05", "Return_Date": "2026-09-20", "Fine_Amount": 15},
  {"Transaction_ID": "L004", "Member_ID": "MB103", "Book_ID": "B101", "Category": "Computer Science", "Issue_Date": "2026-09-07", "Return_Date": "2026-09-16", "Fine_Amount": 0},
  {"Transaction_ID": "L005", "Member_ID": "MB104", "Book_ID": "B104", "Category": "Mathematics", "Issue_Date": "2026-09-08", "Return_Date": "2026-09-25", "Fine_Amount": 20},
  {"Transaction_ID": "L006", "Member_ID": "MB102", "Book_ID": "B105", "Category": "Data Science", "Issue_Date": "2026-09-10", "Return_Date": "2026-09-19", "Fine_Amount": 0},
  {"Transaction_ID": "L007", "Member_ID": "MB105", "Book_ID": "B102", "Category": "Literature", "Issue_Date": "2026-09-11", "Return_Date": "2026-09-22", "Fine_Amount": 5},
  {"Transaction_ID": "L008", "Member_ID": "MB103", "Book_ID": "B106", "Category": "History", "Issue_Date": "2026-09-12", "Return_Date": "2026-09-28", "Fine_Amount": 12},
  {"Transaction_ID": "L009", "Member_ID": "MB101", "Book_ID": "B105", "Category": "Data Science", "Issue_Date": "2026-09-15", "Return_Date": "2026-09-25", "Fine_Amount": 0},
  {"Transaction_ID": "L010", "Member_ID": "MB106", "Book_ID": "B103", "Category": "Data Science", "Issue_Date": "2026-09-18", "Return_Date": "2026-09-29", "Fine_Amount": 8}
])
db.library_transactions.countDocuments({})
db.library_transactions.find()

// FIND ($gt) : transactions with fine
db.library_transactions.find({ Fine_Amount: { $gt: 0 } })

// FIND (equal) + SORT : Data Science books by issue date
db.library_transactions.find({ Category: "Data Science" }).sort({ Issue_Date: 1 })

// FIND (date range as text) : issued between 5 and 12 Sep
db.library_transactions.find({ Issue_Date: { $gte: "2026-09-05", $lte: "2026-09-12" } })

// FIND (regex) : categories containing "Science"
db.library_transactions.find({ Category: /Science/ })

// COUNT + DISTINCT
db.library_transactions.countDocuments({ Fine_Amount: 0 })
db.library_transactions.distinct("Member_ID")

// AGGREGATE (GROUP + SUM) : total fine per member
db.library_transactions.aggregate([
  { $group: { _id: "$Member_ID", totalFine: { $sum: "$Fine_Amount" }, books: { $sum: 1 } } },
  { $sort: { totalFine: -1 } }
])

// AGGREGATE (GROUP + COUNT) : issues per category
db.library_transactions.aggregate([
  { $group: { _id: "$Category", issues: { $sum: 1 } } },
  { $sort: { issues: -1 } }
])

// AGGREGATE (GROUP + HAVING) : books issued more than once
db.library_transactions.aggregate([
  { $group: { _id: "$Book_ID", count: { $sum: 1 } } },
  { $match: { count: { $gt: 1 } } }
])

// AGGREGATE (MATCH + GROUP) : fine collected per category
db.library_transactions.aggregate([
  { $match: { Fine_Amount: { $gt: 0 } } },
  { $group: { _id: "$Category", totalFine: { $sum: "$Fine_Amount" } } }
])

// UPDATE / DELETE
db.library_transactions.updateOne({ Transaction_ID: "L005" }, { $set: { Fine_Amount: 25 } })
db.library_transactions.updateMany({ Fine_Amount: { $gt: 0 } }, { $inc: { Fine_Amount: 5 } })
db.library_transactions.deleteOne({ Transaction_ID: "L010" })
db.library_transactions.find()
