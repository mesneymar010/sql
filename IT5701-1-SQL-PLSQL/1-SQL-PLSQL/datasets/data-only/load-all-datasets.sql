-- Loads ALL 9 exam dataset tables
-- Run:  @"C:\path\load-all-datasets.sql"

-- bank_transactions
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE bank_transactions CASCADE CONSTRAINTS;

CREATE TABLE bank_transactions (
  transaction_id            VARCHAR2(20),
  customer_id               VARCHAR2(20),
  account_type              VARCHAR2(20),
  transaction_type          VARCHAR2(20),
  amount                    NUMBER(12),
  branch                    VARCHAR2(20),
  transaction_date          DATE,
  PRIMARY KEY (transaction_id)
);

INSERT INTO bank_transactions VALUES ('T001', 'CU201', 'Savings', 'Deposit', 5000, 'Chennai', TO_DATE('2026-10-01','YYYY-MM-DD'));
INSERT INTO bank_transactions VALUES ('T002', 'CU202', 'Current', 'Withdrawal', 1800, 'Coimbatore', TO_DATE('2026-10-01','YYYY-MM-DD'));
INSERT INTO bank_transactions VALUES ('T003', 'CU201', 'Savings', 'Withdrawal', 750, 'Chennai', TO_DATE('2026-10-02','YYYY-MM-DD'));
INSERT INTO bank_transactions VALUES ('T004', 'CU203', 'Savings', 'Deposit', 12000, 'Madurai', TO_DATE('2026-10-02','YYYY-MM-DD'));
INSERT INTO bank_transactions VALUES ('T005', 'CU204', 'Current', 'Deposit', 8500, 'Trichy', TO_DATE('2026-10-03','YYYY-MM-DD'));
INSERT INTO bank_transactions VALUES ('T006', 'CU205', 'Savings', 'Withdrawal', 2200, 'Salem', TO_DATE('2026-10-03','YYYY-MM-DD'));
INSERT INTO bank_transactions VALUES ('T007', 'CU202', 'Current', 'Deposit', 3000, 'Coimbatore', TO_DATE('2026-10-04','YYYY-MM-DD'));
INSERT INTO bank_transactions VALUES ('T008', 'CU206', 'Savings', 'Deposit', 6400, 'Chennai', TO_DATE('2026-10-04','YYYY-MM-DD'));
INSERT INTO bank_transactions VALUES ('T009', 'CU203', 'Savings', 'Withdrawal', 1500, 'Madurai', TO_DATE('2026-10-05','YYYY-MM-DD'));
INSERT INTO bank_transactions VALUES ('T010', 'CU207', 'Current', 'Deposit', 10000, 'Trichy', TO_DATE('2026-10-05','YYYY-MM-DD'));
COMMIT;

-- learning_activity
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE learning_activity CASCADE CONSTRAINTS;

CREATE TABLE learning_activity (
  activity_id               VARCHAR2(20),
  student_id                VARCHAR2(20),
  course_id                 VARCHAR2(20),
  activity_type             VARCHAR2(20),
  time_spent_minutes        NUMBER(12),
  completion_percentage     NUMBER(12),
  quiz_score                NUMBER(12),
  PRIMARY KEY (activity_id)
);

INSERT INTO learning_activity VALUES ('A001', 'S101', 'CR101', 'Video', 35, 100, 88);
INSERT INTO learning_activity VALUES ('A002', 'S101', 'CR102', 'Quiz', 20, 80, 76);
INSERT INTO learning_activity VALUES ('A003', 'S102', 'CR101', 'Video', 45, 100, 92);
INSERT INTO learning_activity VALUES ('A004', 'S102', 'CR103', 'Quiz', 25, 70, 68);
INSERT INTO learning_activity VALUES ('A005', 'S103', 'CR102', 'Reading', 30, 90, 84);
INSERT INTO learning_activity VALUES ('A006', 'S103', 'CR103', 'Quiz', 18, 100, 95);
INSERT INTO learning_activity VALUES ('A007', 'S104', 'CR101', 'Video', 28, 60, 72);
INSERT INTO learning_activity VALUES ('A008', 'S104', 'CR102', 'Quiz', 22, 85, 81);
INSERT INTO learning_activity VALUES ('A009', 'S105', 'CR103', 'Reading', 40, 100, 89);
INSERT INTO learning_activity VALUES ('A010', 'S105', 'CR101', 'Quiz', 15, 75, 70);
INSERT INTO learning_activity VALUES ('A011', 'S106', 'CR102', 'Video', 50, 100, 96);
INSERT INTO learning_activity VALUES ('A012', 'S106', 'CR103', 'Quiz', 24, 90, 87);
COMMIT;

