-- DATASET : shipment_records   (from shipment_records.csv)
-- Columns : shipment_id, customer_id, source_city, destination_city, transport_mode, weight_kg, shipping_cost, delivery_status
-- Run     : @"C:\path\load-shipment-records.sql"

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
