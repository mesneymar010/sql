-- PL/SQL : Cursors and Exceptions
-- Run:  @"C:\path\la4-plsql-cursors-exceptions.sql"

SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

DROP TABLE empraise;
DROP TABLE emp;

CREATE TABLE emp (
  eno         NUMBER(4) PRIMARY KEY,
  ename       VARCHAR2(20),
  designation VARCHAR2(20),
  doj         DATE,
  sal         NUMBER(8,2),
  comm        NUMBER(8,2),
  deptno      NUMBER(2)
);

CREATE TABLE empraise (
  eno        NUMBER(4) REFERENCES emp(eno),
  raise_date DATE,
  raise_amt  NUMBER(8,2)
);

-- doj relative to today, so all cases (<1 yr, 1-2 yr, >2 yr) always exist
INSERT INTO emp VALUES (1,'Arun','Manager',ADD_MONTHS(SYSDATE,-60),5000,1500,10);
INSERT INTO emp VALUES (2,'Bala','Clerk',ADD_MONTHS(SYSDATE,-6),3000,NULL,20);
INSERT INTO emp VALUES (3,'Chitra','Analyst',ADD_MONTHS(SYSDATE,-18),4500,500,20);
INSERT INTO emp VALUES (4,'Deepa','Salesman',ADD_MONTHS(SYSDATE,-36),4000,2500,30);
INSERT INTO emp VALUES (5,'Ezhil','Clerk',ADD_MONTHS(SYSDATE,-30),2800,NULL,10);
INSERT INTO emp VALUES (6,'Farook','Analyst',ADD_MONTHS(SYSDATE,-14),6200,NULL,20);
COMMIT;

SELECT * FROM emp;

------------------------------------------------------------
-- EXPLICIT CURSOR + USER-DEFINED EXCEPTION + IF-ELSIF : raise by experience
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT * FROM emp;
  v_exp    NUMBER;
  v_sal    NUMBER;
  less_exp EXCEPTION;
BEGIN
  FOR r IN c LOOP
    BEGIN
      v_exp := ROUND(MONTHS_BETWEEN(SYSDATE, r.doj) / 12, 1);
      IF v_exp < 1 THEN
        RAISE less_exp;
      ELSIF v_exp <= 2 THEN
        v_sal := r.sal * 1.15;
      ELSE
        v_sal := r.sal * 1.20;
      END IF;
      UPDATE emp SET sal = v_sal WHERE eno = r.eno;
      DBMS_OUTPUT.PUT_LINE(r.ename || '  ' || r.designation || '  ' || v_sal || '  ' || v_exp || ' yrs');
    EXCEPTION
      WHEN less_exp THEN
        DBMS_OUTPUT.PUT_LINE(r.ename || ' : less than 1 year, details not displayed');
    END;
  END LOOP;
END;
/

------------------------------------------------------------
-- CURSOR WITH UPDATE + INSERT INTO LOG TABLE : 5% raise for dept 20
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT eno, sal FROM emp WHERE deptno = 20;
  v_raise NUMBER;
BEGIN
  FOR r IN c LOOP
    v_raise := r.sal * 0.05;
    UPDATE emp SET sal = sal + v_raise WHERE eno = r.eno;
    INSERT INTO empraise VALUES (r.eno, SYSDATE, v_raise);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Raise given to dept 20');
END;
/

SELECT * FROM empraise;

------------------------------------------------------------
-- CURSOR WITH WHERE + NVL : employees with sal + comm > 6000
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT * FROM emp WHERE sal + NVL(comm,0) > 6000;
BEGIN
  FOR r IN c LOOP
    DBMS_OUTPUT.PUT_LINE(r.eno || '  ' || r.ename || '  ' || r.designation || '  ' ||
                         r.sal || '  ' || NVL(r.comm,0) || '  ' || r.deptno);
  END LOOP;
END;
/

------------------------------------------------------------
-- RAISE EXCEPTION ON CONDITION : show if netsal > 6000, else exception
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT ename, sal, comm FROM emp;
  v_net   NUMBER;
  low_sal EXCEPTION;
BEGIN
  FOR r IN c LOOP
    BEGIN
      v_net := r.sal + NVL(r.comm,0);
      IF v_net > 6000 THEN
        DBMS_OUTPUT.PUT_LINE(r.ename || '  ' || r.sal || '  netsal: ' || v_net);
      ELSE
        RAISE low_sal;
      END IF;
    EXCEPTION
      WHEN low_sal THEN
        DBMS_OUTPUT.PUT_LINE(r.ename || ' : netsal ' || v_net || ' is not more than 6000');
    END;
  END LOOP;
END;
/

------------------------------------------------------------
-- IMPLICIT CURSOR SQL%FOUND / SQL%ROWCOUNT : +2000 for dept 10
------------------------------------------------------------
BEGIN
  UPDATE emp SET sal = sal + 2000 WHERE deptno = 10;
  IF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rows updated');
  ELSE
    DBMS_OUTPUT.PUT_LINE('No employees in dept 10');
  END IF;
END;
/

SELECT * FROM emp;
COMMIT;