-- library_transactions
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE library_transactions CASCADE CONSTRAINTS;

CREATE TABLE library_transactions (
  transaction_id            VARCHAR2(20),
  member_id                 VARCHAR2(20),
  book_id                   VARCHAR2(20),
  category                  VARCHAR2(20),
  issue_date                DATE,
  return_date               DATE,
  fine_amount               NUMBER(12),
  PRIMARY KEY (transaction_id)
);

INSERT INTO library_transactions VALUES ('L001', 'MB101', 'B101', 'Computer Science', TO_DATE('2026-09-01','YYYY-MM-DD'), TO_DATE('2026-09-10','YYYY-MM-DD'), 0);
INSERT INTO library_transactions VALUES ('L002', 'MB102', 'B102', 'Literature', TO_DATE('2026-09-02','YYYY-MM-DD'), TO_DATE('2026-09-15','YYYY-MM-DD'), 10);
INSERT INTO library_transactions VALUES ('L003', 'MB101', 'B103', 'Data Science', TO_DATE('2026-09-05','YYYY-MM-DD'), TO_DATE('2026-09-20','YYYY-MM-DD'), 15);
INSERT INTO library_transactions VALUES ('L004', 'MB103', 'B101', 'Computer Science', TO_DATE('2026-09-07','YYYY-MM-DD'), TO_DATE('2026-09-16','YYYY-MM-DD'), 0);
INSERT INTO library_transactions VALUES ('L005', 'MB104', 'B104', 'Mathematics', TO_DATE('2026-09-08','YYYY-MM-DD'), TO_DATE('2026-09-25','YYYY-MM-DD'), 20);
INSERT INTO library_transactions VALUES ('L006', 'MB102', 'B105', 'Data Science', TO_DATE('2026-09-10','YYYY-MM-DD'), TO_DATE('2026-09-19','YYYY-MM-DD'), 0);
INSERT INTO library_transactions VALUES ('L007', 'MB105', 'B102', 'Literature', TO_DATE('2026-09-11','YYYY-MM-DD'), TO_DATE('2026-09-22','YYYY-MM-DD'), 5);
INSERT INTO library_transactions VALUES ('L008', 'MB103', 'B106', 'History', TO_DATE('2026-09-12','YYYY-MM-DD'), TO_DATE('2026-09-28','YYYY-MM-DD'), 12);
INSERT INTO library_transactions VALUES ('L009', 'MB101', 'B105', 'Data Science', TO_DATE('2026-09-15','YYYY-MM-DD'), TO_DATE('2026-09-25','YYYY-MM-DD'), 0);
INSERT INTO library_transactions VALUES ('L010', 'MB106', 'B103', 'Data Science', TO_DATE('2026-09-18','YYYY-MM-DD'), TO_DATE('2026-09-29','YYYY-MM-DD'), 8);
COMMIT;

-- medical_records
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE medical_records CASCADE CONSTRAINTS;

CREATE TABLE medical_records (
  patient_id                VARCHAR2(20),
  age                       NUMBER(12),
  gender                    VARCHAR2(20),
  diagnosis                 VARCHAR2(20),
  blood_sugar               NUMBER(12),
  blood_pressure            VARCHAR2(20),
  doctor_specialization     VARCHAR2(20),
  PRIMARY KEY (patient_id)
);

