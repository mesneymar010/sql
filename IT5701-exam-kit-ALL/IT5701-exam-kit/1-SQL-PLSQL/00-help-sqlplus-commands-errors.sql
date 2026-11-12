-- HELP : SQL*Plus commands and fixes (Oracle 10g, Windows)
-- Reference file. Copy the line you need. Don't run the whole file.

------------------------------------------------------------
-- 1. RUN FIRST IN EVERY SESSION
------------------------------------------------------------
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 200
SET PAGESIZE 100
SET SQLBLANKLINES ON
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';
SHOW USER

------------------------------------------------------------
-- 2. RUNNING AND EDITING
------------------------------------------------------------
@"C:\Users\26120040\Desktop\lab\la1.sql"
-- /        run last statement again
-- L        list last statement
-- ED       open last statement in Notepad, save, close, then type /
-- CL SCR   clear screen
-- Stuck at a line number prompt (like "  5")? type / to run it, or . to cancel
-- PL/SQL (DECLARE/BEGIN/CREATE PROCEDURE...) must end with / on its own line

-- save output to a file
SPOOL C:\Users\26120040\Desktop\output.txt
SPOOL OFF

-- columns too wide / wrapping
COLUMN address FORMAT A30
COLUMN cust_name FORMAT A15
CLEAR COLUMNS

------------------------------------------------------------
-- 3. SEE WHAT EXISTS
------------------------------------------------------------
SELECT * FROM tab;
SELECT table_name FROM user_tables;
DESC orders
SELECT object_name, object_type, status FROM user_objects;
SELECT trigger_name, table_name, status FROM user_triggers;
SELECT constraint_name, constraint_type, table_name FROM user_constraints WHERE table_name = 'ORDERS';

------------------------------------------------------------
-- 4. COMPILATION ERRORS
-- "Warning: Procedure created with compilation errors."
------------------------------------------------------------
SHOW ERRORS
SHOW ERRORS PROCEDURE print_bill
SHOW ERRORS FUNCTION top_customer
SHOW ERRORS TRIGGER trg_total_amt
SELECT name, line, text FROM user_errors;

------------------------------------------------------------
-- 5. CALLING PROCEDURES AND FUNCTIONS
------------------------------------------------------------
EXEC print_bill('OP100');

VARIABLE t NUMBER
EXEC total_pizza('OP100', :t);
PRINT t

SELECT top_customer('pan') FROM dual;

-- function that does UPDATE/INSERT -> call from a block
BEGIN
  DBMS_OUTPUT.PUT_LINE(bill_amount('OP200'));
END;
/

------------------------------------------------------------
-- 6. DROP / DISABLE
------------------------------------------------------------
DROP TABLE orders CASCADE CONSTRAINTS;
DROP PROCEDURE print_bill;
DROP FUNCTION top_customer;
DROP TRIGGER trg_order_limit;
ALTER TRIGGER trg_order_limit DISABLE;
ALTER TRIGGER trg_order_limit ENABLE;
ALTER TABLE orders DISABLE ALL TRIGGERS;
ALTER TABLE orders ENABLE ALL TRIGGERS;
PURGE RECYCLEBIN;

------------------------------------------------------------
-- 7. ALTER TABLE
------------------------------------------------------------
ALTER TABLE orders ADD total_amt NUMBER(10,2);
ALTER TABLE orders MODIFY total_amt NUMBER(12,2);
ALTER TABLE orders DROP COLUMN total_amt;
ALTER TABLE order_list MODIFY qty NOT NULL;
ALTER TABLE pizza ADD CONSTRAINT chk_price CHECK (unit_price > 0);
ALTER TABLE orders ADD CONSTRAINT fk_cust FOREIGN KEY (cust_id) REFERENCES customer(cust_id);
ALTER TABLE orders DROP CONSTRAINT fk_cust;

------------------------------------------------------------
-- 8. DATA
------------------------------------------------------------
COMMIT;
ROLLBACK;
DELETE FROM orders WHERE order_no = 'OP901';
TRUNCATE TABLE empraise;
UPDATE emp SET sal = 5000 WHERE eno = 1;

------------------------------------------------------------
-- 9. DATES
------------------------------------------------------------
SELECT SYSDATE FROM dual;
SELECT TO_DATE('29-JUN-2015','DD-MON-YYYY') FROM dual;
SELECT TO_CHAR(SYSDATE,'YYYY') FROM dual;
SELECT EXTRACT(YEAR FROM SYSDATE) FROM dual;
SELECT ADD_MONTHS(SYSDATE, -12) FROM dual;
SELECT MONTHS_BETWEEN(SYSDATE, TO_DATE('01-JAN-2020','DD-MON-YYYY')) FROM dual;
SELECT SYSDATE + 1 FROM dual;

