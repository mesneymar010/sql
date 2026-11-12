-- DATASET : medical_records   (from medical_records.csv)
-- Columns : patient_id, age, gender, diagnosis, blood_sugar, blood_pressure, doctor_specialization
-- Run     : @"C:\path\load-medical-records.sql"

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
