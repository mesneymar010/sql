-- PL/SQL : Stored Procedures and Functions (Pizza DB)
-- Run:  @"C:\path\la2-plsql-procedures-functions.sql"

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
-- PROCEDURE WITH IN + OUT PARAMETERS : total pizzas in an order
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE total_pizza(p_ono IN VARCHAR2, p_total OUT NUMBER) IS
BEGIN
  SELECT SUM(qty) INTO p_total FROM order_list WHERE order_no = p_ono;
  IF p_total IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No pizzas found for order ' || p_ono);
  END IF;
END;
/

DECLARE
  t NUMBER;
BEGIN
  total_pizza('OP100', t);
  DBMS_OUTPUT.PUT_LINE('Total pizzas in OP100: ' || t);
  total_pizza('OP999', t);
END;
/

------------------------------------------------------------
-- PROCEDURE + CURSOR FOR LOOP + IF-ELSIF + UPDATE : discount bill
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE print_bill(p_ono IN VARCHAR2) IS
  v_date  orders.order_date%TYPE;
  v_name  customer.cust_name%TYPE;
  v_phone customer.phone%TYPE;
  v_sno   NUMBER := 0;
  v_qty   NUMBER := 0;
  v_total NUMBER := 0;
  v_pct   NUMBER := 0;
  v_disc  NUMBER;
  v_pay   NUMBER;
BEGIN
  SELECT o.order_date, c.cust_name, c.phone INTO v_date, v_name, v_phone
  FROM orders o, customer c
  WHERE o.cust_id = c.cust_id AND o.order_no = p_ono;

  DBMS_OUTPUT.PUT_LINE('************************************************************');
  DBMS_OUTPUT.PUT_LINE(RPAD('Order Number:' || p_ono, 35) || 'Customer Name: ' || v_name);
  DBMS_OUTPUT.PUT_LINE(RPAD('Order Date :' || TO_CHAR(v_date,'DD-Mon-YYYY'), 35) || 'Phone: ' || v_phone);
  DBMS_OUTPUT.PUT_LINE('************************************************************');
  DBMS_OUTPUT.PUT_LINE(RPAD('SNo',6) || RPAD('Pizza Type',15) || RPAD('Qty',6) || RPAD('Price',8) || 'Amount');

  FOR r IN (SELECT p.pizza_type, NVL(ol.qty,0) qty, p.unit_price
            FROM order_list ol, pizza p
            WHERE ol.pizza_id = p.pizza_id AND ol.order_no = p_ono) LOOP
    v_sno   := v_sno + 1;
    v_qty   := v_qty + r.qty;
    v_total := v_total + r.qty * r.unit_price;
    DBMS_OUTPUT.PUT_LINE(RPAD(v_sno || '.',6) || RPAD(INITCAP(r.pizza_type),15) ||
                         RPAD(r.qty,6) || RPAD(r.unit_price,8) || r.qty * r.unit_price);
  END LOOP;

  IF v_sno = 0 THEN
    DBMS_OUTPUT.PUT_LINE('No pizzas in this order');
    RETURN;
  END IF;

  IF v_total > 10000 THEN
    v_pct := 20;
  ELSIF v_total > 5000 THEN
    v_pct := 10;
  ELSIF v_total > 2000 THEN
    v_pct := 5;
  END IF;

  v_disc := v_total * v_pct / 100;
  v_pay  := v_total - v_disc;

  UPDATE orders SET total_amt = v_pay WHERE order_no = p_ono;

  DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
  DBMS_OUTPUT.PUT_LINE(RPAD('Total =',21) || RPAD(v_qty,14) || v_total);
  DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Total Amount       :Rs.' || v_total);
  DBMS_OUTPUT.PUT_LINE(RPAD('Discount (' || v_pct || '%)',19) || ':Rs.' || v_disc);
  DBMS_OUTPUT.PUT_LINE('------------------------------');
  DBMS_OUTPUT.PUT_LINE('Amount to be paid  :Rs.' || v_pay);
  DBMS_OUTPUT.PUT_LINE('------------------------------');
  DBMS_OUTPUT.PUT_LINE('Great Offers! Discount up to 25% on DIWALI Festival Day...');
  DBMS_OUTPUT.PUT_LINE('************************************************************');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Order ' || p_ono || ' not found');
END;
/

EXEC print_bill('OP100');
EXEC print_bill('OP999');
SELECT * FROM orders WHERE order_no = 'OP100';

------------------------------------------------------------
-- FUNCTION RETURNING VARCHAR2 + ROWNUM TOP-1 : top customer for a pizza type
------------------------------------------------------------
CREATE OR REPLACE FUNCTION top_customer(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  v_name customer.cust_name%TYPE;
BEGIN
  SELECT cust_name INTO v_name
  FROM (SELECT c.cust_name, SUM(NVL(ol.qty,0)) tot
        FROM customer c, orders o, order_list ol, pizza p
        WHERE c.cust_id = o.cust_id AND o.order_no = ol.order_no
        AND ol.pizza_id = p.pizza_id AND p.pizza_type = p_type
        GROUP BY c.cust_name
        ORDER BY tot DESC)
  WHERE ROWNUM = 1;
  RETURN v_name;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'No orders for ' || p_type;
END;
/

SELECT top_customer('pan') FROM dual;
SELECT top_customer('italian') FROM dual;
SELECT top_customer('xyz') FROM dual;

------------------------------------------------------------
-- FUNCTION WITH UPDATE (call from block) : amount to be paid after discount
------------------------------------------------------------
CREATE OR REPLACE FUNCTION bill_amount(p_ono IN VARCHAR2) RETURN NUMBER IS
  v_total NUMBER;
  v_pay   NUMBER;
BEGIN
  SELECT SUM(NVL(ol.qty,0) * p.unit_price) INTO v_total
  FROM order_list ol, pizza p
  WHERE ol.pizza_id = p.pizza_id AND ol.order_no = p_ono;

  IF v_total IS NULL THEN
    RETURN 0;
  END IF;

  IF v_total > 10000 THEN
    v_pay := v_total * 0.80;
  ELSIF v_total > 5000 THEN
    v_pay := v_total * 0.90;
  ELSIF v_total > 2000 THEN
    v_pay := v_total * 0.95;
  ELSE
    v_pay := v_total;
  END IF;

  UPDATE orders SET total_amt = v_pay WHERE order_no = p_ono;
  RETURN v_pay;
END;
/

-- function has UPDATE, so call it from a block (not from SELECT ... FROM dual)
DECLARE
  amt NUMBER;
BEGIN
  amt := bill_amount('OP200');
  IF amt = 0 THEN
    DBMS_OUTPUT.PUT_LINE('No data for this order');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Amount to be paid: Rs.' || amt);
  END IF;
END;
/

SELECT * FROM orders;
COMMIT;
