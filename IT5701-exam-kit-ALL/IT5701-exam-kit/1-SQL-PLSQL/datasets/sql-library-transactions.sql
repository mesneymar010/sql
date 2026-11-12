-- DATASET : library_transactions   (from library_transactions.csv)
-- Columns : transaction_id, member_id, book_id, category, issue_date, return_date, fine_amount
-- Run     : @"C:\path\sql-library-transactions.sql"

SET SERVEROUTPUT ON SIZE 1000000
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

SELECT * FROM library_transactions;

------------------------------------------------------------
-- SQL QUERIES
------------------------------------------------------------
-- WHERE : transactions with fine
SELECT * FROM library_transactions WHERE fine_amount > 0;

-- DATE ARITHMETIC : days each book was kept
SELECT transaction_id, member_id, book_id, return_date - issue_date days_kept
FROM library_transactions;

-- DATE ARITHMETIC + WHERE : kept more than 14 days
SELECT * FROM library_transactions WHERE return_date - issue_date > 14;

-- TO_CHAR (date) : issue date as day name
SELECT transaction_id, TO_CHAR(issue_date,'DD-Mon-YYYY Day') issued_on FROM library_transactions;

-- GROUP BY + SUM : total fine per member
SELECT member_id, SUM(fine_amount) total_fine, COUNT(*) books_taken
FROM library_transactions
GROUP BY member_id
ORDER BY total_fine DESC;

-- GROUP BY + COUNT : books issued per category
SELECT category, COUNT(*) no_of_issues
FROM library_transactions
GROUP BY category;

-- HAVING : books issued more than once
SELECT book_id, COUNT(*) FROM library_transactions
GROUP BY book_id
HAVING COUNT(*) > 1;

-- SUBQUERY (AVG) : fine above average
SELECT * FROM library_transactions
WHERE fine_amount > (SELECT AVG(fine_amount) FROM library_transactions);

-- SUBQUERY WITH GROUP : member(s) with highest total fine
SELECT member_id, SUM(fine_amount) FROM library_transactions
GROUP BY member_id
HAVING SUM(fine_amount) = (SELECT MAX(SUM(fine_amount)) FROM library_transactions GROUP BY member_id);

-- CASE : late or on time
SELECT transaction_id, return_date - issue_date days_kept,
       CASE WHEN return_date - issue_date > 14 THEN 'Late' ELSE 'On Time' END status
FROM library_transactions;

------------------------------------------------------------
-- PROCEDURE (IN, OUT) : total fine of a member
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE lib_member_fine(p_mid IN VARCHAR2, p_total OUT NUMBER) IS
BEGIN
  SELECT SUM(fine_amount) INTO p_total
  FROM library_transactions
  WHERE member_id = p_mid;
  IF p_total IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No transactions for ' || p_mid);
  END IF;
END;
/

DECLARE
  t NUMBER;
BEGIN
  lib_member_fine('MB101', t);
  DBMS_OUTPUT.PUT_LINE('Total fine of MB101: ' || t);
END;
/

------------------------------------------------------------
-- FUNCTION : fine = Rs.2 per day after 14 days
------------------------------------------------------------
CREATE OR REPLACE FUNCTION lib_calc_fine(p_issue IN DATE, p_return IN DATE) RETURN NUMBER IS
  v_days NUMBER;
BEGIN
  v_days := p_return - p_issue;
  IF v_days > 14 THEN
    RETURN (v_days - 14) * 2;
  ELSE
    RETURN 0;
  END IF;
END;
/

SELECT transaction_id, return_date - issue_date days_kept, lib_calc_fine(issue_date, return_date) calc_fine
FROM library_transactions;

------------------------------------------------------------
-- TRIGGER (BEFORE INSERT) : return after issue, fine default 0
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_lib_check
BEFORE INSERT OR UPDATE ON library_transactions
FOR EACH ROW
BEGIN
  IF :NEW.return_date < :NEW.issue_date THEN
    RAISE_APPLICATION_ERROR(-20001, 'Return date can not be before issue date');
  END IF;
  IF :NEW.fine_amount IS NULL THEN
    :NEW.fine_amount := 0;
  END IF;
END;
/

INSERT INTO library_transactions VALUES ('L011','MB107','B107','History',TO_DATE('2026-09-20','YYYY-MM-DD'),TO_DATE('2026-09-10','YYYY-MM-DD'),0);
INSERT INTO library_transactions VALUES ('L012','MB107','B107','History',TO_DATE('2026-09-20','YYYY-MM-DD'),TO_DATE('2026-09-30','YYYY-MM-DD'),NULL);
SELECT * FROM library_transactions WHERE transaction_id IN ('L011','L012');
ROLLBACK;

------------------------------------------------------------
-- CURSOR + USER EXCEPTION : late returns (> 14 days)
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT * FROM library_transactions;
  late_return EXCEPTION;
  v_days NUMBER;
BEGIN
  FOR r IN c LOOP
    BEGIN
      v_days := r.return_date - r.issue_date;
      IF v_days > 14 THEN
        RAISE late_return;
      END IF;
      DBMS_OUTPUT.PUT_LINE(r.transaction_id || '  ' || r.member_id || '  ' || v_days || ' days  OK');
    EXCEPTION
      WHEN late_return THEN
        DBMS_OUTPUT.PUT_LINE(r.transaction_id || '  ' || r.member_id || '  ' || v_days || ' days  <-- LATE');
    END;
  END LOOP;
END;
/

------------------------------------------------------------
-- IMPLICIT CURSOR : SQL%ROWCOUNT
------------------------------------------------------------
BEGIN
  UPDATE library_transactions SET fine_amount = fine_amount + 5 WHERE return_date - issue_date > 14;
  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rows updated');
  ROLLBACK;
END;
/
