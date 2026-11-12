-- DATASET : pharmacy_inventory   (from pharmacy_inventory.csv)
-- Columns : medicine_id, medicine_name, category, supplier_id, unit_price, stock_quantity, reorder_level
-- Run     : @"C:\path\load-pharmacy-inventory.sql"

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
