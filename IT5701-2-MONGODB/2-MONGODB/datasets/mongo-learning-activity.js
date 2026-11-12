// DATASET : learning_activity   (from learning_activity.csv)
// Fields  : Activity_ID, Student_ID, Course_ID, Activity_Type, Time_Spent_Minutes, Completion_Percentage, Quiz_Score
// Start shell: mongosh  (or mongo)  -> paste block by block

use examdb

// LOAD DATA
db.learning_activity.drop()
db.learning_activity.insertMany([
  {"Activity_ID": "A001", "Student_ID": "S101", "Course_ID": "CR101", "Activity_Type": "Video", "Time_Spent_Minutes": 35, "Completion_Percentage": 100, "Quiz_Score": 88},
  {"Activity_ID": "A002", "Student_ID": "S101", "Course_ID": "CR102", "Activity_Type": "Quiz", "Time_Spent_Minutes": 20, "Completion_Percentage": 80, "Quiz_Score": 76},
  {"Activity_ID": "A003", "Student_ID": "S102", "Course_ID": "CR101", "Activity_Type": "Video", "Time_Spent_Minutes": 45, "Completion_Percentage": 100, "Quiz_Score": 92},
  {"Activity_ID": "A004", "Student_ID": "S102", "Course_ID": "CR103", "Activity_Type": "Quiz", "Time_Spent_Minutes": 25, "Completion_Percentage": 70, "Quiz_Score": 68},
  {"Activity_ID": "A005", "Student_ID": "S103", "Course_ID": "CR102", "Activity_Type": "Reading", "Time_Spent_Minutes": 30, "Completion_Percentage": 90, "Quiz_Score": 84},
  {"Activity_ID": "A006", "Student_ID": "S103", "Course_ID": "CR103", "Activity_Type": "Quiz", "Time_Spent_Minutes": 18, "Completion_Percentage": 100, "Quiz_Score": 95},
  {"Activity_ID": "A007", "Student_ID": "S104", "Course_ID": "CR101", "Activity_Type": "Video", "Time_Spent_Minutes": 28, "Completion_Percentage": 60, "Quiz_Score": 72},
  {"Activity_ID": "A008", "Student_ID": "S104", "Course_ID": "CR102", "Activity_Type": "Quiz", "Time_Spent_Minutes": 22, "Completion_Percentage": 85, "Quiz_Score": 81},
  {"Activity_ID": "A009", "Student_ID": "S105", "Course_ID": "CR103", "Activity_Type": "Reading", "Time_Spent_Minutes": 40, "Completion_Percentage": 100, "Quiz_Score": 89},
  {"Activity_ID": "A010", "Student_ID": "S105", "Course_ID": "CR101", "Activity_Type": "Quiz", "Time_Spent_Minutes": 15, "Completion_Percentage": 75, "Quiz_Score": 70},
  {"Activity_ID": "A011", "Student_ID": "S106", "Course_ID": "CR102", "Activity_Type": "Video", "Time_Spent_Minutes": 50, "Completion_Percentage": 100, "Quiz_Score": 96},
  {"Activity_ID": "A012", "Student_ID": "S106", "Course_ID": "CR103", "Activity_Type": "Quiz", "Time_Spent_Minutes": 24, "Completion_Percentage": 90, "Quiz_Score": 87}
])
db.learning_activity.countDocuments({})
db.learning_activity.find()

// FIND (equal) : fully completed activities
db.learning_activity.find({ Completion_Percentage: 100 })

// FIND ($gte) + SORT + PROJECTION : quiz score >= 85
db.learning_activity.find({ Quiz_Score: { $gte: 85 } }, { _id: 0, Student_ID: 1, Course_ID: 1, Quiz_Score: 1 }).sort({ Quiz_Score: -1 })

// FIND ($in) : video or reading
db.learning_activity.find({ Activity_Type: { $in: ["Video", "Reading"] } })

// FIND ($or) : low completion or low score
db.learning_activity.find({ $or: [ { Completion_Percentage: { $lt: 80 } }, { Quiz_Score: { $lt: 75 } } ] })

// COUNT + DISTINCT
db.learning_activity.countDocuments({ Activity_Type: "Quiz" })
db.learning_activity.distinct("Course_ID")

// AGGREGATE (GROUP + AVG) : average quiz score per course
db.learning_activity.aggregate([
  { $group: { _id: "$Course_ID", avgScore: { $avg: "$Quiz_Score" }, count: { $sum: 1 } } },
  { $sort: { avgScore: -1 } }
])

// AGGREGATE (GROUP + SUM) : total time per student
db.learning_activity.aggregate([
  { $group: { _id: "$Student_ID", totalMinutes: { $sum: "$Time_Spent_Minutes" } } },
  { $sort: { totalMinutes: -1 } }
])

// AGGREGATE (GROUP + HAVING) : students with average score above 85
db.learning_activity.aggregate([
  { $group: { _id: "$Student_ID", avgScore: { $avg: "$Quiz_Score" } } },
  { $match: { avgScore: { $gt: 85 } } }
])

// AGGREGATE (MATCH + GROUP) : quiz activities per course
db.learning_activity.aggregate([
  { $match: { Activity_Type: "Quiz" } },
  { $group: { _id: "$Course_ID", quizzes: { $sum: 1 }, avgScore: { $avg: "$Quiz_Score" } } }
])

// UPDATE / DELETE
db.learning_activity.updateOne({ Activity_ID: "A004" }, { $set: { Completion_Percentage: 100 } })
db.learning_activity.updateMany({ Quiz_Score: { $lt: 75 } }, { $inc: { Quiz_Score: 5 } })
db.learning_activity.deleteMany({ Completion_Percentage: { $lt: 70 } })
db.learning_activity.find()