INSERT INTO medical_records VALUES ('P101', 45, 'Female', 'Diabetes', 165, '140/90', 'Endocrinology');
INSERT INTO medical_records VALUES ('P102', 52, 'Male', 'Hypertension', 110, '150/95', 'Cardiology');
INSERT INTO medical_records VALUES ('P103', 38, 'Female', 'Diabetes', 145, '130/85', 'Endocrinology');
INSERT INTO medical_records VALUES ('P104', 61, 'Male', 'Hypertension', 120, '160/100', 'Cardiology');
INSERT INTO medical_records VALUES ('P105', 29, 'Female', 'General Checkup', 95, '120/80', 'General Medicine');
INSERT INTO medical_records VALUES ('P106', 55, 'Male', 'Diabetes', 180, '145/95', 'Endocrinology');
INSERT INTO medical_records VALUES ('P107', 47, 'Female', 'Hypertension', 105, '135/90', 'Cardiology');
INSERT INTO medical_records VALUES ('P108', 34, 'Male', 'General Checkup', 90, '118/78', 'General Medicine');
INSERT INTO medical_records VALUES ('P109', 63, 'Female', 'Diabetes', 172, '150/92', 'Endocrinology');
INSERT INTO medical_records VALUES ('P110', 41, 'Male', 'General Checkup', 98, '122/82', 'General Medicine');
COMMIT;

-- pharmacy_inventory
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE pharmacy_inventory CASCADE CONSTRAINTS;

CREATE TABLE pharmacy_inventory (
  medicine_id               VARCHAR2(20),
  medicine_name             VARCHAR2(20),
  category                  VARCHAR2(20),
  supplier_id               VARCHAR2(20),
  unit_price                NUMBER(12,2),
  stock_quantity            NUMBER(12),
  reorder_level             NUMBER(12),
  PRIMARY KEY (medicine_id)
);

INSERT INTO pharmacy_inventory VALUES ('M101', 'Paracetamol', 'Analgesic', 'SUP01', 2.5, 500, 100);
INSERT INTO pharmacy_inventory VALUES ('M102', 'Amoxicillin', 'Antibiotic', 'SUP02', 8.0, 75, 100);
INSERT INTO pharmacy_inventory VALUES ('M103', 'Cetirizine', 'Antihistamine', 'SUP01', 3.5, 180, 50);
INSERT INTO pharmacy_inventory VALUES ('M104', 'Metformin', 'Antidiabetic', 'SUP03', 6.0, 90, 120);
INSERT INTO pharmacy_inventory VALUES ('M105', 'Amlodipine', 'Antihypertensive', 'SUP02', 4.5, 45, 60);
INSERT INTO pharmacy_inventory VALUES ('M106', 'Omeprazole', 'Gastrointestinal', 'SUP04', 5.0, 130, 80);
INSERT INTO pharmacy_inventory VALUES ('M107', 'Ibuprofen', 'Analgesic', 'SUP01', 3.0, 40, 75);
INSERT INTO pharmacy_inventory VALUES ('M108', 'Azithromycin', 'Antibiotic', 'SUP03', 12.0, 55, 70);
INSERT INTO pharmacy_inventory VALUES ('M109', 'ORS Sachet', 'Electrolyte', 'SUP04', 1.5, 300, 100);
INSERT INTO pharmacy_inventory VALUES ('M110', 'Vitamin C', 'Supplement', 'SUP02', 2.0, 65, 80);
COMMIT;

-- retail_sales
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE retail_sales CASCADE CONSTRAINTS;

CREATE TABLE retail_sales (
  order_id                  VARCHAR2(20),
  customer_id               VARCHAR2(20),
  product_id                VARCHAR2(20),
  category                  VARCHAR2(20),
  quantity                  NUMBER(12),
  unit_price                NUMBER(12),
  region                    VARCHAR2(20),
  PRIMARY KEY (order_id)
);

