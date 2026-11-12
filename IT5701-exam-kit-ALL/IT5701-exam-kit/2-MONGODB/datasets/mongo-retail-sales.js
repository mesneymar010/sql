// DATASET : retail_sales   (from retail_sales.csv)
// Fields  : Order_ID, Customer_ID, Product_ID, Category, Quantity, Unit_Price, Region
// Start shell: mongosh  (or mongo)  -> paste block by block

use examdb

// LOAD DATA
db.retail_sales.drop()
db.retail_sales.insertMany([
  {"Order_ID": "O1001", "Customer_ID": "CU101", "Product_ID": "PR101", "Category": "Electronics", "Quantity": 2, "Unit_Price": 15000, "Region": "Chennai"},
  {"Order_ID": "O1002", "Customer_ID": "CU102", "Product_ID": "PR102", "Category": "Clothing", "Quantity": 3, "Unit_Price": 1200, "Region": "Coimbatore"},
  {"Order_ID": "O1003", "Customer_ID": "CU103", "Product_ID": "PR103", "Category": "Grocery", "Quantity": 10, "Unit_Price": 150, "Region": "Madurai"},
  {"Order_ID": "O1004", "Customer_ID": "CU101", "Product_ID": "PR104", "Category": "Electronics", "Quantity": 1, "Unit_Price": 22000, "Region": "Chennai"},
  {"Order_ID": "O1005", "Customer_ID": "CU104", "Product_ID": "PR105", "Category": "Clothing", "Quantity": 2, "Unit_Price": 1800, "Region": "Trichy"},
  {"Order_ID": "O1006", "Customer_ID": "CU105", "Product_ID": "PR106", "Category": "Home", "Quantity": 4, "Unit_Price": 2500, "Region": "Salem"},
  {"Order_ID": "O1007", "Customer_ID": "CU102", "Product_ID": "PR101", "Category": "Electronics", "Quantity": 1, "Unit_Price": 15000, "Region": "Coimbatore"},
  {"Order_ID": "O1008", "Customer_ID": "CU106", "Product_ID": "PR103", "Category": "Grocery", "Quantity": 8, "Unit_Price": 150, "Region": "Chennai"},
  {"Order_ID": "O1009", "Customer_ID": "CU107", "Product_ID": "PR107", "Category": "Home", "Quantity": 2, "Unit_Price": 4200, "Region": "Madurai"},
  {"Order_ID": "O1010", "Customer_ID": "CU103", "Product_ID": "PR105", "Category": "Clothing", "Quantity": 1, "Unit_Price": 1800, "Region": "Madurai"},
  {"Order_ID": "O1011", "Customer_ID": "CU108", "Product_ID": "PR104", "Category": "Electronics", "Quantity": 1, "Unit_Price": 22000, "Region": "Trichy"},
  {"Order_ID": "O1012", "Customer_ID": "CU105", "Product_ID": "PR106", "Category": "Home", "Quantity": 2, "Unit_Price": 2500, "Region": "Salem"}
])
db.retail_sales.countDocuments({})
db.retail_sales.find()

// FIND (equal) : electronics orders
db.retail_sales.find({ Category: "Electronics" })

// FIND ($gte) + SORT + PROJECTION : quantity >= 3
db.retail_sales.find({ Quantity: { $gte: 3 } }, { _id: 0, Order_ID: 1, Category: 1, Quantity: 1 }).sort({ Quantity: -1 })

// FIND ($in) : Chennai or Madurai
db.retail_sales.find({ Region: { $in: ["Chennai", "Madurai"] } })

// COUNT + DISTINCT
db.retail_sales.countDocuments({ Region: "Chennai" })
db.retail_sales.distinct("Category")

// AGGREGATE ($project + $multiply) : amount of each order
db.retail_sales.aggregate([
  { $project: { _id: 0, Order_ID: 1, Customer_ID: 1, amount: { $multiply: ["$Quantity", "$Unit_Price"] } } },
  { $sort: { amount: -1 } }
])

// AGGREGATE (GROUP + SUM of product) : revenue per category
db.retail_sales.aggregate([
  { $group: { _id: "$Category", revenue: { $sum: { $multiply: ["$Quantity", "$Unit_Price"] } }, qty: { $sum: "$Quantity" } } },
  { $sort: { revenue: -1 } }
])

// AGGREGATE : revenue per region
db.retail_sales.aggregate([
  { $group: { _id: "$Region", revenue: { $sum: { $multiply: ["$Quantity", "$Unit_Price"] } }, orders: { $sum: 1 } } },
  { $sort: { revenue: -1 } }
])

// AGGREGATE (GROUP + HAVING) : customers with more than one order
db.retail_sales.aggregate([
  { $group: { _id: "$Customer_ID", orders: { $sum: 1 } } },
  { $match: { orders: { $gt: 1 } } }
])

// AGGREGATE (SORT + LIMIT) : top 3 customers by spend
db.retail_sales.aggregate([
  { $group: { _id: "$Customer_ID", spend: { $sum: { $multiply: ["$Quantity", "$Unit_Price"] } } } },
  { $sort: { spend: -1 } },
  { $limit: 3 }
])

// UPDATE / DELETE
db.retail_sales.updateOne({ Order_ID: "O1003" }, { $set: { Quantity: 12 } })
db.retail_sales.updateMany({ Category: "Clothing" }, { $mul: { Unit_Price: 0.9 } })
db.retail_sales.deleteOne({ Order_ID: "O1012" })
db.retail_sales.find()
