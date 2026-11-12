-- DATASET : library_transactions   (from library_transactions.csv)
-- Columns : transaction_id, member_id, book_id, category, issue_date, return_date, fine_amount
-- Run     : @"C:\path\load-library-transactions.sql"

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
