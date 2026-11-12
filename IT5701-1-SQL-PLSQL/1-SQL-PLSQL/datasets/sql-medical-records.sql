-- DATASET : medical_records   (from medical_records.csv)
-- Columns : patient_id, age, gender, diagnosis, blood_sugar, blood_pressure, doctor_specialization
-- Run     : @"C:\path\sql-medical-records.sql"

SET SERVEROUTPUT ON SIZE 1000000
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

SELECT * FROM medical_records;

------------------------------------------------------------
-- SQL QUERIES
------------------------------------------------------------
-- WHERE + AND : diabetic patients with sugar above 150
SELECT * FROM medical_records WHERE diagnosis = 'Diabetes' AND blood_sugar > 150;

-- WHERE + BETWEEN : patients aged 40 to 55
SELECT * FROM medical_records WHERE age BETWEEN 40 AND 55;

-- ORDER BY : oldest first
SELECT patient_id, age, gender, diagnosis FROM medical_records ORDER BY age DESC;

-- GROUP BY + COUNT : patients per diagnosis
SELECT diagnosis, COUNT(*) no_of_patients
FROM medical_records
GROUP BY diagnosis;

-- GROUP BY + AVG : average age per gender
SELECT gender, ROUND(AVG(age),1) avg_age
FROM medical_records
GROUP BY gender;

-- GROUP BY : average sugar per specialization
SELECT doctor_specialization, ROUND(AVG(blood_sugar),1) avg_sugar, MAX(blood_sugar) max_sugar
FROM medical_records
GROUP BY doctor_specialization;

-- HAVING : diagnosis with average sugar above 120
SELECT diagnosis, AVG(blood_sugar) FROM medical_records
GROUP BY diagnosis
HAVING AVG(blood_sugar) > 120;

-- SUBQUERY (AVG) : patients older than average age
SELECT * FROM medical_records
WHERE age > (SELECT AVG(age) FROM medical_records);

-- STRING FUNCTIONS : split blood pressure 140/90 into systolic and diastolic
SELECT patient_id, blood_pressure,
       TO_NUMBER(SUBSTR(blood_pressure, 1, INSTR(blood_pressure,'/') - 1)) systolic,
       TO_NUMBER(SUBSTR(blood_pressure, INSTR(blood_pressure,'/') + 1)) diastolic
FROM medical_records;

-- STRING FUNCTIONS + WHERE : high BP (systolic >= 140)
SELECT * FROM medical_records
WHERE TO_NUMBER(SUBSTR(blood_pressure, 1, INSTR(blood_pressure,'/') - 1)) >= 140;

-- CASE : sugar level
SELECT patient_id, blood_sugar,
       CASE WHEN blood_sugar < 100 THEN 'Normal'
            WHEN blood_sugar <= 125 THEN 'Pre-Diabetic'
            ELSE 'High' END sugar_level
FROM medical_records;

------------------------------------------------------------
-- PROCEDURE (IN, OUT) : number of patients for a diagnosis
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE med_diag_count(p_diag IN VARCHAR2, p_cnt OUT NUMBER) IS
BEGIN
  SELECT COUNT(*) INTO p_cnt
  FROM medical_records
  WHERE diagnosis = p_diag;
  IF p_cnt = 0 THEN
    DBMS_OUTPUT.PUT_LINE('No patients with ' || p_diag);
  END IF;
END;
/

DECLARE
  n NUMBER;
BEGIN
  med_diag_count('Diabetes', n);
  DBMS_OUTPUT.PUT_LINE('Diabetes patients: ' || n);
END;
/

------------------------------------------------------------
-- FUNCTION : sugar status of a patient (SELECT INTO + NO_DATA_FOUND)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION med_sugar_status(p_pid IN VARCHAR2) RETURN VARCHAR2 IS
  v_sugar medical_records.blood_sugar%TYPE;
BEGIN
  SELECT blood_sugar INTO v_sugar FROM medical_records WHERE patient_id = p_pid;
  IF v_sugar < 100 THEN
    RETURN 'Normal';
  ELSIF v_sugar <= 125 THEN
    RETURN 'Pre-Diabetic';
  ELSE
    RETURN 'High';
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'Patient not found';
END;
/

SELECT med_sugar_status('P101') FROM dual;
SELECT med_sugar_status('P999') FROM dual;

------------------------------------------------------------
-- TRIGGER (BEFORE INSERT) : valid age and sugar
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_med_check
BEFORE INSERT OR UPDATE ON medical_records
FOR EACH ROW
BEGIN
  IF :NEW.age <= 0 OR :NEW.age > 120 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Invalid age');
  END IF;
  IF :NEW.blood_sugar <= 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Invalid blood sugar');
  END IF;
END;
/

INSERT INTO medical_records VALUES ('P111',150,'Male','Diabetes',150,'130/85','Endocrinology');
INSERT INTO medical_records VALUES ('P112',50,'Male','Diabetes',150,'130/85','Endocrinology');
SELECT * FROM medical_records WHERE patient_id IN ('P111','P112');
ROLLBACK;

------------------------------------------------------------
-- CURSOR + USER EXCEPTION : alert for sugar above 160
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT * FROM medical_records;
  high_sugar EXCEPTION;
BEGIN
  FOR r IN c LOOP
    BEGIN
      IF r.blood_sugar > 160 THEN
        RAISE high_sugar;
      END IF;
      DBMS_OUTPUT.PUT_LINE(r.patient_id || '  ' || r.diagnosis || '  ' || r.blood_sugar);
    EXCEPTION
      WHEN high_sugar THEN
        DBMS_OUTPUT.PUT_LINE(r.patient_id || '  ' || r.diagnosis || '  ' || r.blood_sugar || '  <-- ALERT HIGH SUGAR');
    END;
  END LOOP;
END;
/

------------------------------------------------------------
-- IMPLICIT CURSOR : SQL%ROWCOUNT
------------------------------------------------------------
BEGIN
  UPDATE medical_records SET doctor_specialization = 'Diabetology' WHERE diagnosis = 'Diabetes';
  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rows updated');
  ROLLBACK;
END;
/
