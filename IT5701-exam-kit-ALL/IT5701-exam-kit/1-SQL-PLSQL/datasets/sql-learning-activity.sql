-- DATASET : learning_activity   (from learning_activity.csv)
-- Columns : activity_id, student_id, course_id, activity_type, time_spent_minutes, completion_percentage, quiz_score
-- Run     : @"C:\path\sql-learning-activity.sql"

SET SERVEROUTPUT ON SIZE 1000000
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

------------------------------------------------------------
-- SQL QUERIES
------------------------------------------------------------
-- WHERE : fully completed activities
SELECT * FROM learning_activity WHERE completion_percentage = 100;

-- WHERE + IN : video or reading activities
SELECT * FROM learning_activity WHERE activity_type IN ('Video','Reading');

-- ORDER BY : highest quiz score first
SELECT student_id, course_id, quiz_score FROM learning_activity ORDER BY quiz_score DESC;

-- GROUP BY + AVG : average quiz score per course
SELECT course_id, ROUND(AVG(quiz_score),2) avg_score, COUNT(*) no_of_activities
FROM learning_activity
GROUP BY course_id;

-- GROUP BY + SUM : total time spent per student
SELECT student_id, SUM(time_spent_minutes) total_minutes
FROM learning_activity
GROUP BY student_id
ORDER BY total_minutes DESC;

-- GROUP BY : count and average time per activity type
SELECT activity_type, COUNT(*), AVG(time_spent_minutes)
FROM learning_activity
GROUP BY activity_type;

-- HAVING : students with average score above 85
SELECT student_id, AVG(quiz_score) FROM learning_activity
GROUP BY student_id
HAVING AVG(quiz_score) > 85;

-- SUBQUERY (AVG) : scores above overall average
SELECT * FROM learning_activity
WHERE quiz_score > (SELECT AVG(quiz_score) FROM learning_activity);

-- CORRELATED SUBQUERY : above the average of their own course
SELECT a.* FROM learning_activity a
WHERE a.quiz_score > (SELECT AVG(b.quiz_score) FROM learning_activity b WHERE b.course_id = a.course_id);

-- CASE : grade from quiz score
SELECT student_id, course_id, quiz_score,
       CASE WHEN quiz_score >= 90 THEN 'A'
            WHEN quiz_score >= 80 THEN 'B'
            WHEN quiz_score >= 70 THEN 'C'
            ELSE 'D' END grade
FROM learning_activity;

-- TOP N (ROWNUM) : top 3 scores
SELECT * FROM (SELECT * FROM learning_activity ORDER BY quiz_score DESC)
WHERE ROWNUM <= 3;

------------------------------------------------------------
-- PROCEDURE (IN, OUT) : average score of a student
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE learn_student_avg(p_sid IN VARCHAR2, p_avg OUT NUMBER) IS
BEGIN
  SELECT ROUND(AVG(quiz_score),2) INTO p_avg
  FROM learning_activity
  WHERE student_id = p_sid;
  IF p_avg IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No activity for ' || p_sid);
  END IF;
END;
/

DECLARE
  a NUMBER;
BEGIN
  learn_student_avg('S101', a);
  DBMS_OUTPUT.PUT_LINE('Average score of S101: ' || a);
END;
/

------------------------------------------------------------
-- FUNCTION : grade for a score
------------------------------------------------------------
CREATE OR REPLACE FUNCTION learn_grade(p_score IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  IF p_score >= 90 THEN
    RETURN 'A';
  ELSIF p_score >= 80 THEN
    RETURN 'B';
  ELSIF p_score >= 70 THEN
    RETURN 'C';
  ELSE
    RETURN 'D';
  END IF;
END;
/

SELECT activity_id, student_id, quiz_score, learn_grade(quiz_score) grade FROM learning_activity;

------------------------------------------------------------
-- TRIGGER (BEFORE INSERT) : score and completion must be 0-100
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_learn_check
BEFORE INSERT OR UPDATE ON learning_activity
FOR EACH ROW
BEGIN
  IF :NEW.quiz_score < 0 OR :NEW.quiz_score > 100 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Quiz score must be between 0 and 100');
  END IF;
  IF :NEW.completion_percentage < 0 OR :NEW.completion_percentage > 100 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Completion must be between 0 and 100');
  END IF;
END;
/

INSERT INTO learning_activity VALUES ('A013','S107','CR101','Quiz',20,100,105);
INSERT INTO learning_activity VALUES ('A014','S107','CR101','Quiz',20,100,78);
SELECT * FROM learning_activity WHERE activity_id IN ('A013','A014');
ROLLBACK;

------------------------------------------------------------
-- CURSOR + USER EXCEPTION : incomplete activities (< 80%)
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT * FROM learning_activity;
  incomplete EXCEPTION;
BEGIN
  FOR r IN c LOOP
    BEGIN
      IF r.completion_percentage < 80 THEN
        RAISE incomplete;
      END IF;
      DBMS_OUTPUT.PUT_LINE(r.student_id || '  ' || r.course_id || '  ' || r.completion_percentage || '%  OK');
    EXCEPTION
      WHEN incomplete THEN
        DBMS_OUTPUT.PUT_LINE(r.student_id || '  ' || r.course_id || '  ' || r.completion_percentage || '%  <-- INCOMPLETE');
    END;
  END LOOP;
END;
/

------------------------------------------------------------
-- IMPLICIT CURSOR : SQL%ROWCOUNT
------------------------------------------------------------
BEGIN
  UPDATE learning_activity SET quiz_score = quiz_score + 2 WHERE quiz_score < 75;
  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rows updated');
  ROLLBACK;
END;
/
