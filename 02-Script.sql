-- CREATE DATABASE FOR THE PROJECT
CREATE DATABASE  nyc_restaurant_inspection;


-- CONVERT THE DATASET TO RIGHT FORMAT

CREATE TABLE IF NOT EXISTS table_restaurant_inspection_dataset (
    "ID"                    SERIAL PRIMARY KEY,
    "CAMIS"                 bigint,
    "DBA"                   TEXT,
    "BORO"                  TEXT,
    "BUILDING"              TEXT,
    "STREET"                TEXT,
    "ZIPCODE"               numeric(8,0),
    "PHONE"                 TEXT,
    "CUISINE DESCRIPTION"   TEXT,
    "INSPECTION DATE"       date,
    "ACTION"                TEXT,
    "VIOLATION CODE"        TEXT,
    "VIOLATION DESCRIPTION" TEXT,
    "CRITICAL FLAG"         TEXT,
    "SCORE"                 numeric(5,2),
    "GRADE"                 varchar(2),
    "GRADE DATE"            date,
    "RECORD DATE"           date,
    "INSPECTION TYPE"       TEXT,
    "Latitude"              numeric(9,6),
    "Longitude"             numeric(9,6),
    "Community Board"       numeric(4,0),
    "Council District"      numeric(4,0),
    "Census Tract"          numeric(10,0),
    "BIN"                   numeric(9,0),
    "BBL"                   numeric(12,0),
    "NTA"                   TEXT,
    "Location Point1"       numeric(9,6)
);

INSERT INTO table_restaurant_inspection_dataset (
    "CAMIS",
    "DBA",
    "BORO",
    "BUILDING",
    "STREET",
    "ZIPCODE",
    "PHONE",
    "CUISINE DESCRIPTION",
    "INSPECTION DATE",
    "ACTION",
    "VIOLATION CODE",
    "VIOLATION DESCRIPTION",
    "CRITICAL FLAG",
    "SCORE",
    "GRADE",
    "GRADE DATE",
    "RECORD DATE",
    "INSPECTION TYPE",
    "Latitude",
    "Longitude",
    "Community Board",
    "Council District",
    "Census Tract",
    "BIN",
    "BBL",
    "NTA",
    "Location Point1"
)
SELECT
    "CAMIS",
    "DBA",
    "BORO",
    "BUILDING",
    "STREET",
    "ZIPCODE",
    "PHONE", -- Remove "_" and then cast to BIGINT
    "CUISINE DESCRIPTION",
    TO_DATE("INSPECTION DATE", 'MM/DD/YYYY'),
    "ACTION",
    "VIOLATION CODE",
    "VIOLATION DESCRIPTION",
    "CRITICAL FLAG",
    "SCORE",
    "GRADE",
    TO_DATE("GRADE DATE", 'MM/DD/YYYY'),
    TO_DATE("RECORD DATE", 'MM/DD/YYYY'),
    "INSPECTION TYPE",
    "Latitude",
    "Longitude",
    "Community Board",
    "Council District",
    "Census Tract",
    "BIN",
    "BBL",
    "NTA",
    "Location Point1"
FROM public.restaurant_inspection_dataset
WHERE "DBA" IS NOT NULL AND "VIOLATION CODE" IS NOT NULL
ORDER BY TO_DATE("INSPECTION DATE", 'MM/DD/YYYY');

SELECT * FROM table_restaurant_inspection_dataset;

-- TODO: TABLE ACTION TYPE
create table if not exists public.table_action_type
(
    id  serial primary key,
    type text
);

INSERT INTO table_action_type (type)
SELECT DISTINCT COALESCE("ACTION", NULL)
FROM public.table_restaurant_inspection_dataset
ORDER BY COALESCE("ACTION", NULL);

SELECT * FROM table_action_type;


-- TODO: TABLE GRADE TYPE

SELECT DISTINCT "GRADE"
from restaurant_inspection_dataset;

CREATE TABLE IF NOT EXISTS table_grade_type
(
    id    SERIAL PRIMARY KEY,
    type TEXT
);

