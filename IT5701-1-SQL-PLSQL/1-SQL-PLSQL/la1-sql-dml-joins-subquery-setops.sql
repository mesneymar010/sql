-- SQL : DML, Joins, Subquery, Set operations
-- Run:  @"C:\path\la1-sql-dml-joins-subquery-setops.sql"

SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

DROP TABLE employees CASCADE CONSTRAINTS;
DROP TABLE order_list CASCADE CONSTRAINTS;
DROP TABLE orders CASCADE CONSTRAINTS;
DROP TABLE pizza CASCADE CONSTRAINTS;
DROP TABLE customer CASCADE CONSTRAINTS;

------------------------------------------------------------
-- SETUP : EMPLOYEES table (from employees.sql)
------------------------------------------------------------
CREATE TABLE employees (
  employee_id    NUMBER(6) PRIMARY KEY,
  first_name     VARCHAR2(20),
  last_name      VARCHAR2(25) NOT NULL,
  email          VARCHAR2(25) NOT NULL UNIQUE,
  phone_number   VARCHAR2(20),
  hire_date      DATE NOT NULL,
  job_id         VARCHAR2(10) NOT NULL,
  salary         NUMBER(8,2) CHECK (salary > 0),
  commission_pct NUMBER(2,2),
  manager_id     NUMBER(6) REFERENCES employees(employee_id),
  department_id  NUMBER(4)
);

INSERT INTO employees VALUES (100,'Steven','King','SKING','515.123.4567','17-JUN-1987','AD_PRES',24000,NULL,NULL,90);
INSERT INTO employees VALUES (101,'Neena','Kochhar','NKOCHHAR','515.123.4568','21-SEP-1989','AD_VP',17000,NULL,100,90);
INSERT INTO employees VALUES (102,'Lex','De Haan','LDEHAAN','515.123.4569','13-JAN-1993','AD_VP',17000,NULL,100,90);
INSERT INTO employees VALUES (103,'Alexander','Hunold','AHUNOLD','590.423.4567','03-JAN-1990','IT_PROG',9000,NULL,102,60);
INSERT INTO employees VALUES (104,'Bruce','Ernst','BERNST','590.423.4568','21-MAY-1991','IT_PROG',6000,NULL,103,60);
INSERT INTO employees VALUES (105,'David','Austin','DAUSTIN','590.423.4569','25-JUN-1997','IT_PROG',4800,NULL,103,60);
INSERT INTO employees VALUES (106,'Valli','Pataballa','VPATABAL','590.423.4560','05-FEB-1998','IT_PROG',4800,NULL,103,60);
INSERT INTO employees VALUES (107,'Diana','Lorentz','DLORENTZ','590.423.5567','07-FEB-1999','IT_PROG',4200,NULL,103,60);
INSERT INTO employees VALUES (124,'Kevin','Mourgos','KMOURGOS','650.123.5234','16-NOV-1999','ST_MAN',5800,NULL,100,50);
INSERT INTO employees VALUES (141,'Trenna','Rajs','TRAJS','650.121.8009','17-OCT-1995','ST_CLERK',3500,NULL,124,50);
INSERT INTO employees VALUES (142,'Curtis','Davies','CDAVIES','650.121.2994','29-JAN-1997','ST_CLERK',3100,NULL,124,50);
INSERT INTO employees VALUES (143,'Randall','Matos','RMATOS','650.121.2874','15-MAR-1998','ST_CLERK',2600,NULL,124,50);
INSERT INTO employees VALUES (144,'Peter','Vargas','PVARGAS','650.121.2004','09-JUL-1998','ST_CLERK',2500,NULL,124,50);
INSERT INTO employees VALUES (149,'Eleni','Zlotkey','EZLOTKEY','011.44.1344.429018','29-JAN-2000','SA_MAN',10500,.2,100,80);
INSERT INTO employees VALUES (174,'Ellen','Abel','EABEL','011.44.1644.429267','11-MAY-1996','SA_REP',11000,.30,149,80);
INSERT INTO employees VALUES (176,'Jonathon','Taylor','JTAYLOR','011.44.1644.429265','24-MAR-1998','SA_REP',8600,.20,149,80);
INSERT INTO employees VALUES (178,'Kimberely','Grant','KGRANT','011.44.1644.429263','24-MAY-1999','SA_REP',7000,.15,149,NULL);
INSERT INTO employees VALUES (200,'Jennifer','Whalen','JWHALEN','515.123.4444','17-SEP-1987','AD_ASST',4400,NULL,101,10);
INSERT INTO employees VALUES (201,'Michael','Hartstein','MHARTSTE','515.123.5555','17-FEB-1996','MK_MAN',13000,NULL,100,20);
INSERT INTO employees VALUES (202,'Pat','Fay','PFAY','603.123.6666','17-AUG-1997','MK_REP',6000,NULL,201,20);
INSERT INTO employees VALUES (205,'Shelley','Higgins','SHIGGINS','515.123.8080','07-JUN-1994','AC_MGR',12000,NULL,101,110);
INSERT INTO employees VALUES (206,'William','Gietz','WGIETZ','515.123.8181','07-JUN-1994','AC_ACCOUNT',8300,NULL,205,110);
COMMIT;

