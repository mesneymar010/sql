# CSV -> Oracle CREATE TABLE + INSERT statements (Oracle 10g compatible)
# Usage (cmd):  py csv_to_sql.py data.csv > data.sql
#               py csv_to_sql.py data.csv my_table > data.sql
# Then in SQL*Plus:  @"C:\path\data.sql"
# Dates: 2026-10-01 and 2026-10-01 09:00:00 are detected. 05/01/2024 is read as DD/MM/YYYY.

import csv
import os
import re
import sys

RESERVED = set("""ACCESS ADD ALL ALTER AND ANY AS ASC AUDIT BETWEEN BY CHAR CHECK CLUSTER COLUMN
COMMENT COMPRESS CONNECT CREATE CURRENT DATE DECIMAL DEFAULT DELETE DESC DISTINCT DROP ELSE
EXCLUSIVE EXISTS FILE FLOAT FOR FROM GRANT GROUP HAVING IDENTIFIED IMMEDIATE IN INCREMENT INDEX
INITIAL INSERT INTEGER INTERSECT INTO IS LEVEL LIKE LOCK LONG MAXEXTENTS MINUS MLSLABEL MODE
MODIFY NOAUDIT NOCOMPRESS NOT NOWAIT NULL NUMBER OF OFFLINE ON ONLINE OPTION OR ORDER PCTFREE
PRIOR PRIVILEGES PUBLIC RAW RENAME RESOURCE REVOKE ROW ROWID ROWNUM ROWS SELECT SESSION SET
SHARE SIZE SMALLINT START SUCCESSFUL SYNONYM SYSDATE TABLE THEN TO TRIGGER UID UNION UNIQUE
UPDATE USER VALIDATE VALUES VARCHAR VARCHAR2 VIEW WHENEVER WHERE WITH""".split())

DATE_FORMATS = [
    (r"^\d{4}-\d{2}-\d{2}$", "YYYY-MM-DD"),
    (r"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$", "YYYY-MM-DD HH24:MI:SS"),
    (r"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$", "YYYY-MM-DD HH24:MI"),
    (r"^\d{2}-\d{2}-\d{4}$", "DD-MM-YYYY"),
    (r"^\d{2}/\d{2}/\d{4}$", "DD/MM/YYYY"),
]


def clean_name(name):
    name = re.sub(r"[^A-Za-z0-9_]", "_", name.strip()).strip("_").lower()
    if not name:
        name = "col"
    if name[0].isdigit():
        name = "c_" + name
    if name.upper() in RESERVED:
        name = name + "_col"
    return name[:30]


def is_int(v):
    return re.match(r"^-?\d+$", v) is not None and not (len(v.lstrip("-")) > 1 and v.lstrip("-")[0] == "0")


def is_dec(v):
    return re.match(r"^-?\d*\.\d+$", v) is not None


def col_type(values):
    vals = [v for v in values if v != ""]
    if not vals:
        return "VARCHAR2(50)", None
    if all(is_int(v) for v in vals):
        return "NUMBER(12)", None
    if all(is_int(v) or is_dec(v) for v in vals):
        return "NUMBER(12,2)", None
    for pattern, fmt in DATE_FORMATS:
        if all(re.match(pattern, v) for v in vals):
            return "DATE", fmt
    size = max(len(v) for v in vals)
    size = max(20, ((size + 9) // 10) * 10)
    return "VARCHAR2(%d)" % size, None


def sql_value(v, ctype, fmt):
    if v == "":
        return "NULL"
    if ctype.startswith("NUMBER"):
        return v
    if ctype == "DATE":
        return "TO_DATE('%s','%s')" % (v, fmt)
    return "'" + v.replace("'", "''") + "'"


def main():
    if len(sys.argv) < 2:
        print("Usage: py csv_to_sql.py file.csv [table_name]")
        return
    path = sys.argv[1]
    table = clean_name(sys.argv[2] if len(sys.argv) > 2 else os.path.splitext(os.path.basename(path))[0])

    with open(path, newline="", encoding="utf-8-sig") as f:
        rows = [r for r in csv.reader(f) if any(c.strip() for c in r)]
    header = [clean_name(h) for h in rows[0]]
    data = [[c.strip() for c in r] + [""] * (len(header) - len(r)) for r in rows[1:]]

    types = [col_type([r[i] for r in data]) for i in range(len(header))]

    pk = None
    first = [r[0] for r in data]
    if "" not in first and len(set(first)) == len(first):
        pk = header[0]
    elif len(header) > 1:
        for j in range(1, len(header)):
            pair = [(r[0], r[j]) for r in data]
            if len(set(pair)) == len(pair):
                pk = header[0] + ", " + header[j]
                break

    print("SET DEFINE OFF")
    print("SET LINESIZE 200")
    print("SET PAGESIZE 100")
    print("ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';")
    print("")
    print("DROP TABLE %s CASCADE CONSTRAINTS;" % table)
    print("")
    print("CREATE TABLE %s (" % table)
    lines = ["  %-25s %s" % (h, t[0]) for h, t in zip(header, types)]
    if pk:
        lines.append("  PRIMARY KEY (%s)" % pk)
    print(",\n".join(lines))
    print(");")
    print("")
    for r in data:
        vals = [sql_value(r[i], types[i][0], types[i][1]) for i in range(len(header))]
        print("INSERT INTO %s VALUES (%s);" % (table, ", ".join(vals)))
    print("COMMIT;")
    print("")
    print("SELECT * FROM %s;" % table)


main()