------------------------------------------------------------
-- 10. QUICK TOY TABLE (when no data is given)
------------------------------------------------------------
CREATE TABLE student (
  rollno NUMBER(4) PRIMARY KEY,
  name   VARCHAR2(20),
  dept   VARCHAR2(10),
  marks  NUMBER(3),
  dob    DATE
);
INSERT INTO student VALUES (1,'Anu','CSE',85,'10-JAN-2004');
INSERT INTO student VALUES (2,'Babu','IT',72,'22-MAR-2004');
INSERT INTO student VALUES (3,'Cathy','CSE',91,'05-JUL-2003');
COMMIT;

------------------------------------------------------------
-- 11. PL/SQL SKELETONS
------------------------------------------------------------
-- block
DECLARE
  v NUMBER;
BEGIN
  SELECT COUNT(*) INTO v FROM emp;
  DBMS_OUTPUT.PUT_LINE('Count: ' || v);
EXCEPTION
  WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No data');
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- explicit cursor with OPEN/FETCH/CLOSE
DECLARE
  CURSOR c IS SELECT ename, sal FROM emp;
  v_name emp.ename%TYPE;
  v_sal  emp.sal%TYPE;
BEGIN
  OPEN c;
  LOOP
    FETCH c INTO v_name, v_sal;
    EXIT WHEN c%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_name || ' ' || v_sal);
  END LOOP;
  CLOSE c;
END;
/

-- user exception
DECLARE
  my_err EXCEPTION;
BEGIN
  RAISE my_err;
EXCEPTION
  WHEN my_err THEN DBMS_OUTPUT.PUT_LINE('my_err raised');
END;
/

-- procedure
CREATE OR REPLACE PROCEDURE p1(a IN NUMBER, b OUT NUMBER) IS
BEGIN
  b := a * 2;
END;
/

-- function
CREATE OR REPLACE FUNCTION f1(a IN NUMBER) RETURN NUMBER IS
BEGIN
  RETURN a * 2;
END;
/

-- row trigger
CREATE OR REPLACE TRIGGER t1
BEFORE INSERT OR UPDATE ON emp
FOR EACH ROW
BEGIN
  IF :NEW.sal < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Salary can not be negative');
  END IF;
END;
/

------------------------------------------------------------
-- 12. COMMON ERRORS
------------------------------------------------------------
-- Nothing printed from DBMS_OUTPUT  -> SET SERVEROUTPUT ON
-- ORA-00942 table or view does not exist -> wrong name / not created yet (ok on first DROP)
-- ORA-00955 name is already used         -> DROP it first
-- ORA-00904 invalid identifier           -> wrong column name, check DESC
-- ORA-00933 / ORA-00936                  -> syntax: missing comma, extra comma, missing FROM
-- ORA-00001 unique constraint violated   -> duplicate primary key value
-- ORA-01400 cannot insert NULL           -> NOT NULL column left empty
-- ORA-02291 parent key not found         -> insert parent (customer/orders) first
-- ORA-02292 child record found           -> delete child rows first or use CASCADE
-- ORA-02296 cannot enable NOT NULL       -> column already has NULLs (use CHECK (col IS NOT NULL) NOVALIDATE)
-- ORA-01722 invalid number               -> text compared/inserted into NUMBER column
-- ORA-01843 / ORA-01858 date errors      -> use TO_DATE('29-JUN-2015','DD-MON-YYYY')
-- ORA-01403 no data found                -> SELECT INTO got 0 rows, handle NO_DATA_FOUND
-- ORA-01422 exact fetch returns more     -> SELECT INTO got many rows, use a cursor
-- ORA-06502 value error                  -> variable too small, use %TYPE
-- ORA-04091 table is mutating            -> row trigger reading its own table (avoid INSERT..SELECT)
-- ORA-14551 cannot perform DML in query  -> function with UPDATE called in SELECT, call in block
-- ORA-20xxx                              -> your own RAISE_APPLICATION_ERROR (expected in tests)
-- PLS-00201 identifier must be declared  -> typo or variable not declared
-- ORA-06550 / PLS errors                 -> SHOW ERRORS

-- NOT in 10g (works on Mac 23ai but fails in college):
-- FETCH FIRST n ROWS ONLY  -> use WHERE ROWNUM <= n
-- GENERATED AS IDENTITY    -> plain NUMBER primary key
-- COMPOUND TRIGGER         -> normal row trigger
-- CREATE TABLE IF NOT EXISTS, DROP TABLE IF EXISTS
-- SELECT without FROM dual
-- LISTAGG