------------------------------------------------------------
-- CONCAT || + COLUMN ALIAS + ORDER BY : full name, monthly and annual salary
------------------------------------------------------------
SELECT employee_id,
       first_name || ' ' || last_name "FULL NAME",
       salary "MONTHLY SAL",
       salary * 12 "ANNUAL SALARY"
FROM employees
ORDER BY first_name;

-- IS NOT NULL : employees earning commission
SELECT employee_id, first_name, job_id, salary, commission_pct
FROM employees
WHERE commission_pct IS NOT NULL;

-- LIKE : employees who are managers
SELECT employee_id, first_name, job_id, salary, department_id
FROM employees
WHERE job_id LIKE '%MAN' OR job_id LIKE '%MGR';

-- AND / OR + DATE COMPARE : not sales rep, hired after 01-May-1999 or salary >= 10000
SELECT employee_id, first_name, hire_date, job_id, salary, department_id
FROM employees
WHERE job_id <> 'SA_REP'
AND (hire_date > TO_DATE('01-MAY-1999','DD-MON-YYYY') OR salary >= 10000);

-- BETWEEN + IN + SUBSTR : salary 5000-15000, name starts with A,J,K,S
SELECT first_name, salary, hire_date, department_id
FROM employees
WHERE salary BETWEEN 5000 AND 15000
AND SUBSTR(first_name,1,1) IN ('A','J','K','S')
ORDER BY first_name;

-- MONTHS_BETWEEN + TRUNC + MOD : experience in years and months
SELECT employee_id, first_name, hire_date,
       TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) "EXP-YRS",
       MOD(TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date)), 12) "EXP-MONTHS"
FROM employees
WHERE hire_date > TO_DATE('31-DEC-1998','DD-MON-YYYY');

-- GROUP BY + TO_CHAR(date) : employees hired year-wise
SELECT TO_CHAR(hire_date,'YYYY') "HIRE_YEAR", COUNT(*) "NO_OF_EMP"
FROM employees
GROUP BY TO_CHAR(hire_date,'YYYY')
ORDER BY TO_CHAR(hire_date,'YYYY');

-- AGGREGATE + GROUP BY + HAVING : min, max, avg salary per dept
SELECT department_id, MIN(salary), MAX(salary), AVG(salary), COUNT(*)
FROM employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING COUNT(*) >= 2 AND AVG(salary) > 10000
ORDER BY MIN(salary) DESC;

------------------------------------------------------------
-- SETUP : PIZZA DB
-- CREATE TABLE + PRIMARY KEY / FOREIGN KEY / COMPOSITE KEY
------------------------------------------------------------
CREATE TABLE customer (
  cust_id   VARCHAR2(5) PRIMARY KEY,
  cust_name VARCHAR2(20),
  address   VARCHAR2(50),
  phone     NUMBER(10)
);

CREATE TABLE pizza (
  pizza_id   VARCHAR2(5) PRIMARY KEY,
  pizza_type VARCHAR2(20),
  unit_price NUMBER(6)
);

CREATE TABLE orders (
  order_no   VARCHAR2(5) PRIMARY KEY,
  cust_id    VARCHAR2(5) REFERENCES customer(cust_id),
  order_date DATE,
  delv_date  DATE
);

