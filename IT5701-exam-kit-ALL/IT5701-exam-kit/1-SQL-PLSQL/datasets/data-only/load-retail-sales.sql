-- DATASET : retail_sales   (from retail_sales.csv)
-- Columns : order_id, customer_id, product_id, category, quantity, unit_price, region
-- Run     : @"C:\path\load-retail-sales.sql"

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
