-- DATASET : retail_sales   (from retail_sales.csv)
-- Columns : order_id, customer_id, product_id, category, quantity, unit_price, region
-- Run     : @"C:\path\sql-retail-sales.sql"

SET SERVEROUTPUT ON SIZE 1000000
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE retail_sales CASCADE CONSTRAINTS;

CREATE TABLE retail_sales (
  order_id                  VARCHAR2(20),
  customer_id               VARCHAR2(20),
  product_id                VARCHAR2(20),
  category                  VARCHAR2(20),
  quantity                  NUMBER(12),
  unit_price                NUMBER(12),
  region                    VARCHAR2(20),
  PRIMARY KEY (order_id)
);

INSERT INTO retail_sales VALUES ('O1001', 'CU101', 'PR101', 'Electronics', 2, 15000, 'Chennai');
INSERT INTO retail_sales VALUES ('O1002', 'CU102', 'PR102', 'Clothing', 3, 1200, 'Coimbatore');
INSERT INTO retail_sales VALUES ('O1003', 'CU103', 'PR103', 'Grocery', 10, 150, 'Madurai');
INSERT INTO retail_sales VALUES ('O1004', 'CU101', 'PR104', 'Electronics', 1, 22000, 'Chennai');
INSERT INTO retail_sales VALUES ('O1005', 'CU104', 'PR105', 'Clothing', 2, 1800, 'Trichy');
INSERT INTO retail_sales VALUES ('O1006', 'CU105', 'PR106', 'Home', 4, 2500, 'Salem');
INSERT INTO retail_sales VALUES ('O1007', 'CU102', 'PR101', 'Electronics', 1, 15000, 'Coimbatore');
INSERT INTO retail_sales VALUES ('O1008', 'CU106', 'PR103', 'Grocery', 8, 150, 'Chennai');
INSERT INTO retail_sales VALUES ('O1009', 'CU107', 'PR107', 'Home', 2, 4200, 'Madurai');
INSERT INTO retail_sales VALUES ('O1010', 'CU103', 'PR105', 'Clothing', 1, 1800, 'Madurai');
INSERT INTO retail_sales VALUES ('O1011', 'CU108', 'PR104', 'Electronics', 1, 22000, 'Trichy');
INSERT INTO retail_sales VALUES ('O1012', 'CU105', 'PR106', 'Home', 2, 2500, 'Salem');
COMMIT;

SELECT * FROM retail_sales;

------------------------------------------------------------
-- SQL QUERIES
------------------------------------------------------------
-- WHERE : electronics orders
SELECT * FROM retail_sales WHERE category = 'Electronics';

-- CALCULATED COLUMN : amount of each order
SELECT order_id, customer_id, category, quantity, unit_price, quantity * unit_price amount
FROM retail_sales
ORDER BY amount DESC;

-- GROUP BY + SUM : revenue per category
SELECT category, SUM(quantity * unit_price) revenue, SUM(quantity) total_qty
FROM retail_sales
GROUP BY category
ORDER BY revenue DESC;

-- GROUP BY + SUM : revenue per region
SELECT region, SUM(quantity * unit_price) revenue, COUNT(*) no_of_orders
FROM retail_sales
GROUP BY region
ORDER BY revenue DESC;

-- GROUP BY : total spend per customer
SELECT customer_id, SUM(quantity * unit_price) total_spend
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spend DESC;

-- HAVING COUNT : customers with more than one order
SELECT customer_id, COUNT(*) FROM retail_sales
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- HAVING SUM : categories with revenue above 20000
SELECT category, SUM(quantity * unit_price) FROM retail_sales
GROUP BY category
HAVING SUM(quantity * unit_price) > 20000;

-- SUBQUERY (AVG) : orders above average amount
SELECT * FROM retail_sales
WHERE quantity * unit_price > (SELECT AVG(quantity * unit_price) FROM retail_sales);