INSERT INTO table_grade_type (type)
SELECT DISTINCT COALESCE("GRADE", NULL)
FROM public.table_restaurant_inspection_dataset
ORDER BY COALESCE("GRADE", NULL);

SELECT * FROM table_grade_type;

-- TODO: TABLE CRITICAL FLAG

CREATE TABLE table_critical_flag
(
    id    SERIAL PRIMARY KEY,
    flag TEXT
);

INSERT INTO table_critical_flag (flag)
SELECT DISTINCT COALESCE("CRITICAL FLAG",NULL)
FROM public.table_restaurant_inspection_dataset
ORDER BY COALESCE("CRITICAL FLAG",NULL);

SELECT * from table_critical_flag;
-- TODO: TABLE INSPECTION TYPE

SELECT DISTINCT "INSPECTION TYPE"
from restaurant_inspection_dataset;

CREATE TABLE table_inspection_type
(
    id              SERIAL PRIMARY KEY,
    type TEXT
);

INSERT INTO table_inspection_type (type)
SELECT DISTINCT COALESCE("INSPECTION TYPE", NULL)
FROM public.table_restaurant_inspection_dataset
ORDER BY COALESCE("INSPECTION TYPE", NULL);

SELECT * from table_inspection_type;
-- TODO: TABLE BOROUGH TYPE

CREATE TABLE IF NOT EXISTS table_borough
(
    id      SERIAL PRIMARY KEY,
    name TEXT
);

INSERT INTO table_borough (name)
SELECT DISTINCT COALESCE("BORO", NULL)
FROM public.table_restaurant_inspection_dataset
ORDER BY COALESCE("BORO", NULL);

SELECT *
FROM table_borough;


-- TODO: ADDRESS TABLE
-- SELECT COUNT(*)
-- FROM (SELECT DISTINCT "BUILDING", "STREET", "ZIPCODE", tb.id as "Borough Number", "Latitude", "Longitude"
--       FROM public.table_restaurant_inspection_dataset rid
--                LEFT JOIN table_borough tb on rid."BORO" = tb.name) AS subquery;

CREATE TABLE table_address (
    id      SERIAL PRIMARY KEY,
    BUILDING TEXT,
    STREET TEXT,
    ZIPCODE DOUBLE PRECISION,
    BOROUGH_ID INTEGER,
    Latitude  DOUBLE PRECISION,
    Longitude  DOUBLE PRECISION,
    CONSTRAINT fk_borough FOREIGN KEY (BOROUGH_ID) REFERENCES table_borough (id)
);

INSERT INTO table_address (BUILDING, STREET, ZIPCODE, BOROUGH_ID, Latitude, Longitude)
SELECT DISTINCT "BUILDING", "STREET", "ZIPCODE", tb.id as "Borough Number", "Latitude", "Longitude"
FROM public.table_restaurant_inspection_dataset rid
LEFT JOIN table_borough tb ON rid."BORO" = tb.name
ORDER BY "ZIPCODE";

SELECT * FROM table_address;

-- TODO : ======TABLE CUISINE TYPE=============================

CREATE TABLE IF NOT EXISTS table_cuisine
(
    id      SERIAL PRIMARY KEY,
    type   TEXT
);

INSERT INTO table_cuisine (type)
SELECT DISTINCT COALESCE("CUISINE DESCRIPTION", NULL)
FROM public.table_restaurant_inspection_dataset
ORDER BY COALESCE("CUISINE DESCRIPTION", NULL);

SELECT *
FROM table_cuisine;

-- TODO : ========TABLE VIOLATION===========================

CREATE TABLE IF NOT EXISTS table_violation (
    id SERIAL PRIMARY KEY,
    code TEXT,
    description TEXT
);

INSERT INTO table_violation (code, description)
SELECT DISTINCT "VIOLATION CODE", "VIOLATION DESCRIPTION"
FROM public.table_restaurant_inspection_dataset
WHERE "VIOLATION CODE" IS NOT NULL;


SELECT * FROM table_violation;

-- TODO : ======TABLE RESTAURANT INFO=============================

