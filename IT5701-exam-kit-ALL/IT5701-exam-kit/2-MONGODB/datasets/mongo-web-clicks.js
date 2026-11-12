// DATASET : web_clicks   (from web_clicks.csv)
// Fields  : Click_ID, User_ID, Country, Device_Type, Page_Category, Click_Time, Session_ID, Duration_Seconds
// Start shell: mongosh  (or mongo)  -> paste block by block

use examdb

// LOAD DATA
db.web_clicks.drop()
db.web_clicks.insertMany([
  {"Click_ID": "C001", "User_ID": "U101", "Country": "India", "Device_Type": "Mobile", "Page_Category": "Home", "Click_Time": "2026-10-01 09:00:00", "Session_ID": "S101", "Duration_Seconds": 25},
  {"Click_ID": "C002", "User_ID": "U101", "Country": "India", "Device_Type": "Mobile", "Page_Category": "Products", "Click_Time": "2026-10-01 09:01:10", "Session_ID": "S101", "Duration_Seconds": 60},
  {"Click_ID": "C003", "User_ID": "U102", "Country": "USA", "Device_Type": "Desktop", "Page_Category": "Home", "Click_Time": "2026-10-01 10:00:00", "Session_ID": "S102", "Duration_Seconds": 35},
  {"Click_ID": "C004", "User_ID": "U102", "Country": "USA", "Device_Type": "Desktop", "Page_Category": "Checkout", "Click_Time": "2026-10-01 10:02:00", "Session_ID": "S102", "Duration_Seconds": 90},
  {"Click_ID": "C005", "User_ID": "U103", "Country": "India", "Device_Type": "Tablet", "Page_Category": "Products", "Click_Time": "2026-10-01 11:10:00", "Session_ID": "S103", "Duration_Seconds": 45},
  {"Click_ID": "C006", "User_ID": "U104", "Country": "UK", "Device_Type": "Mobile", "Page_Category": "Home", "Click_Time": "2026-10-01 12:00:00", "Session_ID": "S104", "Duration_Seconds": 20},
  {"Click_ID": "C007", "User_ID": "U104", "Country": "UK", "Device_Type": "Mobile", "Page_Category": "Products", "Click_Time": "2026-10-01 12:01:00", "Session_ID": "S104", "Duration_Seconds": 75},
  {"Click_ID": "C008", "User_ID": "U105", "Country": "India", "Device_Type": "Desktop", "Page_Category": "Checkout", "Click_Time": "2026-10-01 13:15:00", "Session_ID": "S105", "Duration_Seconds": 120},
  {"Click_ID": "C009", "User_ID": "U106", "Country": "USA", "Device_Type": "Mobile", "Page_Category": "Products", "Click_Time": "2026-10-01 14:20:00", "Session_ID": "S106", "Duration_Seconds": 55},
  {"Click_ID": "C010", "User_ID": "U107", "Country": "UK", "Device_Type": "Desktop", "Page_Category": "Home", "Click_Time": "2026-10-01 15:00:00", "Session_ID": "S107", "Duration_Seconds": 40},
  {"Click_ID": "C011", "User_ID": "U108", "Country": "India", "Device_Type": "Mobile", "Page_Category": "Blog", "Click_Time": "2026-10-02 09:30:00", "Session_ID": "S108", "Duration_Seconds": 32},
  {"Click_ID": "C012", "User_ID": "U103", "Country": "India", "Device_Type": "Tablet", "Page_Category": "Checkout", "Click_Time": "2026-10-02 11:12:00", "Session_ID": "S103", "Duration_Seconds": 85}
])
db.web_clicks.countDocuments({})
db.web_clicks.find()

// FIND (equal) : checkout clicks
db.web_clicks.find({ Page_Category: "Checkout" })

// FIND (AND) : mobile clicks from India
db.web_clicks.find({ Device_Type: "Mobile", Country: "India" })

// FIND ($gt) + SORT + PROJECTION : duration above 50s
db.web_clicks.find({ Duration_Seconds: { $gt: 50 } }, { _id: 0, Click_ID: 1, User_ID: 1, Duration_Seconds: 1 }).sort({ Duration_Seconds: -1 })

// FIND (regex on date text) : clicks on 1 Oct 2026
db.web_clicks.find({ Click_Time: /^2026-10-01/ })

// COUNT + DISTINCT
db.web_clicks.countDocuments({ Country: "India" })
db.web_clicks.distinct("User_ID")

// AGGREGATE (GROUP + COUNT) : clicks per country
db.web_clicks.aggregate([
  { $group: { _id: "$Country", clicks: { $sum: 1 }, totalDuration: { $sum: "$Duration_Seconds" } } },
  { $sort: { clicks: -1 } }
])

// AGGREGATE (GROUP + AVG) : average duration per device
db.web_clicks.aggregate([
  { $group: { _id: "$Device_Type", avgDuration: { $avg: "$Duration_Seconds" } } }
])

// AGGREGATE (GROUP + SUM) : total time per session
db.web_clicks.aggregate([
  { $group: { _id: "$Session_ID", clicks: { $sum: 1 }, totalSeconds: { $sum: "$Duration_Seconds" } } },
  { $sort: { totalSeconds: -1 } }
])

// AGGREGATE (GROUP + HAVING) : users with more than one click
db.web_clicks.aggregate([
  { $group: { _id: "$User_ID", clicks: { $sum: 1 } } },
  { $match: { clicks: { $gt: 1 } } }
])

// AGGREGATE (GROUP) : clicks per page category
db.web_clicks.aggregate([
  { $group: { _id: "$Page_Category", clicks: { $sum: 1 } } },
  { $sort: { clicks: -1 } }
])

// UPDATE / DELETE
db.web_clicks.updateOne({ Click_ID: "C006" }, { $set: { Duration_Seconds: 30 } })
db.web_clicks.updateMany({ Device_Type: "Tablet" }, { $set: { Device_Type: "Mobile" } })
db.web_clicks.deleteMany({ Duration_Seconds: { $lt: 25 } })
db.web_clicks.find()
