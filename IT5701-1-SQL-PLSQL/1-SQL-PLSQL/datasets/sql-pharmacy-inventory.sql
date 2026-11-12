-- DATASET : pharmacy_inventory   (from pharmacy_inventory.csv)
-- Columns : medicine_id, medicine_name, category, supplier_id, unit_price, stock_quantity, reorder_level
-- Run     : @"C:\path\sql-pharmacy-inventory.sql"

SET SERVEROUTPUT ON SIZE 1000000
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE pharmacy_inventory CASCADE CONSTRAINTS;

CREATE TABLE pharmacy_inventory (
  medicine_id               VARCHAR2(20),
  medicine_name             VARCHAR2(20),
  category                  VARCHAR2(20),
  supplier_id               VARCHAR2(20),
  unit_price                NUMBER(12,2),
  stock_quantity            NUMBER(12),
  reorder_level             NUMBER(12),
  PRIMARY KEY (medicine_id)
);

INSERT INTO pharmacy_inventory VALUES ('M101', 'Paracetamol', 'Analgesic', 'SUP01', 2.5, 500, 100);
INSERT INTO pharmacy_inventory VALUES ('M102', 'Amoxicillin', 'Antibiotic', 'SUP02', 8.0, 75, 100);
INSERT INTO pharmacy_inventory VALUES ('M103', 'Cetirizine', 'Antihistamine', 'SUP01', 3.5, 180, 50);
INSERT INTO pharmacy_inventory VALUES ('M104', 'Metformin', 'Antidiabetic', 'SUP03', 6.0, 90, 120);
INSERT INTO pharmacy_inventory VALUES ('M105', 'Amlodipine', 'Antihypertensive', 'SUP02', 4.5, 45, 60);
INSERT INTO pharmacy_inventory VALUES ('M106', 'Omeprazole', 'Gastrointestinal', 'SUP04', 5.0, 130, 80);
INSERT INTO pharmacy_inventory VALUES ('M107', 'Ibuprofen', 'Analgesic', 'SUP01', 3.0, 40, 75);
INSERT INTO pharmacy_inventory VALUES ('M108', 'Azithromycin', 'Antibiotic', 'SUP03', 12.0, 55, 70);
INSERT INTO pharmacy_inventory VALUES ('M109', 'ORS Sachet', 'Electrolyte', 'SUP04', 1.5, 300, 100);
INSERT INTO pharmacy_inventory VALUES ('M110', 'Vitamin C', 'Supplement', 'SUP02', 2.0, 65, 80);
COMMIT;

SELECT * FROM pharmacy_inventory;

------------------------------------------------------------
-- SQL QUERIES
------------------------------------------------------------
-- COLUMN COMPARE : medicines to reorder (stock below reorder level)
SELECT * FROM pharmacy_inventory WHERE stock_quantity < reorder_level;

-- LIKE : medicine names starting with A
SELECT * FROM pharmacy_inventory WHERE medicine_name LIKE 'A%';

-- CALCULATED COLUMN : stock value of each medicine
SELECT medicine_id, medicine_name, unit_price, stock_quantity, unit_price * stock_quantity stock_value
FROM pharmacy_inventory
ORDER BY stock_value DESC;

-- GROUP BY + SUM : total stock value per supplier
SELECT supplier_id, SUM(unit_price * stock_quantity) total_value, COUNT(*) no_of_items
FROM pharmacy_inventory
GROUP BY supplier_id;

-- GROUP BY + COUNT/AVG : per category
SELECT category, COUNT(*), AVG(unit_price), SUM(stock_quantity)
FROM pharmacy_inventory
GROUP BY category;

-- HAVING : categories with more than one medicine
SELECT category, COUNT(*) FROM pharmacy_inventory
GROUP BY category
HAVING COUNT(*) > 1;

-- SUBQUERY (MAX) : costliest medicine
SELECT * FROM pharmacy_inventory
WHERE unit_price = (SELECT MAX(unit_price) FROM pharmacy_inventory);