CREATE TABLE order_list (
  order_no VARCHAR2(5) REFERENCES orders(order_no),
  pizza_id VARCHAR2(5) REFERENCES pizza(pizza_id),
  qty      NUMBER(3),
  PRIMARY KEY (order_no, pizza_id)
);

-- data (same as pizza-db.sql). In lab you can instead run: @"C:\path\pizza-db.sql"
insert into customer values('c001','Hari','32 RING ROAD,ALWARPET',9001200031);
insert into customer values('c002','Prasanth','42 bull ROAD,numgambakkam',9444120003);
insert into customer values('c003','Neethu','12a RING ROAD,ALWARPET',9840112003);
insert into customer values('c004','Jim','P.H ROAD,Annanagar',9845712993);
insert into customer values('c005','Sindhu','100 feet ROAD,vadapalani',9840166677);
insert into customer values('c006','Brinda','GST ROAD, TAMBARAM', 9876543210);
insert into customer values('c007','Ramkumar','2nd cross street, Perambur',8566944453);

insert into pizza values('p001','pan',130);
insert into pizza values('p002','grilled',230);
insert into pizza values('p003','italian',200);
insert into pizza values('p004','spanish',260);
insert into pizza values('p005','supremo',250);

insert into orders values('OP100','c001','28-JUN-2015','28-JUN-2015');
insert into orders values('OP200','c002','28-JUN-2015','29-JUN-2015');
insert into orders values('OP300','c003','29-JUN-2015','29-JUN-2015');
insert into orders values('OP400','c004','29-JUN-2015','29-JUN-2015');
insert into orders values('OP500','c001','29-JUN-2015','30-JUN-2015');
insert into orders values('OP600','c002','29-JUN-2015','29-JUN-2015');
insert into orders values('OP700','c005','30-JUN-2015','30-JUN-2015');
insert into orders values('OP800','c006','30-JUN-2015','30-JUN-2015');

insert into order_list values('OP100','p001',3);
insert into order_list values('OP100','p002',2);
insert into order_list values('OP100','p003',2);
insert into order_list values('OP100','p004',5);
insert into order_list values('OP100','p005',4);
insert into order_list values('OP200','p003',2);
insert into order_list values('OP200','p001',6);
insert into order_list values('OP200','p004',8);
insert into order_list values('OP300','p003',3);
insert into order_list values('OP400','p001',3);
insert into order_list values('OP400','p004',1);
insert into order_list values('OP500','p003',6);
insert into order_list values('OP500','p004',5);
insert into order_list values('OP500','p001',null);
insert into order_list values('OP600','p002',3);
insert into order_list values('OP600','p003',2);
COMMIT;

-- ALTER TABLE + NOT NULL constraint : qty can not be null
ALTER TABLE order_list MODIFY qty NOT NULL;
-- above fails (ORA-02296) because OP500 already has a NULL qty. Then use:
ALTER TABLE order_list ADD CONSTRAINT qty_nn CHECK (qty IS NOT NULL) NOVALIDATE;

------------------------------------------------------------
-- JOIN
------------------------------------------------------------
-- INNER JOIN + GROUP BY : total qty ordered for each pizza
SELECT p.pizza_type, SUM(ol.qty) "TOTAL_QTY"
FROM pizza p JOIN order_list ol ON p.pizza_id = ol.pizza_id
GROUP BY p.pizza_type;

-- MULTI-TABLE JOIN + DISTINCT : pizza types not delivered on ordered day
SELECT DISTINCT p.pizza_type
FROM pizza p
JOIN order_list ol ON p.pizza_id = ol.pizza_id
JOIN orders o ON ol.order_no = o.order_no
WHERE o.delv_date <> o.order_date;

-- LEFT OUTER JOIN + COUNT : orders per customer, including 0 orders
SELECT c.cust_id, c.cust_name, COUNT(o.order_no) "NO_OF_ORDERS"
FROM customer c LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.cust_name;

