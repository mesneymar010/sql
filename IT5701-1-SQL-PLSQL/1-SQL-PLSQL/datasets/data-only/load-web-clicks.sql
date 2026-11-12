-- DATASET : web_clicks   (from web_clicks.csv)
-- Columns : click_id, user_id, country, device_type, page_category, click_time, session_id, duration_seconds
-- Run     : @"C:\path\load-web-clicks.sql"

SET DEFINE OFF
SET LINESIZE 200
SET PAGESIZE 100
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

DROP TABLE web_clicks CASCADE CONSTRAINTS;

CREATE TABLE web_clicks (
  click_id                  VARCHAR2(20),
  user_id                   VARCHAR2(20),
  country                   VARCHAR2(20),
  device_type               VARCHAR2(20),
  page_category             VARCHAR2(20),
  click_time                DATE,
  session_id                VARCHAR2(20),
  duration_seconds          NUMBER(12),
  PRIMARY KEY (click_id)
);

INSERT INTO web_clicks VALUES ('C001', 'U101', 'India', 'Mobile', 'Home', TO_DATE('2026-10-01 09:00:00','YYYY-MM-DD HH24:MI:SS'), 'S101', 25);
INSERT INTO web_clicks VALUES ('C002', 'U101', 'India', 'Mobile', 'Products', TO_DATE('2026-10-01 09:01:10','YYYY-MM-DD HH24:MI:SS'), 'S101', 60);
INSERT INTO web_clicks VALUES ('C003', 'U102', 'USA', 'Desktop', 'Home', TO_DATE('2026-10-01 10:00:00','YYYY-MM-DD HH24:MI:SS'), 'S102', 35);
INSERT INTO web_clicks VALUES ('C004', 'U102', 'USA', 'Desktop', 'Checkout', TO_DATE('2026-10-01 10:02:00','YYYY-MM-DD HH24:MI:SS'), 'S102', 90);
INSERT INTO web_clicks VALUES ('C005', 'U103', 'India', 'Tablet', 'Products', TO_DATE('2026-10-01 11:10:00','YYYY-MM-DD HH24:MI:SS'), 'S103', 45);
INSERT INTO web_clicks VALUES ('C006', 'U104', 'UK', 'Mobile', 'Home', TO_DATE('2026-10-01 12:00:00','YYYY-MM-DD HH24:MI:SS'), 'S104', 20);
INSERT INTO web_clicks VALUES ('C007', 'U104', 'UK', 'Mobile', 'Products', TO_DATE('2026-10-01 12:01:00','YYYY-MM-DD HH24:MI:SS'), 'S104', 75);
INSERT INTO web_clicks VALUES ('C008', 'U105', 'India', 'Desktop', 'Checkout', TO_DATE('2026-10-01 13:15:00','YYYY-MM-DD HH24:MI:SS'), 'S105', 120);
INSERT INTO web_clicks VALUES ('C009', 'U106', 'USA', 'Mobile', 'Products', TO_DATE('2026-10-01 14:20:00','YYYY-MM-DD HH24:MI:SS'), 'S106', 55);
INSERT INTO web_clicks VALUES ('C010', 'U107', 'UK', 'Desktop', 'Home', TO_DATE('2026-10-01 15:00:00','YYYY-MM-DD HH24:MI:SS'), 'S107', 40);
INSERT INTO web_clicks VALUES ('C011', 'U108', 'India', 'Mobile', 'Blog', TO_DATE('2026-10-02 09:30:00','YYYY-MM-DD HH24:MI:SS'), 'S108', 32);
INSERT INTO web_clicks VALUES ('C012', 'U103', 'India', 'Tablet', 'Checkout', TO_DATE('2026-10-02 11:12:00','YYYY-MM-DD HH24:MI:SS'), 'S103', 85);
COMMIT;

SELECT * FROM web_clicks;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
