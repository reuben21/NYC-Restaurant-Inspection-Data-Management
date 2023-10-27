SELECT COUNT(*)
FROM (SELECT *
      from public.table_restaurant_inspection_dataset
      WHERE "DBA" IS NOT NULL) AS subquery;

SELECT *
from public.table_restaurant_inspection_dataset;



-- TODO: TABLE BOROUGH TYPE

CREATE TABLE table_borough
(
    id      SERIAL PRIMARY KEY,
    borough TEXT
);

INSERT INTO table_borough (borough)
SELECT DISTINCT COALESCE("BORO", NULL)
FROM public.table_restaurant_inspection_dataset
ORDER BY COALESCE("BORO", NULL);

SELECT *
FROM table_borough;
-- TODO: ==============================================

-- TODO: ADDRESS TABLE
SELECT COUNT(*)
FROM (SELECT DISTINCT "BUILDING", "STREET", "ZIPCODE", tb.id as "Borough Number", "Latitude", "Longitude"
      FROM public.table_restaurant_inspection_dataset rid
               LEFT JOIN table_borough tb on rid."BORO" = tb.borough) AS subquery;

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
LEFT JOIN table_borough tb ON rid."BORO" = tb.borough
ORDER BY "ZIPCODE";

CREATE INDEX idx_location
ON table_address (building, street, zipcode, BOROUGH_ID, latitude, longitude);

SELECT * from table_address;
-- TODO: ==============================================

-- TODO: TABLE ACTION TYPE
create table public.table_action_type
(
    id  serial primary key,
    action text
);

INSERT INTO table_action_type (action)
SELECT DISTINCT COALESCE("ACTION", NULL)
FROM public.table_restaurant_inspection_dataset
ORDER BY COALESCE("ACTION", NULL);

SELECT * FROM table_action_type;

-- TODO: TABLE INSPECTION TYPE

SELECT DISTINCT "INSPECTION TYPE"
from restaurant_inspection_dataset;

CREATE TABLE table_inspection_type
(
    id              SERIAL PRIMARY KEY,
    inspection_type TEXT
);

INSERT INTO table_inspection_type (inspection_type)
SELECT DISTINCT COALESCE("INSPECTION TYPE", NULL)
FROM public.table_restaurant_inspection_dataset
ORDER BY COALESCE("INSPECTION TYPE", NULL);

SELECT * from table_inspection_type;

-- TODO: TABLE GRADE TYPE

SELECT DISTINCT "GRADE"
from restaurant_inspection_dataset;

CREATE TABLE table_grade_type
(
    id    SERIAL PRIMARY KEY,
    grade TEXT
);

INSERT INTO table_grade_type (grade)
SELECT DISTINCT COALESCE("GRADE", NULL)
FROM public.table_restaurant_inspection_dataset
ORDER BY COALESCE("GRADE", NULL);

SELECT * FROM table_grade_type;

-- TODO: TABLE CRITICAL FLAG

CREATE TABLE table_critical_flag
(
    id    SERIAL PRIMARY KEY,
    "critical_flag" TEXT
);

INSERT INTO table_critical_flag (critical_flag)
SELECT DISTINCT COALESCE("CRITICAL FLAG",NULL)
FROM public.table_restaurant_inspection_dataset
ORDER BY COALESCE("CRITICAL FLAG",NULL);

SELECT * from table_critical_flag;

-- TODO: ==============================================


-- TODO : TABLE FOR INSPECTION

CREATE TABLE table_inspection_results (
    id    SERIAL PRIMARY KEY,
    refer_id INT,
    action_id INT ,
    critical_flag_id INT ,
    grade_type_id INT ,
    inspection_type_id INT ,
    "SCORE" DOUBLE PRECISION,
    FOREIGN KEY (action_id) REFERENCES table_action_type (id),
    FOREIGN KEY (critical_flag_id) REFERENCES table_critical_flag (id),
    FOREIGN KEY (grade_type_id) REFERENCES table_grade_type (id),
    FOREIGN KEY (inspection_type_id) REFERENCES table_inspection_type (id)
);

INSERT INTO table_inspection_results
    (refer_id,action_id, critical_flag_id, grade_type_id,  inspection_type_id, "SCORE")
SELECT
        rid."ID" as refer_id,
        a.id AS action_id, cf.id AS critical_flag_id, gt.id AS grade_type_id, it.id AS inspection_type_id, "SCORE"
    FROM table_restaurant_inspection_dataset rid
    LEFT JOIN table_action_type a ON rid."ACTION" = a.action
    LEFT JOIN table_critical_flag cf ON rid."CRITICAL FLAG" = cf.critical_flag
    LEFT JOIN table_grade_type gt ON rid."GRADE" = gt.grade
    LEFT JOIN table_inspection_type it ON rid."INSPECTION TYPE" = it.inspection_type;
--     GROUP BY action_id, critical_flag_id, grade_type_id, inspection_type_id, "SCORE";

SELECT * FROM table_inspection_results;

