-- PL/SQL : Triggers (Pizza DB)
-- Run:  @"C:\path\la3-plsql-triggers.sql"

SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

DROP TABLE order_list CASCADE CONSTRAINTS;
DROP TABLE orders CASCADE CONSTRAINTS;
DROP TABLE pizza CASCADE CONSTRAINTS;
DROP TABLE customer CASCADE CONSTRAINTS;

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

-- new column for this exercise
ALTER TABLE orders ADD total_amt NUMBER(10,2);

------------------------------------------------------------
-- BEFORE ROW TRIGGER + :NEW + RAISE_APPLICATION_ERROR : delivery same day or next day
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_delv_date
BEFORE INSERT OR UPDATE ON orders
FOR EACH ROW
BEGIN
  IF :NEW.delv_date < :NEW.order_date OR :NEW.delv_date > :NEW.order_date + 1 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Delivery must be on same day or next day');
  END IF;
END;
/

-- test: fails
INSERT INTO orders VALUES ('OP901','c003','30-JUN-2015','03-JUL-2015',0);
-- test: works
INSERT INTO orders VALUES ('OP902','c003','30-JUN-2015','01-JUL-2015',0);
SELECT * FROM orders WHERE order_no IN ('OP901','OP902');
ROLLBACK;

------------------------------------------------------------
-- AFTER INSERT ROW TRIGGER UPDATING ANOTHER TABLE : total_amt on new order_list row
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_total_amt
AFTER INSERT ON order_list
FOR EACH ROW
DECLARE
  v_price pizza.unit_price%TYPE;
BEGIN
  SELECT unit_price INTO v_price FROM pizza WHERE pizza_id = :NEW.pizza_id;
  UPDATE orders
  SET total_amt = NVL(total_amt,0) + NVL(:NEW.qty,0) * v_price
  WHERE order_no = :NEW.order_no;
END;
/

-- test: new order with 0 total, add 2 pizzas -> total = 2*130 + 1*230 = 490
INSERT INTO orders VALUES ('OP903','c004','30-JUN-2015','30-JUN-2015',0);
INSERT INTO order_list VALUES ('OP903','p001',2);
INSERT INTO order_list VALUES ('OP903','p002',1);
SELECT * FROM orders WHERE order_no = 'OP903';
ROLLBACK;

------------------------------------------------------------
-- BEFORE INSERT TRIGGER WITH COUNT : max 5 orders per customer per day
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_order_limit
BEFORE INSERT ON orders
FOR EACH ROW
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt
  FROM orders
  WHERE cust_id = :NEW.cust_id AND order_date = :NEW.order_date;

  IF v_cnt >= 5 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Customer can not place more than 5 orders per day');
  END IF;
END;
/

-- test: c007 places 5 orders (ok), 6th fails
INSERT INTO orders VALUES ('OP911','c007','30-JUN-2015','30-JUN-2015',0);
INSERT INTO orders VALUES ('OP912','c007','30-JUN-2015','30-JUN-2015',0);
INSERT INTO orders VALUES ('OP913','c007','30-JUN-2015','30-JUN-2015',0);
INSERT INTO orders VALUES ('OP914','c007','30-JUN-2015','30-JUN-2015',0);
INSERT INTO orders VALUES ('OP915','c007','30-JUN-2015','30-JUN-2015',0);
INSERT INTO orders VALUES ('OP916','c007','30-JUN-2015','30-JUN-2015',0);
SELECT * FROM orders WHERE cust_id = 'c007';
ROLLBACK;

SELECT trigger_name, status FROM user_triggers;
