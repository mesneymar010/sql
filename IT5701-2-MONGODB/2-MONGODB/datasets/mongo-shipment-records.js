// DATASET : shipment_records   (from shipment_records.csv)
// Fields  : Shipment_ID, Customer_ID, Source_City, Destination_City, Transport_Mode, Weight_KG, Shipping_Cost, Delivery_Status
// Start shell: mongosh  (or mongo)  -> paste block by block

use examdb

// LOAD DATA
db.shipment_records.drop()
db.shipment_records.insertMany([
  {"Shipment_ID": "SH001", "Customer_ID": "CU301", "Source_City": "Chennai", "Destination_City": "Bengaluru", "Transport_Mode": "Road", "Weight_KG": 120, "Shipping_Cost": 4500, "Delivery_Status": "Delivered"},
  {"Shipment_ID": "SH002", "Customer_ID": "CU302", "Source_City": "Coimbatore", "Destination_City": "Chennai", "Transport_Mode": "Rail", "Weight_KG": 350, "Shipping_Cost": 2800, "Delivery_Status": "In Transit"},
  {"Shipment_ID": "SH003", "Customer_ID": "CU303", "Source_City": "Madurai", "Destination_City": "Trichy", "Transport_Mode": "Road", "Weight_KG": 80, "Shipping_Cost": 1600, "Delivery_Status": "Delivered"},
  {"Shipment_ID": "SH004", "Customer_ID": "CU301", "Source_City": "Chennai", "Destination_City": "Hyderabad", "Transport_Mode": "Air", "Weight_KG": 45, "Shipping_Cost": 6200, "Delivery_Status": "Delayed"},
  {"Shipment_ID": "SH005", "Customer_ID": "CU304", "Source_City": "Salem", "Destination_City": "Bengaluru", "Transport_Mode": "Road", "Weight_KG": 210, "Shipping_Cost": 3900, "Delivery_Status": "Delivered"},
  {"Shipment_ID": "SH006", "Customer_ID": "CU305", "Source_City": "Trichy", "Destination_City": "Chennai", "Transport_Mode": "Rail", "Weight_KG": 400, "Shipping_Cost": 3000, "Delivery_Status": "In Transit"},
  {"Shipment_ID": "SH007", "Customer_ID": "CU306", "Source_City": "Erode", "Destination_City": "Madurai", "Transport_Mode": "Road", "Weight_KG": 65, "Shipping_Cost": 1400, "Delivery_Status": "Delivered"},
  {"Shipment_ID": "SH008", "Customer_ID": "CU302", "Source_City": "Coimbatore", "Destination_City": "Hyderabad", "Transport_Mode": "Air", "Weight_KG": 30, "Shipping_Cost": 5100, "Delivery_Status": "Delivered"},
  {"Shipment_ID": "SH009", "Customer_ID": "CU307", "Source_City": "Chennai", "Destination_City": "Mumbai", "Transport_Mode": "Road", "Weight_KG": 180, "Shipping_Cost": 4700, "Delivery_Status": "Delayed"},
  {"Shipment_ID": "SH010", "Customer_ID": "CU308", "Source_City": "Madurai", "Destination_City": "Bengaluru", "Transport_Mode": "Rail", "Weight_KG": 320, "Shipping_Cost": 2600, "Delivery_Status": "Delivered"}
])
db.shipment_records.countDocuments({})
db.shipment_records.find()

// FIND (equal) : delayed shipments
db.shipment_records.find({ Delivery_Status: "Delayed" })

// FIND ($or) : from Chennai or by Air
db.shipment_records.find({ $or: [ { Source_City: "Chennai" }, { Transport_Mode: "Air" } ] })

// FIND ($gt) + SORT + PROJECTION : weight above 200
db.shipment_records.find({ Weight_KG: { $gt: 200 } }, { _id: 0, Shipment_ID: 1, Weight_KG: 1, Transport_Mode: 1 }).sort({ Weight_KG: -1 })

// COUNT + DISTINCT
db.shipment_records.countDocuments({ Delivery_Status: "Delivered" })
db.shipment_records.distinct("Destination_City")

// AGGREGATE (GROUP + COUNT) : shipments per status
db.shipment_records.aggregate([
  { $group: { _id: "$Delivery_Status", count: { $sum: 1 } } }
])

// AGGREGATE (GROUP + SUM/AVG) : cost and weight per transport mode
db.shipment_records.aggregate([
  { $group: { _id: "$Transport_Mode", totalCost: { $sum: "$Shipping_Cost" }, avgCost: { $avg: "$Shipping_Cost" }, totalWeight: { $sum: "$Weight_KG" } } },
  { $sort: { totalCost: -1 } }
])

// AGGREGATE ($project + $divide) : cost per kg
db.shipment_records.aggregate([
  { $project: { _id: 0, Shipment_ID: 1, costPerKg: { $divide: ["$Shipping_Cost", "$Weight_KG"] } } },
  { $sort: { costPerKg: -1 } }
])

// AGGREGATE (MATCH + GROUP) : delivered shipments per destination
db.shipment_records.aggregate([
  { $match: { Delivery_Status: "Delivered" } },
  { $group: { _id: "$Destination_City", count: { $sum: 1 } } }
])

// UPDATE / DELETE
db.shipment_records.updateOne({ Shipment_ID: "SH004" }, { $set: { Delivery_Status: "Delivered" } })
db.shipment_records.updateMany({ Delivery_Status: "In Transit" }, { $set: { Delivery_Status: "Delivered" } })
db.shipment_records.deleteOne({ Shipment_ID: "SH010" })
db.shipment_records.find()