-- SUBQUERY WITH GROUP : best selling product by quantity
SELECT product_id, SUM(quantity) FROM retail_sales
GROUP BY product_id
HAVING SUM(quantity) = (SELECT MAX(SUM(quantity)) FROM retail_sales GROUP BY product_id);

-- TOP N (ROWNUM) : top 3 orders by amount
SELECT * FROM (SELECT order_id, customer_id, quantity * unit_price amount FROM retail_sales ORDER BY amount DESC)
WHERE ROWNUM <= 3;

-- CASE : order size
SELECT order_id, quantity * unit_price amount,
       CASE WHEN quantity * unit_price >= 20000 THEN 'Large'
            WHEN quantity * unit_price >= 5000 THEN 'Medium'
            ELSE 'Small' END order_size
FROM retail_sales;

------------------------------------------------------------
-- PROCEDURE (IN, OUT) : total spend of a customer
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE retail_cust_spend(p_cust IN VARCHAR2, p_total OUT NUMBER) IS
BEGIN
  SELECT SUM(quantity * unit_price) INTO p_total
  FROM retail_sales
  WHERE customer_id = p_cust;
  IF p_total IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No orders for ' || p_cust);
  END IF;
END;
/

DECLARE
  t NUMBER;
BEGIN
  retail_cust_spend('CU101', t);
  DBMS_OUTPUT.PUT_LINE('Total spend of CU101: Rs.' || t);
END;
/

------------------------------------------------------------
-- FUNCTION : bill amount after discount (10% if >= 20000, 5% if >= 5000)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION retail_bill(p_oid IN VARCHAR2) RETURN NUMBER IS
  v_amt NUMBER;
BEGIN
  SELECT quantity * unit_price INTO v_amt FROM retail_sales WHERE order_id = p_oid;
  IF v_amt >= 20000 THEN
    RETURN v_amt * 0.90;
  ELSIF v_amt >= 5000 THEN
    RETURN v_amt * 0.95;
  ELSE
    RETURN v_amt;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/

SELECT order_id, quantity * unit_price amount, retail_bill(order_id) to_pay FROM retail_sales;

------------------------------------------------------------
-- TRIGGER (BEFORE INSERT) : quantity and price must be > 0
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_retail_check
BEFORE INSERT OR UPDATE ON retail_sales
FOR EACH ROW
BEGIN
  IF :NEW.quantity <= 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Quantity must be greater than 0');
  END IF;
  IF :NEW.unit_price <= 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Price must be greater than 0');
  END IF;
END;
/

INSERT INTO retail_sales VALUES ('O1013','CU109','PR108','Grocery',0,150,'Chennai');
INSERT INTO retail_sales VALUES ('O1014','CU109','PR108','Grocery',5,150,'Chennai');
SELECT * FROM retail_sales WHERE order_id IN ('O1013','O1014');
ROLLBACK;

------------------------------------------------------------
-- CURSOR + USER EXCEPTION : premium orders (>= 20000)
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT order_id, customer_id, quantity * unit_price amount FROM retail_sales;
  premium EXCEPTION;
BEGIN
  FOR r IN c LOOP
    BEGIN
      IF r.amount >= 20000 THEN
        RAISE premium;
      END IF;
      DBMS_OUTPUT.PUT_LINE(r.order_id || '  ' || r.customer_id || '  ' || r.amount);
    EXCEPTION
      WHEN premium THEN
        DBMS_OUTPUT.PUT_LINE(r.order_id || '  ' || r.customer_id || '  ' || r.amount || '  <-- PREMIUM ORDER');
    END;
  END LOOP;
END;
/

------------------------------------------------------------
-- IMPLICIT CURSOR : SQL%ROWCOUNT
------------------------------------------------------------
BEGIN
  UPDATE retail_sales SET unit_price = unit_price * 0.95 WHERE category = 'Clothing';
  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rows updated');
  ROLLBACK;
END;
/