INSERT INTO retail_sales VALUES ('O1001', 'CU101', 'PR101', 'Electronics', 2, 15000, 'Chennai');
INSERT INTO retail_sales VALUES ('O1002', 'CU102', 'PR102', 'Clothing', 3, 1200, 'Coimbatore');
INSERT INTO retail_sales VALUES ('O1003', 'CU103', 'PR103', 'Grocery', 10, 150, 'Madurai');
INSERT INTO retail_sales VALUES ('O1004', 'CU101', 'PR104', 'Electronics', 1, 22000, 'Chennai');
INSERT INTO retail_sales VALUES ('O1005', 'CU104', 'PR105', 'Clothing', 2, 1800, 'Trichy');
INSERT INTO retail_sales VALUES ('O1006', 'CU105', 'PR106', 'Home', 4, 2500, 'Salem');
INSERT INTO retail_sales VALUES ('O1007', 'CU102', 'PR101', 'Electronics', 1, 15000, 'Coimbatore');
INSERT INTO retail_sales VALUES ('O1008', 'CU106', 'PR103', 'Grocery', 8, 150, 'Chennai');
INSERT INTO retail_sales VALUES ('O1009', 'CU107', 'PR107', 'Home', 2, 4200, 'Madurai');
INSERT INTO retail_sales VALUES ('O1010', 'CU103', 'PR105', 'Clothing', 1, 1800, 'Madurai');
INSERT INTO retail_sales VALUES ('O1011', 'CU108', 'PR104', 'Electronics', 1, 22000, 'Trichy');
INSERT INTO retail_sales VALUES ('O1012', 'CU105', 'PR106', 'Home', 2, 2500, 'Salem');
COMMIT;

-- shipment_records
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE shipment_records CASCADE CONSTRAINTS;

CREATE TABLE shipment_records (
  shipment_id               VARCHAR2(20),
  customer_id               VARCHAR2(20),
  source_city               VARCHAR2(20),
  destination_city          VARCHAR2(20),
  transport_mode            VARCHAR2(20),
  weight_kg                 NUMBER(12),
  shipping_cost             NUMBER(12),
  delivery_status           VARCHAR2(20),
  PRIMARY KEY (shipment_id)
);

INSERT INTO shipment_records VALUES ('SH001', 'CU301', 'Chennai', 'Bengaluru', 'Road', 120, 4500, 'Delivered');
INSERT INTO shipment_records VALUES ('SH002', 'CU302', 'Coimbatore', 'Chennai', 'Rail', 350, 2800, 'In Transit');
INSERT INTO shipment_records VALUES ('SH003', 'CU303', 'Madurai', 'Trichy', 'Road', 80, 1600, 'Delivered');
INSERT INTO shipment_records VALUES ('SH004', 'CU301', 'Chennai', 'Hyderabad', 'Air', 45, 6200, 'Delayed');
INSERT INTO shipment_records VALUES ('SH005', 'CU304', 'Salem', 'Bengaluru', 'Road', 210, 3900, 'Delivered');
INSERT INTO shipment_records VALUES ('SH006', 'CU305', 'Trichy', 'Chennai', 'Rail', 400, 3000, 'In Transit');
INSERT INTO shipment_records VALUES ('SH007', 'CU306', 'Erode', 'Madurai', 'Road', 65, 1400, 'Delivered');
INSERT INTO shipment_records VALUES ('SH008', 'CU302', 'Coimbatore', 'Hyderabad', 'Air', 30, 5100, 'Delivered');
INSERT INTO shipment_records VALUES ('SH009', 'CU307', 'Chennai', 'Mumbai', 'Road', 180, 4700, 'Delayed');
INSERT INTO shipment_records VALUES ('SH010', 'CU308', 'Madurai', 'Bengaluru', 'Rail', 320, 2600, 'Delivered');
COMMIT;

-- student_attendance
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE student_attendance CASCADE CONSTRAINTS;

