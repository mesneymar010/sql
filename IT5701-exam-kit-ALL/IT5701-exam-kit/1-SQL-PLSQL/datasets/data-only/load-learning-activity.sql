-- DATASET : learning_activity   (from learning_activity.csv)
-- Columns : activity_id, student_id, course_id, activity_type, time_spent_minutes, completion_percentage, quiz_score
-- Run     : @"C:\path\load-learning-activity.sql"

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

SELECT * FROM learning_activity;
