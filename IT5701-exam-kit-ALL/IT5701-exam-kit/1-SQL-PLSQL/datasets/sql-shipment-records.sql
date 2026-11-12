-- DATASET : shipment_records   (from shipment_records.csv)
-- Columns : shipment_id, customer_id, source_city, destination_city, transport_mode, weight_kg, shipping_cost, delivery_status
-- Run     : @"C:\path\sql-shipment-records.sql"

SET SERVEROUTPUT ON SIZE 1000000
SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE shipment_records CASCADE CONSTRAINTS;

CREATE TABLE shipment_records (
  shipment_id               VARCHAR2(20),
  customer_id               VARCHAR2(20),
  source_city               VARCHAR2(20),
  destination_city          VARCHAR2(20),
  transport_mode            VARCHAR2(20),
  weight_kg                 NUMBER(12),
  shipping_cost             NUMBER(12),
  delivery_status           VARCHAR2(20),
  PRIMARY KEY (shipment_id)
);

INSERT INTO shipment_records VALUES ('SH001', 'CU301', 'Chennai', 'Bengaluru', 'Road', 120, 4500, 'Delivered');
INSERT INTO shipment_records VALUES ('SH002', 'CU302', 'Coimbatore', 'Chennai', 'Rail', 350, 2800, 'In Transit');
INSERT INTO shipment_records VALUES ('SH003', 'CU303', 'Madurai', 'Trichy', 'Road', 80, 1600, 'Delivered');
INSERT INTO shipment_records VALUES ('SH004', 'CU301', 'Chennai', 'Hyderabad', 'Air', 45, 6200, 'Delayed');
INSERT INTO shipment_records VALUES ('SH005', 'CU304', 'Salem', 'Bengaluru', 'Road', 210, 3900, 'Delivered');
INSERT INTO shipment_records VALUES ('SH006', 'CU305', 'Trichy', 'Chennai', 'Rail', 400, 3000, 'In Transit');
INSERT INTO shipment_records VALUES ('SH007', 'CU306', 'Erode', 'Madurai', 'Road', 65, 1400, 'Delivered');
INSERT INTO shipment_records VALUES ('SH008', 'CU302', 'Coimbatore', 'Hyderabad', 'Air', 30, 5100, 'Delivered');
INSERT INTO shipment_records VALUES ('SH009', 'CU307', 'Chennai', 'Mumbai', 'Road', 180, 4700, 'Delayed');
INSERT INTO shipment_records VALUES ('SH010', 'CU308', 'Madurai', 'Bengaluru', 'Rail', 320, 2600, 'Delivered');
COMMIT;

SELECT * FROM shipment_records;

------------------------------------------------------------
-- SQL QUERIES
------------------------------------------------------------
-- WHERE : delayed shipments
SELECT * FROM shipment_records WHERE delivery_status = 'Delayed';

-- WHERE + OR : from Chennai or by Air
SELECT * FROM shipment_records WHERE source_city = 'Chennai' OR transport_mode = 'Air';

-- CONCAT || : route of each shipment
SELECT shipment_id, source_city || ' -> ' || destination_city route, transport_mode
FROM shipment_records;

-- GROUP BY + COUNT : shipments per status
SELECT delivery_status, COUNT(*) FROM shipment_records
GROUP BY delivery_status;

-- GROUP BY + SUM/AVG : cost and weight per transport mode
SELECT transport_mode, COUNT(*), SUM(shipping_cost) total_cost, SUM(weight_kg) total_weight,
       ROUND(SUM(shipping_cost) / SUM(weight_kg), 2) cost_per_kg
FROM shipment_records
GROUP BY transport_mode;

-- GROUP BY : shipments per destination
SELECT destination_city, COUNT(*) FROM shipment_records
GROUP BY destination_city
ORDER BY COUNT(*) DESC;

-- HAVING : customers with more than one shipment
SELECT customer_id, COUNT(*), SUM(shipping_cost) FROM shipment_records
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- SUBQUERY (AVG) : cost above average
SELECT * FROM shipment_records
WHERE shipping_cost > (SELECT AVG(shipping_cost) FROM shipment_records);