CREATE TABLE student_attendance (
  student_id                VARCHAR2(20),
  student_name              VARCHAR2(20),
  department                VARCHAR2(20),
  course_id                 VARCHAR2(20),
  total_classes             NUMBER(12),
  attended_classes          NUMBER(12),
  PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_attendance VALUES ('S101', 'Arun Kumar', 'IT', 'C101', 40, 36);
INSERT INTO student_attendance VALUES ('S101', 'Arun Kumar', 'IT', 'C102', 38, 31);
INSERT INTO student_attendance VALUES ('S102', 'Priya Sharma', 'CSE', 'C101', 40, 30);
INSERT INTO student_attendance VALUES ('S102', 'Priya Sharma', 'CSE', 'C102', 38, 34);
INSERT INTO student_attendance VALUES ('S103', 'Kavin Raj', 'IT', 'C101', 40, 39);
INSERT INTO student_attendance VALUES ('S103', 'Kavin Raj', 'IT', 'C103', 36, 32);
INSERT INTO student_attendance VALUES ('S104', 'Meena Devi', 'ECE', 'C101', 40, 27);
INSERT INTO student_attendance VALUES ('S104', 'Meena Devi', 'ECE', 'C103', 36, 30);
INSERT INTO student_attendance VALUES ('S105', 'Rahul Das', 'CSE', 'C102', 38, 28);
INSERT INTO student_attendance VALUES ('S105', 'Rahul Das', 'CSE', 'C103', 36, 33);
INSERT INTO student_attendance VALUES ('S106', 'Nithya Rao', 'ECE', 'C101', 40, 37);
INSERT INTO student_attendance VALUES ('S106', 'Nithya Rao', 'ECE', 'C102', 38, 36);
COMMIT;

-- web_clicks
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE web_clicks CASCADE CONSTRAINTS;

CREATE TABLE web_clicks (
  click_id                  VARCHAR2(20),
  user_id                   VARCHAR2(20),
  country                   VARCHAR2(20),
  device_type               VARCHAR2(20),
  page_category             VARCHAR2(20),
  click_time                DATE,
  session_id                VARCHAR2(20),
  duration_seconds          NUMBER(12),
  PRIMARY KEY (click_id)
);

INSERT INTO web_clicks VALUES ('C001', 'U101', 'India', 'Mobile', 'Home', TO_DATE('2026-10-01 09:00:00','YYYY-MM-DD HH24:MI:SS'), 'S101', 25);
INSERT INTO web_clicks VALUES ('C002', 'U101', 'India', 'Mobile', 'Products', TO_DATE('2026-10-01 09:01:10','YYYY-MM-DD HH24:MI:SS'), 'S101', 60);
INSERT INTO web_clicks VALUES ('C003', 'U102', 'USA', 'Desktop', 'Home', TO_DATE('2026-10-01 10:00:00','YYYY-MM-DD HH24:MI:SS'), 'S102', 35);
INSERT INTO web_clicks VALUES ('C004', 'U102', 'USA', 'Desktop', 'Checkout', TO_DATE('2026-10-01 10:02:00','YYYY-MM-DD HH24:MI:SS'), 'S102', 90);
INSERT INTO web_clicks VALUES ('C005', 'U103', 'India', 'Tablet', 'Products', TO_DATE('2026-10-01 11:10:00','YYYY-MM-DD HH24:MI:SS'), 'S103', 45);
INSERT INTO web_clicks VALUES ('C006', 'U104', 'UK', 'Mobile', 'Home', TO_DATE('2026-10-01 12:00:00','YYYY-MM-DD HH24:MI:SS'), 'S104', 20);
INSERT INTO web_clicks VALUES ('C007', 'U104', 'UK', 'Mobile', 'Products', TO_DATE('2026-10-01 12:01:00','YYYY-MM-DD HH24:MI:SS'), 'S104', 75);
INSERT INTO web_clicks VALUES ('C008', 'U105', 'India', 'Desktop', 'Checkout', TO_DATE('2026-10-01 13:15:00','YYYY-MM-DD HH24:MI:SS'), 'S105', 120);
INSERT INTO web_clicks VALUES ('C009', 'U106', 'USA', 'Mobile', 'Products', TO_DATE('2026-10-01 14:20:00','YYYY-MM-DD HH24:MI:SS'), 'S106', 55);
INSERT INTO web_clicks VALUES ('C010', 'U107', 'UK', 'Desktop', 'Home', TO_DATE('2026-10-01 15:00:00','YYYY-MM-DD HH24:MI:SS'), 'S107', 40);
INSERT INTO web_clicks VALUES ('C011', 'U108', 'India', 'Mobile', 'Blog', TO_DATE('2026-10-02 09:30:00','YYYY-MM-DD HH24:MI:SS'), 'S108', 32);
INSERT INTO web_clicks VALUES ('C012', 'U103', 'India', 'Tablet', 'Checkout', TO_DATE('2026-10-02 11:12:00','YYYY-MM-DD HH24:MI:SS'), 'S103', 85);
COMMIT;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

SELECT table_name FROM user_tables;
