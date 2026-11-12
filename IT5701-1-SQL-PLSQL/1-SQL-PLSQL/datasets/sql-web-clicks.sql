-- DATASET : web_clicks   (from web_clicks.csv)
-- Columns : click_id, user_id, country, device_type, page_category, click_time, session_id, duration_seconds
-- Run     : @"C:\path\sql-web-clicks.sql"

SET SERVEROUTPUT ON SIZE 1000000
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

------------------------------------------------------------
-- SQL QUERIES
------------------------------------------------------------
-- WHERE : checkout clicks
SELECT * FROM web_clicks WHERE page_category = 'Checkout';

-- WHERE + AND : mobile clicks from India
SELECT * FROM web_clicks WHERE device_type = 'Mobile' AND country = 'India';

-- DATE FILTER (TRUNC) : clicks on 1 Oct 2026
SELECT * FROM web_clicks WHERE TRUNC(click_time) = TO_DATE('2026-10-01','YYYY-MM-DD');

-- TO_CHAR (time) : clicks per hour
SELECT TO_CHAR(click_time,'HH24') hour_of_day, COUNT(*) FROM web_clicks
GROUP BY TO_CHAR(click_time,'HH24')
ORDER BY hour_of_day;

-- GROUP BY + COUNT : clicks per country
SELECT country, COUNT(*) clicks, SUM(duration_seconds) total_duration
FROM web_clicks
GROUP BY country
ORDER BY clicks DESC;

-- GROUP BY + AVG : average duration per device
SELECT device_type, ROUND(AVG(duration_seconds),2) avg_duration
FROM web_clicks
GROUP BY device_type;

-- GROUP BY : clicks per page category
SELECT page_category, COUNT(*) FROM web_clicks
GROUP BY page_category
ORDER BY COUNT(*) DESC;

-- GROUP BY : total time per session
SELECT session_id, COUNT(*) clicks, SUM(duration_seconds) total_seconds
FROM web_clicks
GROUP BY session_id;

-- HAVING : users with more than one click
SELECT user_id, COUNT(*) FROM web_clicks
GROUP BY user_id
HAVING COUNT(*) > 1;

-- HAVING : sessions longer than 100 seconds
SELECT session_id, SUM(duration_seconds) FROM web_clicks
GROUP BY session_id
HAVING SUM(duration_seconds) > 100;

-- SUBQUERY (AVG) : clicks longer than average
SELECT * FROM web_clicks
WHERE duration_seconds > (SELECT AVG(duration_seconds) FROM web_clicks);

-- CASE : engagement level
SELECT click_id, duration_seconds,
       CASE WHEN duration_seconds >= 60 THEN 'High'
            WHEN duration_seconds >= 30 THEN 'Medium'
            ELSE 'Low' END engagement
FROM web_clicks;

------------------------------------------------------------
-- PROCEDURE (IN, OUT) : total time of a session
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE web_session_time(p_sid IN VARCHAR2, p_total OUT NUMBER) IS
BEGIN
  SELECT SUM(duration_seconds) INTO p_total
  FROM web_clicks
  WHERE session_id = p_sid;
  IF p_total IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No clicks for ' || p_sid);
  END IF;
END;
/

DECLARE
  t NUMBER;
BEGIN
  web_session_time('S101', t);
  DBMS_OUTPUT.PUT_LINE('Total time of S101: ' || t || ' seconds');
END;
/

------------------------------------------------------------
-- FUNCTION : engagement level for a duration
------------------------------------------------------------
CREATE OR REPLACE FUNCTION web_engagement(p_dur IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  IF p_dur >= 60 THEN
    RETURN 'High';
  ELSIF p_dur >= 30 THEN
    RETURN 'Medium';
  ELSE
    RETURN 'Low';
  END IF;
END;
/

SELECT click_id, duration_seconds, web_engagement(duration_seconds) engagement FROM web_clicks;

------------------------------------------------------------
-- TRIGGER (BEFORE INSERT) : duration >= 0, valid device
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_web_check
BEFORE INSERT OR UPDATE ON web_clicks
FOR EACH ROW
BEGIN
  IF :NEW.duration_seconds < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Duration can not be negative');
  END IF;
  IF :NEW.device_type NOT IN ('Mobile','Desktop','Tablet') THEN
    RAISE_APPLICATION_ERROR(-20002, 'Invalid device type');
  END IF;
END;
/

INSERT INTO web_clicks VALUES ('C013','U109','India','Watch','Home',TO_DATE('2026-10-02 12:00:00','YYYY-MM-DD HH24:MI:SS'),'S109',30);
INSERT INTO web_clicks VALUES ('C014','U109','India','Mobile','Home',TO_DATE('2026-10-02 12:00:00','YYYY-MM-DD HH24:MI:SS'),'S109',30);
SELECT * FROM web_clicks WHERE click_id IN ('C013','C014');
ROLLBACK;

------------------------------------------------------------
-- CURSOR + USER EXCEPTION : bounce clicks (< 30 seconds)
------------------------------------------------------------
DECLARE
  CURSOR c IS SELECT * FROM web_clicks;
  bounce EXCEPTION;
BEGIN
  FOR r IN c LOOP
    BEGIN
      IF r.duration_seconds < 30 THEN
        RAISE bounce;
      END IF;
      DBMS_OUTPUT.PUT_LINE(r.click_id || '  ' || r.user_id || '  ' || r.page_category || '  ' || r.duration_seconds || 's');
    EXCEPTION
      WHEN bounce THEN
        DBMS_OUTPUT.PUT_LINE(r.click_id || '  ' || r.user_id || '  ' || r.page_category || '  ' || r.duration_seconds || 's  <-- BOUNCE');
    END;
  END LOOP;
END;
/

------------------------------------------------------------
-- IMPLICIT CURSOR : SQL%ROWCOUNT
------------------------------------------------------------
BEGIN
  DELETE FROM web_clicks WHERE duration_seconds < 30;
  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rows deleted');
  ROLLBACK;
END;
/