-- SUBQUERY (MAX) : heaviest shipment
SELECT * FROM shipment_records
WHERE weight_kg = (SELECT MAX(weight_kg) FROM shipment_records);

-- CASE : weight class
SELECT shipment_id, weight_kg,
       CASE WHEN weight_kg >= 300 THEN 'Heavy'
            WHEN weight_kg >= 100 THEN 'Medium'
            ELSE 'Light' END weight_class
FROM shipment_records;

------------------------------------------------------------
-- PROCEDURE (IN, OUT) : total cost for a transport mode
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ship_mode_cost(p_mode IN VARCHAR2, p_total OUT NUMBER) IS
BEGIN
  SELECT SUM(shipping_cost) INTO p_total
  FROM shipment_records
  WHERE transport_mode = p_mode;
  IF p_total IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No shipments by ' || p_mode);
  END IF;
END;
/

DECLARE
  t NUMBER;
BEGIN
  ship_mode_cost('Road', t);
  DBMS_OUTPUT.PUT_LINE('Total Road cost: Rs.' || t);
END;
/

------------------------------------------------------------
-- FUNCTION : cost per kg of a shipment (SELECT INTO + NO_DATA_FOUND)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION ship_cost_per_kg(p_sid IN VARCHAR2) RETURN NUMBER IS
  v_cost   NUMBER;
  v_weight NUMBER;
BEGIN
  SELECT shipping_cost, weight_kg INTO v_cost, v_weight
  FROM shipment_records WHERE shipment_id = p_sid;
  RETURN ROUND(v_cost / v_weight, 2);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/

SELECT shipment_id, ship_cost_per_kg(shipment_id) cost_per_kg FROM shipment_records;

------------------------------------------------------------
-- TRIGGER (BEFORE INSERT) : weight > 0, source <> destination, valid status
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_ship_check
BEFORE INSERT OR UPDATE ON shipment_records
FOR EACH ROW
BEGIN
  IF :NEW.weight_kg <= 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Weight must be greater than 0');
  END IF;
  IF :NEW.source_city = :NEW.destination_city THEN
    RAISE_APPLICATION_ERROR(-20002, 'Source and destination can not be same');
  END IF;
  IF :NEW.delivery_status NOT IN ('Delivered','In Transit','Delayed') THEN
    RAISE_APPLICATION_ERROR(-20003, 'Invalid delivery status');
  END IF;
END;
/

INSERT INTO shipment_records VALUES ('SH011','CU309','Chennai','Chennai','Road',100,2000,'Delivered');
INSERT INTO shipment_records VALUES ('SH012','CU309','Chennai','Salem','Road',100,2000,'Lost');
INSERT INTO shipment_records VALUES ('SH013','CU309','Chennai','Salem','Road',100,2000,'In Transit');
SELECT * FROM shipment_records WHERE shipment_id IN ('SH011','SH012','SH013');
ROLLBACK;

------------------------------------------------------------
-- CURSOR + USER EXCEPTION : delayed shipments alert
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT * FROM shipment_records;
  late_shipment EXCEPTION;
BEGIN
  FOR r IN c LOOP
    BEGIN
      IF r.delivery_status = 'Delayed' THEN
        RAISE late_shipment;
      END IF;
      DBMS_OUTPUT.PUT_LINE(r.shipment_id || '  ' || r.source_city || ' -> ' || r.destination_city || '  ' || r.delivery_status);
    EXCEPTION
      WHEN late_shipment THEN
        DBMS_OUTPUT.PUT_LINE(r.shipment_id || '  ' || r.source_city || ' -> ' || r.destination_city || '  <-- DELAYED');
    END;
  END LOOP;
END;
/

------------------------------------------------------------
-- IMPLICIT CURSOR : mark in-transit as delivered
------------------------------------------------------------
BEGIN
  UPDATE shipment_records SET delivery_status = 'Delivered' WHERE delivery_status = 'In Transit';
  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' shipments updated');
  ROLLBACK;
END;
/
