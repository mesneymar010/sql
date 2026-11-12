-- DATASET : student_attendance   (from student_attendance.csv)
-- Columns : student_id, student_name, department, course_id, total_classes, attended_classes
-- Run     : @"C:\path\sql-student-attendance.sql"

SET SERVEROUTPUT ON SIZE 1000000
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

------------------------------------------------------------
-- SQL QUERIES
------------------------------------------------------------
-- CALCULATED COLUMN + ROUND : attendance percentage
SELECT student_id, student_name, course_id,
       ROUND(attended_classes * 100 / total_classes, 2) attendance_pct
FROM student_attendance;

-- WHERE on CALCULATION : below 75% attendance
SELECT student_id, student_name, course_id,
       ROUND(attended_classes * 100 / total_classes, 2) attendance_pct
FROM student_attendance
WHERE attended_classes * 100 / total_classes < 75;

-- WHERE : IT department
SELECT * FROM student_attendance WHERE department = 'IT';

-- GROUP BY : overall attendance per student
SELECT student_id, student_name,
       SUM(attended_classes) attended, SUM(total_classes) total,
       ROUND(SUM(attended_classes) * 100 / SUM(total_classes), 2) overall_pct
FROM student_attendance
GROUP BY student_id, student_name
ORDER BY overall_pct DESC;

-- GROUP BY + AVG : average attendance per department
SELECT department, ROUND(AVG(attended_classes * 100 / total_classes), 2) avg_pct
FROM student_attendance
GROUP BY department;

-- GROUP BY + COUNT : students per course
SELECT course_id, COUNT(*) no_of_students
FROM student_attendance
GROUP BY course_id;

-- HAVING : departments with average attendance above 85
SELECT department, AVG(attended_classes * 100 / total_classes) FROM student_attendance
GROUP BY department
HAVING AVG(attended_classes * 100 / total_classes) > 85;

-- SUBQUERY : students with any course below 75%
SELECT DISTINCT student_id, student_name FROM student_attendance
WHERE student_id IN (SELECT student_id FROM student_attendance
                     WHERE attended_classes * 100 / total_classes < 75);

-- CASE : eligibility
SELECT student_id, course_id, ROUND(attended_classes * 100 / total_classes, 2) pct,
       CASE WHEN attended_classes * 100 / total_classes >= 75 THEN 'Eligible'
            WHEN attended_classes * 100 / total_classes >= 65 THEN 'Condonation'
            ELSE 'Detained' END status
FROM student_attendance;

------------------------------------------------------------
-- PROCEDURE (IN, OUT) : overall attendance % of a student
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE att_student_pct(p_sid IN VARCHAR2, p_pct OUT NUMBER) IS
BEGIN
  SELECT ROUND(SUM(attended_classes) * 100 / SUM(total_classes), 2) INTO p_pct
  FROM student_attendance
  WHERE student_id = p_sid;
  IF p_pct IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No records for ' || p_sid);
  END IF;
END;
/

DECLARE
  p NUMBER;
BEGIN
  att_student_pct('S104', p);
  DBMS_OUTPUT.PUT_LINE('Attendance of S104: ' || p || '%');
END;
/

------------------------------------------------------------
-- FUNCTION : eligibility for a percentage
------------------------------------------------------------
CREATE OR REPLACE FUNCTION att_status(p_pct IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  IF p_pct >= 75 THEN
    RETURN 'Eligible';
  ELSIF p_pct >= 65 THEN
    RETURN 'Condonation';
  ELSE
    RETURN 'Detained';
  END IF;
END;
/

SELECT student_id, course_id, ROUND(attended_classes * 100 / total_classes, 2) pct,
       att_status(attended_classes * 100 / total_classes) status
FROM student_attendance;

------------------------------------------------------------
-- TRIGGER (BEFORE INSERT) : attended can not exceed total
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_att_check
BEFORE INSERT OR UPDATE ON student_attendance
FOR EACH ROW
BEGIN
  IF :NEW.attended_classes > :NEW.total_classes THEN
    RAISE_APPLICATION_ERROR(-20001, 'Attended classes can not exceed total classes');
  END IF;
  IF :NEW.attended_classes < 0 OR :NEW.total_classes <= 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Invalid class count');
  END IF;
END;
/

INSERT INTO student_attendance VALUES ('S107','Vijay','IT','C101',40,45);
INSERT INTO student_attendance VALUES ('S107','Vijay','IT','C102',38,35);
SELECT * FROM student_attendance WHERE student_id = 'S107';
ROLLBACK;

------------------------------------------------------------
-- CURSOR + USER EXCEPTION : attendance shortage (< 75%)
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT * FROM student_attendance;
  shortage EXCEPTION;
  v_pct NUMBER;
BEGIN
  FOR r IN c LOOP
    BEGIN
      v_pct := ROUND(r.attended_classes * 100 / r.total_classes, 2);
      IF v_pct < 75 THEN
        RAISE shortage;
      END IF;
      DBMS_OUTPUT.PUT_LINE(r.student_name || '  ' || r.course_id || '  ' || v_pct || '%');
    EXCEPTION
      WHEN shortage THEN
        DBMS_OUTPUT.PUT_LINE(r.student_name || '  ' || r.course_id || '  ' || v_pct || '%  <-- SHORTAGE');
    END;
  END LOOP;
END;
/

------------------------------------------------------------
-- IMPLICIT CURSOR : add one class for C101
------------------------------------------------------------
BEGIN
  UPDATE student_attendance SET total_classes = total_classes + 1, attended_classes = attended_classes + 1
  WHERE course_id = 'C101';
  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rows updated');
  ROLLBACK;
END;
/
