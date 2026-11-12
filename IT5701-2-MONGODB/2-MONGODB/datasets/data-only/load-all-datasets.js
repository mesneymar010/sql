// Loads ALL 9 exam datasets into database examdb
// Paste into mongosh / mongo

use examdb

// bank_transactions
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

// learning_activity
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

// library_transactions
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

// medical_records
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

// pharmacy_inventory
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

// retail_sales
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

// shipment_records
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

// student_attendance
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

// web_clicks
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

show collections
