// DATASET : bank_transactions   (from bank_transactions.csv)
// Fields  : Transaction_ID, Customer_ID, Account_Type, Transaction_Type, Amount, Branch, Transaction_Date
// Start shell: mongosh  (or mongo)  -> paste block by block

use examdb

// LOAD DATA
db.bank_transactions.drop()
db.bank_transactions.insertMany([
  {"Transaction_ID": "T001", "Customer_ID": "CU201", "Account_Type": "Savings", "Transaction_Type": "Deposit", "Amount": 5000, "Branch": "Chennai", "Transaction_Date": "2026-10-01"},
  {"Transaction_ID": "T002", "Customer_ID": "CU202", "Account_Type": "Current", "Transaction_Type": "Withdrawal", "Amount": 1800, "Branch": "Coimbatore", "Transaction_Date": "2026-10-01"},
  {"Transaction_ID": "T003", "Customer_ID": "CU201", "Account_Type": "Savings", "Transaction_Type": "Withdrawal", "Amount": 750, "Branch": "Chennai", "Transaction_Date": "2026-10-02"},
  {"Transaction_ID": "T004", "Customer_ID": "CU203", "Account_Type": "Savings", "Transaction_Type": "Deposit", "Amount": 12000, "Branch": "Madurai", "Transaction_Date": "2026-10-02"},
  {"Transaction_ID": "T005", "Customer_ID": "CU204", "Account_Type": "Current", "Transaction_Type": "Deposit", "Amount": 8500, "Branch": "Trichy", "Transaction_Date": "2026-10-03"},
  {"Transaction_ID": "T006", "Customer_ID": "CU205", "Account_Type": "Savings", "Transaction_Type": "Withdrawal", "Amount": 2200, "Branch": "Salem", "Transaction_Date": "2026-10-03"},
  {"Transaction_ID": "T007", "Customer_ID": "CU202", "Account_Type": "Current", "Transaction_Type": "Deposit", "Amount": 3000, "Branch": "Coimbatore", "Transaction_Date": "2026-10-04"},
  {"Transaction_ID": "T008", "Customer_ID": "CU206", "Account_Type": "Savings", "Transaction_Type": "Deposit", "Amount": 6400, "Branch": "Chennai", "Transaction_Date": "2026-10-04"},
  {"Transaction_ID": "T009", "Customer_ID": "CU203", "Account_Type": "Savings", "Transaction_Type": "Withdrawal", "Amount": 1500, "Branch": "Madurai", "Transaction_Date": "2026-10-05"},
  {"Transaction_ID": "T010", "Customer_ID": "CU207", "Account_Type": "Current", "Transaction_Type": "Deposit", "Amount": 10000, "Branch": "Trichy", "Transaction_Date": "2026-10-05"}
])
db.bank_transactions.countDocuments({})
db.bank_transactions.find()

// FIND (equal) : only deposits
db.bank_transactions.find({ Transaction_Type: "Deposit" })

// FIND ($gt) + SORT + PROJECTION : amount above 5000, highest first
db.bank_transactions.find({ Amount: { $gt: 5000 } }, { _id: 0, Transaction_ID: 1, Customer_ID: 1, Amount: 1 }).sort({ Amount: -1 })

// FIND (AND) : savings withdrawals
db.bank_transactions.find({ Account_Type: "Savings", Transaction_Type: "Withdrawal" })

// FIND ($in) : Chennai or Madurai
db.bank_transactions.find({ Branch: { $in: ["Chennai", "Madurai"] } })

// FIND (date range, dates stored as text) : 2 to 4 Oct
db.bank_transactions.find({ Transaction_Date: { $gte: "2026-10-02", $lte: "2026-10-04" } })

// COUNT + DISTINCT
db.bank_transactions.countDocuments({ Transaction_Type: "Withdrawal" })
db.bank_transactions.distinct("Branch")

// AGGREGATE (GROUP + SUM + SORT) : total amount per branch
db.bank_transactions.aggregate([
  { $group: { _id: "$Branch", total: { $sum: "$Amount" }, count: { $sum: 1 } } },
  { $sort: { total: -1 } }
])

// AGGREGATE (GROUP + AVG/MAX/MIN) : per account type
db.bank_transactions.aggregate([
  { $group: { _id: "$Account_Type", avgAmount: { $avg: "$Amount" }, maxAmount: { $max: "$Amount" }, minAmount: { $min: "$Amount" } } }
])

// AGGREGATE (MATCH + GROUP) : total deposits per customer
db.bank_transactions.aggregate([
  { $match: { Transaction_Type: "Deposit" } },
  { $group: { _id: "$Customer_ID", totalDeposit: { $sum: "$Amount" } } },
  { $sort: { totalDeposit: -1 } }
])

// AGGREGATE (GROUP + HAVING) : customers with more than 1 transaction
db.bank_transactions.aggregate([
  { $group: { _id: "$Customer_ID", count: { $sum: 1 } } },
  { $match: { count: { $gt: 1 } } }
])

// AGGREGATE ($cond) : balance per customer (deposit +, withdrawal -)
db.bank_transactions.aggregate([
  { $group: { _id: "$Customer_ID", balance: { $sum: { $cond: [ { $eq: ["$Transaction_Type", "Deposit"] }, "$Amount", { $multiply: ["$Amount", -1] } ] } } } }
])

// UPDATE / DELETE
db.bank_transactions.updateOne({ Transaction_ID: "T001" }, { $set: { Amount: 5500 } })
db.bank_transactions.updateMany({ Branch: "Chennai" }, { $inc: { Amount: 100 } })
db.bank_transactions.deleteOne({ Transaction_ID: "T010" })
db.bank_transactions.find()