-- SELF JOIN : pairs of pizzas where qty of first > second in OP100
SELECT p1.pizza_type "PIZZA1", a.qty, p2.pizza_type "PIZZA2", b.qty
FROM order_list a
JOIN order_list b ON a.order_no = b.order_no
JOIN pizza p1 ON a.pizza_id = p1.pizza_id
JOIN pizza p2 ON b.pizza_id = p2.pizza_id
WHERE a.order_no = 'OP100' AND a.qty > b.qty;

------------------------------------------------------------
-- SUBQUERY
------------------------------------------------------------
-- SIMPLE SUBQUERY (AVG) : qty more than overall average
SELECT o.order_no, p.pizza_type, c.cust_name, ol.qty
FROM orders o, order_list ol, pizza p, customer c
WHERE o.order_no = ol.order_no AND ol.pizza_id = p.pizza_id AND o.cust_id = c.cust_id
AND ol.qty > (SELECT AVG(qty) FROM order_list);

-- SUBQUERY WITH IN + GROUP BY HAVING : more than one pizza type in an order
SELECT cust_id, cust_name
FROM customer
WHERE cust_id IN (SELECT o.cust_id
                  FROM orders o, order_list ol
                  WHERE o.order_no = ol.order_no
                  GROUP BY o.cust_id, o.order_no
                  HAVING COUNT(ol.pizza_id) > 1);

-- SUBQUERY WITH > ALL : qty more than the average of each pizza type
SELECT o.order_no, p.pizza_type, c.cust_name, ol.qty
FROM orders o, order_list ol, pizza p, customer c
WHERE o.order_no = ol.order_no AND ol.pizza_id = p.pizza_id AND o.cust_id = c.cust_id
AND ol.qty > ALL (SELECT AVG(qty) FROM order_list GROUP BY pizza_id);

-- CORRELATED SUBQUERY : qty more than average of its own pizza type
SELECT o.order_no, p.pizza_type, c.cust_name, ol.qty
FROM orders o, order_list ol, pizza p, customer c
WHERE o.order_no = ol.order_no AND ol.pizza_id = p.pizza_id AND o.cust_id = c.cust_id
AND ol.qty > (SELECT AVG(x.qty) FROM order_list x WHERE x.pizza_id = ol.pizza_id);

-- DIVISION (COUNT DISTINCT = COUNT ALL) : ordered all pizza types in one order
SELECT *
FROM customer
WHERE cust_id IN (SELECT o.cust_id
                  FROM orders o, order_list ol
                  WHERE o.order_no = ol.order_no
                  GROUP BY o.cust_id, o.order_no
                  HAVING COUNT(DISTINCT ol.pizza_id) = (SELECT COUNT(*) FROM pizza));

------------------------------------------------------------
-- SET OPERATIONS
------------------------------------------------------------
-- UNION : qty more than average of pan or italian
SELECT ol.order_no, p.pizza_type, ol.qty
FROM order_list ol, pizza p
WHERE ol.pizza_id = p.pizza_id
AND ol.qty > (SELECT AVG(x.qty) FROM order_list x, pizza y
              WHERE x.pizza_id = y.pizza_id AND y.pizza_type = 'pan')
UNION
SELECT ol.order_no, p.pizza_type, ol.qty
FROM order_list ol, pizza p
WHERE ol.pizza_id = p.pizza_id
AND ol.qty > (SELECT AVG(x.qty) FROM order_list x, pizza y
              WHERE x.pizza_id = y.pizza_id AND y.pizza_type = 'italian');

-- MINUS : orders with pan but not italian
SELECT ol.order_no FROM order_list ol, pizza p
WHERE ol.pizza_id = p.pizza_id AND p.pizza_type = 'pan'
MINUS
SELECT ol.order_no FROM order_list ol, pizza p
WHERE ol.pizza_id = p.pizza_id AND p.pizza_type = 'italian';

-- INTERSECT : customers who ordered both italian and grilled
SELECT c.cust_name FROM customer c, orders o, order_list ol, pizza p
WHERE c.cust_id = o.cust_id AND o.order_no = ol.order_no
AND ol.pizza_id = p.pizza_id AND p.pizza_type = 'italian'
INTERSECT
SELECT c.cust_name FROM customer c, orders o, order_list ol, pizza p
WHERE c.cust_id = o.cust_id AND o.order_no = ol.order_no
AND ol.pizza_id = p.pizza_id AND p.pizza_type = 'grilled';
