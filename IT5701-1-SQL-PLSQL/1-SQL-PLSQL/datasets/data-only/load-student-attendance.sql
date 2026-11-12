-- DATASET : student_attendance   (from student_attendance.csv)
-- Columns : student_id, student_name, department, course_id, total_classes, attended_classes
-- Run     : @"C:\path\load-student-attendance.sql"

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

SELECT * FROM student_attendance;
