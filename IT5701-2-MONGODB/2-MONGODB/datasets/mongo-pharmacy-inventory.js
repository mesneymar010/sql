// DATASET : pharmacy_inventory   (from pharmacy_inventory.csv)
// Fields  : Medicine_ID, Medicine_Name, Category, Supplier_ID, Unit_Price, Stock_Quantity, Reorder_Level
// Start shell: mongosh  (or mongo)  -> paste block by block

use examdb

// LOAD DATA
db.pharmacy_inventory.drop()
db.pharmacy_inventory.insertMany([
  {"Medicine_ID": "M101", "Medicine_Name": "Paracetamol", "Category": "Analgesic", "Supplier_ID": "SUP01", "Unit_Price": 2.5, "Stock_Quantity": 500, "Reorder_Level": 100},
  {"Medicine_ID": "M102", "Medicine_Name": "Amoxicillin", "Category": "Antibiotic", "Supplier_ID": "SUP02", "Unit_Price": 8.0, "Stock_Quantity": 75, "Reorder_Level": 100},
  {"Medicine_ID": "M103", "Medicine_Name": "Cetirizine", "Category": "Antihistamine", "Supplier_ID": "SUP01", "Unit_Price": 3.5, "Stock_Quantity": 180, "Reorder_Level": 50},
  {"Medicine_ID": "M104", "Medicine_Name": "Metformin", "Category": "Antidiabetic", "Supplier_ID": "SUP03", "Unit_Price": 6.0, "Stock_Quantity": 90, "Reorder_Level": 120},
  {"Medicine_ID": "M105", "Medicine_Name": "Amlodipine", "Category": "Antihypertensive", "Supplier_ID": "SUP02", "Unit_Price": 4.5, "Stock_Quantity": 45, "Reorder_Level": 60},
  {"Medicine_ID": "M106", "Medicine_Name": "Omeprazole", "Category": "Gastrointestinal", "Supplier_ID": "SUP04", "Unit_Price": 5.0, "Stock_Quantity": 130, "Reorder_Level": 80},
  {"Medicine_ID": "M107", "Medicine_Name": "Ibuprofen", "Category": "Analgesic", "Supplier_ID": "SUP01", "Unit_Price": 3.0, "Stock_Quantity": 40, "Reorder_Level": 75},
  {"Medicine_ID": "M108", "Medicine_Name": "Azithromycin", "Category": "Antibiotic", "Supplier_ID": "SUP03", "Unit_Price": 12.0, "Stock_Quantity": 55, "Reorder_Level": 70},
  {"Medicine_ID": "M109", "Medicine_Name": "ORS Sachet", "Category": "Electrolyte", "Supplier_ID": "SUP04", "Unit_Price": 1.5, "Stock_Quantity": 300, "Reorder_Level": 100},
  {"Medicine_ID": "M110", "Medicine_Name": "Vitamin C", "Category": "Supplement", "Supplier_ID": "SUP02", "Unit_Price": 2.0, "Stock_Quantity": 65, "Reorder_Level": 80}
])
db.pharmacy_inventory.countDocuments({})
db.pharmacy_inventory.find()

// FIND ($expr) : stock below reorder level (compare two fields)
db.pharmacy_inventory.find({ $expr: { $lt: ["$Stock_Quantity", "$Reorder_Level"] } })

// FIND ($gt) + SORT + PROJECTION : price above 4
db.pharmacy_inventory.find({ Unit_Price: { $gt: 4 } }, { _id: 0, Medicine_Name: 1, Unit_Price: 1 }).sort({ Unit_Price: -1 })

// FIND (regex) : names starting with A
db.pharmacy_inventory.find({ Medicine_Name: /^A/ })

// COUNT + DISTINCT
db.pharmacy_inventory.countDocuments({ Supplier_ID: "SUP01" })
db.pharmacy_inventory.distinct("Category")

// AGGREGATE ($project + $multiply) : stock value of each medicine
db.pharmacy_inventory.aggregate([
  { $project: { _id: 0, Medicine_Name: 1, stockValue: { $multiply: ["$Unit_Price", "$Stock_Quantity"] } } },
  { $sort: { stockValue: -1 } }
])

// AGGREGATE (GROUP + SUM of product) : stock value per supplier
db.pharmacy_inventory.aggregate([
  { $group: { _id: "$Supplier_ID", totalValue: { $sum: { $multiply: ["$Unit_Price", "$Stock_Quantity"] } }, items: { $sum: 1 } } }
])

// AGGREGATE (GROUP + AVG) : per category
db.pharmacy_inventory.aggregate([
  { $group: { _id: "$Category", avgPrice: { $avg: "$Unit_Price" }, totalStock: { $sum: "$Stock_Quantity" } } }
])

// AGGREGATE (GROUP + HAVING) : categories with more than one medicine
db.pharmacy_inventory.aggregate([
  { $group: { _id: "$Category", count: { $sum: 1 } } },
  { $match: { count: { $gt: 1 } } }
])

// UPDATE / DELETE
db.pharmacy_inventory.updateOne({ Medicine_ID: "M107" }, { $inc: { Stock_Quantity: 100 } })
db.pharmacy_inventory.updateMany({ Category: "Antibiotic" }, { $mul: { Unit_Price: 1.1 } })
db.pharmacy_inventory.deleteOne({ Medicine_ID: "M110" })
db.pharmacy_inventory.find()
