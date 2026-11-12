-- DATASET : bank_transactions   (from bank_transactions.csv)
-- Columns : transaction_id, customer_id, account_type, transaction_type, amount, branch, transaction_date
-- Run     : @"C:\path\load-bank-transactions.sql"

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
