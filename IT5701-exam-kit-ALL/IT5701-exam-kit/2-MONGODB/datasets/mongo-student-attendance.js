// DATASET : student_attendance   (from student_attendance.csv)
// Fields  : Student_ID, Student_Name, Department, Course_ID, Total_Classes, Attended_Classes
// Start shell: mongosh  (or mongo)  -> paste block by block

use examdb

// LOAD DATA
db.student_attendance.drop()
db.student_attendance.insertMany([
  {"Student_ID": "S101", "Student_Name": "Arun Kumar", "Department": "IT", "Course_ID": "C101", "Total_Classes": 40, "Attended_Classes": 36},
  {"Student_ID": "S101", "Student_Name": "Arun Kumar", "Department": "IT", "Course_ID": "C102", "Total_Classes": 38, "Attended_Classes": 31},
  {"Student_ID": "S102", "Student_Name": "Priya Sharma", "Department": "CSE", "Course_ID": "C101", "Total_Classes": 40, "Attended_Classes": 30},
  {"Student_ID": "S102", "Student_Name": "Priya Sharma", "Department": "CSE", "Course_ID": "C102", "Total_Classes": 38, "Attended_Classes": 34},
  {"Student_ID": "S103", "Student_Name": "Kavin Raj", "Department": "IT", "Course_ID": "C101", "Total_Classes": 40, "Attended_Classes": 39},
  {"Student_ID": "S103", "Student_Name": "Kavin Raj", "Department": "IT", "Course_ID": "C103", "Total_Classes": 36, "Attended_Classes": 32},
  {"Student_ID": "S104", "Student_Name": "Meena Devi", "Department": "ECE", "Course_ID": "C101", "Total_Classes": 40, "Attended_Classes": 27},
  {"Student_ID": "S104", "Student_Name": "Meena Devi", "Department": "ECE", "Course_ID": "C103", "Total_Classes": 36, "Attended_Classes": 30},
  {"Student_ID": "S105", "Student_Name": "Rahul Das", "Department": "CSE", "Course_ID": "C102", "Total_Classes": 38, "Attended_Classes": 28},
  {"Student_ID": "S105", "Student_Name": "Rahul Das", "Department": "CSE", "Course_ID": "C103", "Total_Classes": 36, "Attended_Classes": 33},
  {"Student_ID": "S106", "Student_Name": "Nithya Rao", "Department": "ECE", "Course_ID": "C101", "Total_Classes": 40, "Attended_Classes": 37},
  {"Student_ID": "S106", "Student_Name": "Nithya Rao", "Department": "ECE", "Course_ID": "C102", "Total_Classes": 38, "Attended_Classes": 36}
])
db.student_attendance.countDocuments({})
db.student_attendance.find()

// FIND (equal) : IT department
db.student_attendance.find({ Department: "IT" })

// FIND ($expr + $divide) : attendance below 75%
db.student_attendance.find({ $expr: { $lt: [ { $divide: ["$Attended_Classes", "$Total_Classes"] }, 0.75 ] } })

// FIND + SORT + PROJECTION : by attended classes
db.student_attendance.find({}, { _id: 0, Student_Name: 1, Course_ID: 1, Attended_Classes: 1 }).sort({ Attended_Classes: -1 })

// COUNT + DISTINCT
db.student_attendance.countDocuments({ Course_ID: "C101" })
db.student_attendance.distinct("Student_Name")

// AGGREGATE ($project + percentage) : attendance % of each record
db.student_attendance.aggregate([
  { $project: { _id: 0, Student_Name: 1, Course_ID: 1, pct: { $multiply: [ { $divide: ["$Attended_Classes", "$Total_Classes"] }, 100 ] } } }
])

// AGGREGATE (GROUP + SUM) : overall attendance per student
db.student_attendance.aggregate([
  { $group: { _id: "$Student_Name", attended: { $sum: "$Attended_Classes" }, total: { $sum: "$Total_Classes" } } },
  { $project: { attended: 1, total: 1, pct: { $multiply: [ { $divide: ["$attended", "$total"] }, 100 ] } } },
  { $sort: { pct: -1 } }
])

// AGGREGATE (GROUP + AVG) : average attended per department
db.student_attendance.aggregate([
  { $group: { _id: "$Department", avgAttended: { $avg: "$Attended_Classes" }, records: { $sum: 1 } } }
])

// AGGREGATE (GROUP + COUNT) : students per course
db.student_attendance.aggregate([
  { $group: { _id: "$Course_ID", students: { $sum: 1 } } }
])

// UPDATE / DELETE
db.student_attendance.updateOne({ Student_ID: "S104", Course_ID: "C101" }, { $set: { Attended_Classes: 30 } })
db.student_attendance.updateMany({ Course_ID: "C101" }, { $inc: { Total_Classes: 1, Attended_Classes: 1 } })
db.student_attendance.deleteMany({ Student_ID: "S106" })
db.student_attendance.find()