CREATE TABLE IF NOT EXISTS table_restaurant
(
    ID                  SERIAL PRIMARY KEY,
    CAMIS               bigint,
    DBA                 TEXT,
    PHONE               TEXT,
    ADDRESS_ID          INT,
    CUISINE_ID          INT,

    CONSTRAINT fk_address FOREIGN KEY (ADDRESS_ID) REFERENCES table_address (id),
    CONSTRAINT fk_cuisine FOREIGN KEY (CUISINE_ID) REFERENCES table_cuisine (id)
);

INSERT INTO table_restaurant (CAMIS, DBA, PHONE, ADDRESS_ID, CUISINE_ID)
SELECT
    r."CAMIS",
    r."DBA",
    r."PHONE",
    ta."id" as ADDRESS_ID,
    c."id" as CUISINE_ID
FROM
    table_restaurant_inspection_dataset r
    JOIN table_address ta
             ON r."BUILDING" = ta.BUILDING
             AND r."STREET" = ta."street"
             AND r."ZIPCODE" = ta."zipcode"
    JOIN table_cuisine c ON r."CUISINE DESCRIPTION" = c.type;

SELECT * FROM table_restaurant;



-- TODO : ===================================


-- TODO : ===================================



-- TODO: TABLE RESULTS

CREATE TABLE table_results (
    id    SERIAL PRIMARY KEY,
    refer_id INT,
    action_id INT ,
    critical_flag_id INT ,
    grade_type_id INT ,
    "SCORE" DOUBLE PRECISION,
    FOREIGN KEY (action_id) REFERENCES table_action_type (id),
    FOREIGN KEY (critical_flag_id) REFERENCES table_critical_flag (id),
    FOREIGN KEY (grade_type_id) REFERENCES table_grade_type (id)
);

INSERT INTO table_results
    (refer_id,action_id, critical_flag_id, grade_type_id,  "SCORE")
SELECT
        rid."ID" as refer_id,
        a.id AS action_id, cf.id AS critical_flag_id, gt.id AS grade_type_id,  "SCORE"
    FROM table_restaurant_inspection_dataset rid
    LEFT JOIN table_action_type a ON rid."ACTION" = a.type
    LEFT JOIN table_critical_flag cf ON rid."CRITICAL FLAG" = cf.flag
    LEFT JOIN table_grade_type gt ON rid."GRADE" = gt.type;

SELECT count(*) FROM table_results;


-- TODO : TABLE FOR INSPECTION

CREATE TABLE table_inspection
(
    ID                  SERIAL PRIMARY KEY,
    RESTAURANT_INFO     INT,
    VIOLATION_ID INT,
    INSPECTION_TYPE_ID INT,
    "INSPECTION DATE" text,
    "GRADE DATE" text,
    INSPECTION_RESULT int,
    CONSTRAINT fk_restaurant_info FOREIGN KEY (RESTAURANT_INFO) REFERENCES table_restaurant (id),
    CONSTRAINT fk_violation FOREIGN KEY (VIOLATION_ID) REFERENCES table_violation (id),
    CONSTRAINT fk_inspection_result FOREIGN KEY (INSPECTION_RESULT) REFERENCES table_results (id),
    CONSTRAINT fk_inspection_type FOREIGN KEY (INSPECTION_TYPE_ID) REFERENCES table_inspection (id)
);

INSERT INTO table_inspection (
    RESTAURANT_INFO,
    VIOLATION_ID,
    INSPECTION_TYPE_ID,
    "INSPECTION DATE",
    "GRADE DATE",
    INSPECTION_RESULT
)
SELECT
    ri.id,
    V.id,
    it.id,
    M."INSPECTION DATE",
    M."GRADE DATE",
   IR.ID as "INSPECTION RESULT"
FROM public.table_restaurant_inspection_dataset M
LEFT JOIN table_restaurant ri ON M."CAMIS" = ri.CAMIS
LEFT JOIN table_violation V ON M."VIOLATION CODE" = V.code
LEFT JOIN table_inspection_type it ON M."INSPECTION TYPE" = it.type
LEFT JOIN table_results IR ON  M."ID" = IR.refer_id
WHERE M."DBA" IS NOT NULL;

SELECT * from table_inspection;