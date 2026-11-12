// DATASET : medical_records   (from medical_records.csv)
// Fields  : Patient_ID, Age, Gender, Diagnosis, Blood_Sugar, Blood_Pressure, Doctor_Specialization
// Start shell: mongosh  (or mongo)  -> paste block by block

use examdb

// LOAD DATA
db.medical_records.drop()
db.medical_records.insertMany([
  {"Patient_ID": "P101", "Age": 45, "Gender": "Female", "Diagnosis": "Diabetes", "Blood_Sugar": 165, "Blood_Pressure": "140/90", "Doctor_Specialization": "Endocrinology"},
  {"Patient_ID": "P102", "Age": 52, "Gender": "Male", "Diagnosis": "Hypertension", "Blood_Sugar": 110, "Blood_Pressure": "150/95", "Doctor_Specialization": "Cardiology"},
  {"Patient_ID": "P103", "Age": 38, "Gender": "Female", "Diagnosis": "Diabetes", "Blood_Sugar": 145, "Blood_Pressure": "130/85", "Doctor_Specialization": "Endocrinology"},
  {"Patient_ID": "P104", "Age": 61, "Gender": "Male", "Diagnosis": "Hypertension", "Blood_Sugar": 120, "Blood_Pressure": "160/100", "Doctor_Specialization": "Cardiology"},
  {"Patient_ID": "P105", "Age": 29, "Gender": "Female", "Diagnosis": "General Checkup", "Blood_Sugar": 95, "Blood_Pressure": "120/80", "Doctor_Specialization": "General Medicine"},
  {"Patient_ID": "P106", "Age": 55, "Gender": "Male", "Diagnosis": "Diabetes", "Blood_Sugar": 180, "Blood_Pressure": "145/95", "Doctor_Specialization": "Endocrinology"},
  {"Patient_ID": "P107", "Age": 47, "Gender": "Female", "Diagnosis": "Hypertension", "Blood_Sugar": 105, "Blood_Pressure": "135/90", "Doctor_Specialization": "Cardiology"},
  {"Patient_ID": "P108", "Age": 34, "Gender": "Male", "Diagnosis": "General Checkup", "Blood_Sugar": 90, "Blood_Pressure": "118/78", "Doctor_Specialization": "General Medicine"},
  {"Patient_ID": "P109", "Age": 63, "Gender": "Female", "Diagnosis": "Diabetes", "Blood_Sugar": 172, "Blood_Pressure": "150/92", "Doctor_Specialization": "Endocrinology"},
  {"Patient_ID": "P110", "Age": 41, "Gender": "Male", "Diagnosis": "General Checkup", "Blood_Sugar": 98, "Blood_Pressure": "122/82", "Doctor_Specialization": "General Medicine"}
])
db.medical_records.countDocuments({})
db.medical_records.find()

// FIND (AND + $gt) : diabetic with sugar above 150
db.medical_records.find({ Diagnosis: "Diabetes", Blood_Sugar: { $gt: 150 } })

// FIND (range) + SORT + PROJECTION : age 40-55
db.medical_records.find({ Age: { $gte: 40, $lte: 55 } }, { _id: 0, Patient_ID: 1, Age: 1, Diagnosis: 1 }).sort({ Age: -1 })

// FIND ($ne) : not general checkup
db.medical_records.find({ Diagnosis: { $ne: "General Checkup" } })

// COUNT + DISTINCT
db.medical_records.countDocuments({ Gender: "Female" })
db.medical_records.distinct("Diagnosis")

// AGGREGATE (GROUP + COUNT) : patients per diagnosis
db.medical_records.aggregate([
  { $group: { _id: "$Diagnosis", patients: { $sum: 1 } } }
])

// AGGREGATE (GROUP + AVG) : average age per gender
db.medical_records.aggregate([
  { $group: { _id: "$Gender", avgAge: { $avg: "$Age" } } }
])

// AGGREGATE (GROUP + AVG/MAX) : sugar per specialization
db.medical_records.aggregate([
  { $group: { _id: "$Doctor_Specialization", avgSugar: { $avg: "$Blood_Sugar" }, maxSugar: { $max: "$Blood_Sugar" } } },
  { $sort: { avgSugar: -1 } }
])

// AGGREGATE (MATCH + GROUP) : average sugar of patients above 50
db.medical_records.aggregate([
  { $match: { Age: { $gt: 50 } } },
  { $group: { _id: "$Diagnosis", avgSugar: { $avg: "$Blood_Sugar" }, count: { $sum: 1 } } }
])

// UPDATE / DELETE
db.medical_records.updateOne({ Patient_ID: "P105" }, { $set: { Blood_Sugar: 100 } })
db.medical_records.updateMany({ Diagnosis: "Diabetes" }, { $set: { Follow_Up: "Monthly" } })
db.medical_records.deleteOne({ Patient_ID: "P110" })
db.medical_records.find()
