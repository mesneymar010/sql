-- DATASET : bank_transactions   (from bank_transactions.csv)
-- Columns : transaction_id, customer_id, account_type, transaction_type, amount, branch, transaction_date
-- Run     : @"C:\path\sql-bank-transactions.sql"

SET SERVEROUTPUT ON SIZE 1000000
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

SELECT * FROM bank_transactions;

------------------------------------------------------------
-- SQL QUERIES
------------------------------------------------------------
-- WHERE : only deposits
SELECT * FROM bank_transactions WHERE transaction_type = 'Deposit';

-- WHERE + AND : savings withdrawals
SELECT * FROM bank_transactions WHERE account_type = 'Savings' AND transaction_type = 'Withdrawal';

-- ORDER BY : highest amount first
SELECT * FROM bank_transactions ORDER BY amount DESC;

-- BETWEEN DATES
SELECT * FROM bank_transactions
WHERE transaction_date BETWEEN TO_DATE('2026-10-02','YYYY-MM-DD') AND TO_DATE('2026-10-04','YYYY-MM-DD');

-- GROUP BY + SUM : total amount per branch
SELECT branch, SUM(amount) total_amount, COUNT(*) no_of_txn
FROM bank_transactions
GROUP BY branch
ORDER BY total_amount DESC;

-- GROUP BY + AVG/MIN/MAX : per account type
SELECT account_type, COUNT(*), AVG(amount), MIN(amount), MAX(amount)
FROM bank_transactions
GROUP BY account_type;

-- CASE + GROUP BY : deposit, withdrawal and balance per customer
SELECT customer_id,
       SUM(CASE WHEN transaction_type = 'Deposit' THEN amount ELSE 0 END) deposits,
       SUM(CASE WHEN transaction_type = 'Withdrawal' THEN amount ELSE 0 END) withdrawals,
       SUM(CASE WHEN transaction_type = 'Deposit' THEN amount ELSE -amount END) balance
FROM bank_transactions
GROUP BY customer_id
ORDER BY customer_id;

-- HAVING : branches with total more than 10000
SELECT branch, SUM(amount) FROM bank_transactions
GROUP BY branch
HAVING SUM(amount) > 10000;

-- HAVING COUNT : customers with more than one transaction
SELECT customer_id, COUNT(*) FROM bank_transactions
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- SUBQUERY (AVG) : transactions above average amount
SELECT * FROM bank_transactions
WHERE amount > (SELECT AVG(amount) FROM bank_transactions);

-- SUBQUERY (MAX) : highest transaction
SELECT * FROM bank_transactions
WHERE amount = (SELECT MAX(amount) FROM bank_transactions);

-- TOP N (ROWNUM) : top 3 transactions
SELECT * FROM (SELECT * FROM bank_transactions ORDER BY amount DESC)
WHERE ROWNUM <= 3;

-- UPDATE / DELETE
UPDATE bank_transactions SET amount = amount + 100 WHERE transaction_id = 'T001';
DELETE FROM bank_transactions WHERE transaction_id = 'T010';
ROLLBACK;

------------------------------------------------------------
-- PROCEDURE (IN, OUT) : balance of a customer
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE bank_balance(p_cust IN VARCHAR2, p_bal OUT NUMBER) IS
BEGIN
  SELECT SUM(CASE WHEN transaction_type = 'Deposit' THEN amount ELSE -amount END)
  INTO p_bal
  FROM bank_transactions
  WHERE customer_id = p_cust;
  IF p_bal IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No transactions for ' || p_cust);
  END IF;
END;
/

DECLARE
  b NUMBER;
BEGIN
  bank_balance('CU201', b);
  DBMS_OUTPUT.PUT_LINE('Balance of CU201: ' || b);
END;
/

------------------------------------------------------------
-- FUNCTION : total amount of a branch
------------------------------------------------------------
CREATE OR REPLACE FUNCTION bank_branch_total(p_branch IN VARCHAR2) RETURN NUMBER IS
  v_total NUMBER;
BEGIN
  SELECT NVL(SUM(amount), 0) INTO v_total
  FROM bank_transactions
  WHERE branch = p_branch;
  RETURN v_total;
END;
/

SELECT bank_branch_total('Chennai') FROM dual;

------------------------------------------------------------
-- TRIGGER (BEFORE INSERT) : amount must be > 0 and withdrawal <= 50000
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_bank_check
BEFORE INSERT OR UPDATE ON bank_transactions
FOR EACH ROW
BEGIN
  IF :NEW.amount <= 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Amount must be greater than 0');
  END IF;
  IF :NEW.transaction_type = 'Withdrawal' AND :NEW.amount > 50000 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Withdrawal limit is 50000');
  END IF;
END;
/

INSERT INTO bank_transactions VALUES ('T011','CU201','Savings','Withdrawal',60000,'Chennai',TO_DATE('2026-10-06','YYYY-MM-DD'));
INSERT INTO bank_transactions VALUES ('T012','CU201','Savings','Deposit',-5,'Chennai',TO_DATE('2026-10-06','YYYY-MM-DD'));
INSERT INTO bank_transactions VALUES ('T013','CU201','Savings','Deposit',2000,'Chennai',TO_DATE('2026-10-06','YYYY-MM-DD'));
SELECT * FROM bank_transactions WHERE transaction_id IN ('T011','T012','T013');
ROLLBACK;

------------------------------------------------------------
-- CURSOR + USER EXCEPTION : flag high value transactions (>= 10000)
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT * FROM bank_transactions;
  high_value EXCEPTION;
BEGIN
  FOR r IN c LOOP
    BEGIN
      IF r.amount >= 10000 THEN
        RAISE high_value;
      END IF;
      DBMS_OUTPUT.PUT_LINE(r.transaction_id || '  ' || r.customer_id || '  ' || r.amount);
    EXCEPTION
      WHEN high_value THEN
        DBMS_OUTPUT.PUT_LINE(r.transaction_id || '  ' || r.customer_id || '  ' || r.amount || '  <-- HIGH VALUE');
    END;
  END LOOP;
END;
/

------------------------------------------------------------
-- IMPLICIT CURSOR : SQL%ROWCOUNT
------------------------------------------------------------
BEGIN
  UPDATE bank_transactions SET amount = amount * 1.01 WHERE account_type = 'Savings';
  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rows updated');
  ROLLBACK;
END;
/