-- SUBQUERY (AVG) : price above average
SELECT * FROM pharmacy_inventory
WHERE unit_price > (SELECT AVG(unit_price) FROM pharmacy_inventory);

-- CASE : stock status
SELECT medicine_name, stock_quantity, reorder_level,
       CASE WHEN stock_quantity < reorder_level THEN 'Reorder' ELSE 'OK' END status
FROM pharmacy_inventory;

-- UPDATE : increase antibiotic price by 10%
UPDATE pharmacy_inventory SET unit_price = unit_price * 1.10 WHERE category = 'Antibiotic';
SELECT * FROM pharmacy_inventory WHERE category = 'Antibiotic';
ROLLBACK;

------------------------------------------------------------
-- PROCEDURE (IN, OUT) : total stock value of a supplier
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pharm_supplier_value(p_sup IN VARCHAR2, p_val OUT NUMBER) IS
BEGIN
  SELECT SUM(unit_price * stock_quantity) INTO p_val
  FROM pharmacy_inventory
  WHERE supplier_id = p_sup;
  IF p_val IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No items for ' || p_sup);
  END IF;
END;
/

DECLARE
  v NUMBER;
BEGIN
  pharm_supplier_value('SUP01', v);
  DBMS_OUTPUT.PUT_LINE('Stock value of SUP01: Rs.' || v);
END;
/

------------------------------------------------------------
-- FUNCTION : stock status of a medicine (SELECT INTO + NO_DATA_FOUND)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION pharm_stock_status(p_mid IN VARCHAR2) RETURN VARCHAR2 IS
  v_stock pharmacy_inventory.stock_quantity%TYPE;
  v_level pharmacy_inventory.reorder_level%TYPE;
BEGIN
  SELECT stock_quantity, reorder_level INTO v_stock, v_level
  FROM pharmacy_inventory WHERE medicine_id = p_mid;
  IF v_stock < v_level THEN
    RETURN 'Reorder';
  ELSE
    RETURN 'OK';
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'Medicine not found';
END;
/

SELECT medicine_id, medicine_name, pharm_stock_status(medicine_id) status FROM pharmacy_inventory;

------------------------------------------------------------
-- TRIGGER (BEFORE INSERT/UPDATE) : stock can't be negative, price > 0
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_pharm_check
BEFORE INSERT OR UPDATE ON pharmacy_inventory
FOR EACH ROW
BEGIN
  IF :NEW.stock_quantity < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Stock can not be negative');
  END IF;
  IF :NEW.unit_price <= 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Price must be greater than 0');
  END IF;
END;
/

UPDATE pharmacy_inventory SET stock_quantity = stock_quantity - 100 WHERE medicine_id = 'M107';
INSERT INTO pharmacy_inventory VALUES ('M111','Dolo 650','Analgesic','SUP01',3.0,200,50);
SELECT * FROM pharmacy_inventory WHERE medicine_id IN ('M107','M111');
ROLLBACK;

------------------------------------------------------------
-- CURSOR + USER EXCEPTION : low stock alert
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT * FROM pharmacy_inventory;
  low_stock EXCEPTION;
BEGIN
  FOR r IN c LOOP
    BEGIN
      IF r.stock_quantity < r.reorder_level THEN
        RAISE low_stock;
      END IF;
      DBMS_OUTPUT.PUT_LINE(r.medicine_name || '  stock ' || r.stock_quantity || '  OK');
    EXCEPTION
      WHEN low_stock THEN
        DBMS_OUTPUT.PUT_LINE(r.medicine_name || '  stock ' || r.stock_quantity || '  <-- REORDER (level ' || r.reorder_level || ')');
    END;
  END LOOP;
END;
/

------------------------------------------------------------
-- IMPLICIT CURSOR : restock items below reorder level
------------------------------------------------------------
BEGIN
  UPDATE pharmacy_inventory SET stock_quantity = stock_quantity + 100 WHERE stock_quantity < reorder_level;
  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' medicines restocked');
  ROLLBACK;
END;
/