-- TODO : TABLE FOR INSPECTION
-- SELECT COUNT(*)
-- FROM (
--
-- SELECT DISTINCT r."INSPECTION DATE", r."GRADE DATE", i.id as "INSPECTION_RESULT"
-- FROM table_restaurant_inspection_dataset r
-- JOIN table_inspection_results i ON
--      i.refer_id = r."ID"
-- ) as subquery;
--
-- CREATE TABLE inspection (
--     ID    SERIAL PRIMARY KEY,
--
-- );
--
-- INSERT INTO inspection ("INSPECTION DATE", "GRADE DATE", "INSPECTION RESULT")
-- SELECT DISTINCT r."INSPECTION DATE", r."GRADE DATE", i.id as "INSPECTION RESULT"
-- FROM table_restaurant_inspection_dataset r
-- JOIN table_inspection_results i ON i.refer_id = r."ID";
--
-- SELECT * FROM inspection;
-- SELECT * FROM inspection WHERE "INSPECTION DATE" = '09/19/2023';

-- TODO : TABLE FOR INSPECTION

CREATE TABLE table_restaurant
(
    ID                  SERIAL PRIMARY KEY,
    CAMIS               bigint,
    DBA                 TEXT,
    ADDRESS             INT,
    PHONE               TEXT,
    CUISINE_DESCRIPTION INT,
    "INSPECTION DATE" text,
    "GRADE DATE" text,
    "INSPECTION RESULT" int,
    CONSTRAINT fk_cuisine FOREIGN KEY (CUISINE_DESCRIPTION) REFERENCES table_cuisine (id),
    CONSTRAINT fk_address FOREIGN KEY (ADDRESS) REFERENCES table_address (id)
);

SELECT * from table_address;


INSERT INTO table_restaurant (
    CAMIS,
    DBA,
    ADDRESS,
    PHONE,
    CUISINE_DESCRIPTION,
    "INSPECTION DATE",
    "GRADE DATE",
    "INSPECTION RESULT"
)
SELECT
    M."CAMIS",
    M."DBA",
    ta.id,
    M."PHONE",
    C.id,
    M."INSPECTION DATE",
    M."GRADE DATE",
   IR.ID as "INSPECTION RESULT"
FROM public.table_restaurant_inspection_dataset M
LEFT JOIN table_cuisine C ON M."CUISINE DESCRIPTION" = C.cuisine_description
LEFT JOIN table_address ta
     ON M."BUILDING" = ta.BUILDING
     AND M."STREET" = ta."street"
     AND M."ZIPCODE" = ta."zipcode"
LEFT JOIN table_inspection_results IR ON IR.refer_id = M."ID"
WHERE M."DBA" IS NOT NULL;

SELECT COUNT(*) FROM table_restaurant;










-- SELECT "CAMIS", COUNT(*) as Frequency
-- FROM public.table_restaurant_inspection_dataset
-- GROUP BY "CAMIS"
-- HAVING COUNT(*) > 1
-- ORDER BY Frequency DESC;



-- SELECT DISTINCT "CRITICAL FLAG"
-- from public.table_restaurant_inspection_dataset;


-- SELECT COUNT(*)
-- FROM (
-- SELECT DISTINCT "ACTION", "CRITICAL FLAG", "SCORE", "GRADE",  "INSPECTION TYPE"
-- from public.table_restaurant_inspection_dataset
--      )
--     AS subquery;
-- SELECT DISTINCT "RECORD DATE"
-- from public.table_restaurant_inspection_dataset;
--

-- SELECT COUNT(*)
-- FROM (
--     SELECT DISTINCT "INSPECTION DATE", "CRITICAL FLAG", "SCORE", "GRADE","GRADE DATE"
--     FROM restaurant_inspection_dataset rid
-- )   AS subquery;


SELECT COUNT(*)
FROM (
    SELECT DISTINCT
    a.id AS action_id,
    cf.id AS critical_flag_id,
    gt.id AS grade_type_id,
    it.id AS inspection_type_id,
    "SCORE"
FROM
    table_restaurant_inspection_dataset rid
    LEFT JOIN table_action_type a ON rid."ACTION" = a.action
    LEFT JOIN table_critical_flag cf ON rid."CRITICAL FLAG" = cf.critical_flag
    LEFT JOIN table_grade_type gt ON rid."GRADE" = gt.grade
    LEFT JOIN table_inspection_type it ON rid."INSPECTION TYPE" = it.inspection_type
) as subquery;

SELECT COUNT(*)
FROM (
    SELECT
        MIN(rid."ID") as main_id,
        a.id AS action_id, cf.id AS critical_flag_id, gt.id AS grade_type_id, it.id AS inspection_type_id, "SCORE"
    FROM table_restaurant_inspection_dataset rid
    LEFT JOIN table_action_type a ON rid."ACTION" = a.action
    LEFT JOIN table_critical_flag cf ON rid."CRITICAL FLAG" = cf.critical_flag
    LEFT JOIN table_grade_type gt ON rid."GRADE" = gt.grade
    LEFT JOIN table_inspection_type it ON rid."INSPECTION TYPE" = it.inspection_type
    GROUP BY action_id, critical_flag_id, grade_type_id, inspection_type_id, "SCORE"
) as subquery;