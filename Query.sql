SELECT COUNT(*)
FROM (SELECT *
      from public.restaurant_inspection_dataset
      WHERE "DBA" IS NOT NULL) AS subquery;

SELECT *
from public.restaurant_inspection_dataset;

SELECT DISTINCT "BORO"
from restaurant_inspection_dataset;

SELECT * FROM table_borough;

SELECT DISTINCT "ACTION"
from restaurant_inspection_dataset;

SELECT * FROM table_action;

SELECT * FROM table_grade_type;

SELECT * FROM table_inspection_type;

SELECT * FROM table_restaurant;


CREATE TABLE table_borough
(
    id      SERIAL PRIMARY KEY,
    borough TEXT
);

INSERT INTO table_borough (borough)
SELECT DISTINCT "BORO"
FROM public.restaurant_inspection_dataset
ORDER BY "BORO";

SELECT *
FROM table_borough;


-- TO CREATE ADDRESS TABLE
SELECT COUNT(*)
FROM (SELECT DISTINCT "BUILDING", "STREET", "ZIPCODE", tb.id as "Borough Number", "Latitude", "Longitude"
      FROM public.restaurant_inspection_dataset rid
               LEFT JOIN table_borough tb on rid."BORO" = tb.borough) AS subquery;

CREATE TABLE table_address (
    id      SERIAL PRIMARY KEY,
    BUILDING TEXT,
    STREET TEXT,
    ZIPCODE DOUBLE PRECISION,
    "BOROUGH" INTEGER,
    Latitude  DOUBLE PRECISION,
    Longitude  DOUBLE PRECISION
);

INSERT INTO table_address (BUILDING, STREET, ZIPCODE, "BOROUGH", Latitude, Longitude)
SELECT DISTINCT "BUILDING", "STREET", "ZIPCODE", tb.id as "Borough Number", "Latitude", "Longitude"
FROM public.restaurant_inspection_dataset rid
LEFT JOIN table_borough tb ON rid."BORO" = tb.borough
ORDER BY "ZIPCODE";

CREATE INDEX idx_location
ON table_address (building, street, zipcode, "BOROUGH", latitude, longitude);

SELECT * from table_address;

SELECT DISTINCT "INSPECTION TYPE"
from restaurant_inspection_dataset;

CREATE TABLE table_inspection_type
(
    id              SERIAL PRIMARY KEY,
    inspection_type TEXT
);

INSERT INTO table_inspection_type (inspection_type)
SELECT DISTINCT "INSPECTION TYPE"
FROM public.restaurant_inspection_dataset;

SELECT *
from table_inspection_type;

SELECT DISTINCT "GRADE"
from restaurant_inspection_dataset;


CREATE TABLE table_grade_type
(
    id    SERIAL PRIMARY KEY,
    grade TEXT
);

INSERT INTO table_grade_type (grade)
SELECT DISTINCT "GRADE"
FROM public.restaurant_inspection_dataset
ORDER BY "GRADE";

SELECT *
FROM table_grade_type;

SELECT DISTINCT "ACTION", "CRITICAL FLAG", "SCORE", "GRADE", "GRADE DATE", "INSPECTION TYPE"
from public.restaurant_inspection_dataset;

SELECT COUNT(*)
FROM (SELECT DISTINCT "ACTION", "CRITICAL FLAG", "SCORE", "GRADE", tit.inspection_type
      FROM restaurant_inspection_dataset rid
               LEFT JOIN table_inspection_type tit on rid."INSPECTION TYPE" = tit.inspection_type
      )
    AS subquery;


SELECT "CAMIS", COUNT(*) as Frequency
FROM public.restaurant_inspection_dataset
GROUP BY "CAMIS"
HAVING COUNT(*) > 1;


CREATE TABLE table_restaurant
(
    ID                  SERIAL PRIMARY KEY,
    CAMIS               bigint,
    DBA                 TEXT,
    ADDRESS             INT,
    PHONE               TEXT,
    CUISINE_DESCRIPTION INT,
    CONSTRAINT fk_cuisine FOREIGN KEY (CUISINE_DESCRIPTION) REFERENCES table_cuisine (id),
    CONSTRAINT fk_address FOREIGN KEY (ADDRESS) REFERENCES table_address (id)
);

SELECT * from table_address;

EXPLAIN
INSERT INTO table_restaurant (CAMIS, DBA, ADDRESS, PHONE, CUISINE_DESCRIPTION)
SELECT M."CAMIS",
       M."DBA",
       ta.id,
       M."PHONE",
       C.id
FROM public.restaurant_inspection_dataset M
LEFT JOIN table_cuisine C ON M."CUISINE DESCRIPTION" = C.cuisine_description
LEFT JOIN table_address ta
     ON M."BUILDING" = ta.BUILDING
     AND M."STREET" = ta."street"
     AND M."ZIPCODE" = ta."zipcode"
WHERE M."DBA" IS NOT NULL;

SELECT *
FROM public.table_restaurant;


SELECT