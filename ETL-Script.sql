-- Dimension Tables
CREATE TABLE IF NOT EXISTS dimension_borough
(
    BoroughKey  INT PRIMARY KEY,
    BoroughName TEXT
);

INSERT INTO dimension_borough (BoroughKey, BoroughName)
SELECT *
FROM table_borough;

SELECT *
FROM dimension_borough;

SELECT *
FROM table_borough;

-- TODO : DIMENSION LOCATION
CREATE TABLE Dimension_Location
(
    LocationKey  INT PRIMARY KEY,
    BuildingName TEXT,
    StreetName   TEXT,
    ZipCode      DOUBLE PRECISION,
    BoroughKey   INT,
    FOREIGN KEY (BoroughKey) REFERENCES dimension_borough (BoroughKey)
);

-- Insert data into dimension_Grade_Type from source_table
INSERT INTO Dimension_Location (LocationKey, BuildingName, StreetName, ZipCode, BoroughKey)
SELECT DISTINCT id, building, street, zipcode, borough_id
FROM table_address;

SELECT *
FROM Dimension_Location
where LocationKey = 1;

SELECT *
FROM table_address
where id = 1;

-- TODO: DIMENSION RESTAURANT DONE
CREATE TABLE dimension_cuisine
(
    Cuisine_Key INT PRIMARY KEY,
    type        text
);

INSERT INTO dimension_cuisine (CUISINE_KEY, TYPE)
SELECT id, type
FROM table_cuisine;

SELECT *
from dimension_cuisine;

-- TODO: DIMENSION RESTAURANT DONE
CREATE TABLE DIMENSION_RESTAURANT
(
    RESTAURANT_KEY INT PRIMARY KEY,
    CAMIS          BIGINT,
    NAME           VARCHAR(255),
    PHONE          VARCHAR(15)
);

INSERT INTO dimension_restaurant (RESTAURANT_KEY, CAMIS, NAME, Phone)
SELECT tr.id, tr.camis, tr.dba, tr.Phone
FROM table_restaurant tr;

SELECT *
FROM dimension_Restaurant
where RESTAURANT_KEY = 1;

SELECT *
FROM table_restaurant
where id = 1;

-- TODO: DIMENSION CRITICAL TYPE
-- Create dimension_Grade_Type table
-- DROP TABLE dimension_critical_flag;
CREATE TABLE dimension_critical_flag
(
    Critical_Flag_Key INT PRIMARY KEY,
    Flag              text
);


-- Insert data into dimension_Grade_Type from source_table
INSERT INTO dimension_critical_flag (Critical_Flag_Key, Flag)
SELECT DISTINCT id, flag
FROM table_critical_flag;

SELECT *
FROM dimension_critical_flag;

SELECT *
from table_critical_flag;

-- TODO: DIMENSION VIOLATION DONE
CREATE TABLE dimension_Violation
(
    Violation_Key         INT PRIMARY KEY,
    Violation_Code        VARCHAR(10),
    Violation_Description TEXT
);

-- Insert data into dimension_Violation from another table
INSERT INTO dimension_Violation (Violation_Key, Violation_Code, Violation_Description)
SELECT id,
       code,
       description
FROM table_violation;

SELECT *
FROM dimension_Violation;

SELECT *
FROM table_violation;

-- TODO: DIMENSION INSPECTION DONE
CREATE TABLE dimension_Inspection_Type
(
    Inspection_Type_Key INT PRIMARY KEY,
    Inspection_Type     TEXT
);

-- Assuming source_table has the same structure as dimension_Inspection_Type
INSERT INTO dimension_Inspection_Type (Inspection_Type_Key, Inspection_Type)
SELECT id, type
FROM table_inspection_type;

SELECT *
FROM dimension_Inspection_Type;

select *
from table_inspection_type;

-- TODO: DIMENSION DATE DONE
CREATE TABLE dimension_Date
(
    Date_Key      SERIAL PRIMARY KEY,
    Complete_Date DATE,
    Year          INT,
    Month         INT,
    Day           INT
);

-- Generate and insert data from 01 Jan 2013 to current date
INSERT INTO dimension_Date (Complete_Date, Year, Month, Day)
SELECT date_series,
       EXTRACT(YEAR FROM date_series)  AS Year,
       EXTRACT(MONTH FROM date_series) AS Month,
       EXTRACT(DAY FROM date_series)   AS Day
FROM GENERATE_SERIES('2015-01-01'::date, CURRENT_DATE, '1 day') AS date_series;

SELECT *
FROM dimension_Date;


-- where LocationKey = 1;

SElECT *
FROM table_address;

-- TODO: DIMENSION GRADE TYPE
-- Create dimension_Grade_Type table
CREATE TABLE dimension_Grade_Type
(
    Grade_Type_Key INT PRIMARY KEY,
    Grade_Type     VARCHAR(5)
);


-- Insert data into dimension_Grade_Type from source_table
INSERT INTO dimension_Grade_Type (Grade_Type_Key, Grade_Type)
SELECT DISTINCT id, type
FROM table_grade_type;

SELECT *
FROM dimension_Grade_Type;

SELECT *
from table_grade_type;

-- TODO: ACTION TYPE
-- Create dimension_Grade_Type table
CREATE TABLE dimension_action_type
(
    Action_Type_Key INT PRIMARY KEY,
    Action_Type     text
);


-- Insert data into dimension_Grade_Type from source_table
INSERT INTO dimension_action_type (Action_Type_Key, Action_Type)
SELECT id, type
FROM table_action_type;

SELECT *
FROM dimension_action_type;


-- TODO: Fact Table

CREATE TABLE Fact_Inspection
(
    Restaurant_Key      INT,
    Cuisine_Key         INT,
    Location_Key        INT,
    Violation_Key       INT,
    Inspection_Type_Key INT,
    Inspection_Date_Key INT,
    CriticalFlag        TEXT,
    Grade               VARCHAR(5),
    Score               DOUBLE PRECISION,
    FOREIGN KEY (Restaurant_Key) REFERENCES dimension_Restaurant (Restaurant_Key),
    FOREIGN KEY (Cuisine_Key) REFERENCES dimension_cuisine (Cuisine_Key),
    FOREIGN KEY (Location_Key) REFERENCES dimension_location (LocationKey),
    FOREIGN KEY (Violation_Key) REFERENCES dimension_Violation (Violation_Key),
    FOREIGN KEY (Inspection_Type_Key) REFERENCES dimension_Inspection_Type (Inspection_Type_Key),
    FOREIGN KEY (Inspection_Date_Key) REFERENCES dimension_date (date_key)
);

DROP TABLE fact_inspection;

-- Insert data into Fact_Inspection
INSERT INTO Fact_Inspection (Restaurant_Key,
                             Cuisine_Key,
                             Location_Key,
                             Violation_Key,
                             Inspection_Type_Key,
                             Inspection_Date_Key,
                             CriticalFlag,
                             Grade,
                             Score)
SELECT tres.id,
       tres.cuisine_id,
       dl.LocationKey,
       dv.Violation_Key,
       dit.Inspection_Type_Key,
       di.Date_Key as Inspection_Date_Key,
       tcf.flag,
       tgt.type,
       trslts."SCORE"
FROM table_inspection tri
         LEFT JOIN table_restaurant tres ON tri.restaurant_info = tres.id
         LEFT JOIN dimension_location dl ON tres.address_id = dl.LocationKey
         LEFT JOIN dimension_Violation dv ON tri.violation_id = dv.Violation_Key
         LEFT JOIN dimension_Inspection_Type dit ON tri.inspection_type_id = dit.Inspection_Type_Key
         LEFT JOIN dimension_Date di ON tri."INSPECTION DATE"::DATE = di.Complete_Date
         LEFT JOIN table_results trslts ON trslts.id = tri.inspection_result
         LEFT JOIN table_critical_flag tcf on trslts.critical_flag_id = tcf.id
         LEFT JOIN table_grade_type tgt on trslts.grade_type_id = tgt.id;


SELECT *
FROM Fact_Inspection;



SELECT *
from fact_inspection
where Restaurant_Key = 59512;

SELECT *
FROM dimension_restaurant
where RESTAURANT_KEY = 59512;

SELECT *
FROM dimension_restaurant
where CAMIS = 41086770;

SELECT *
FROM table_inspection
where restaurant_info = 5374;


-- SELECT *
-- from Fact_Inspection_Test
-- where Restaurant_Key = 5374;

-- SELECT *
-- FROM dimension_restaurant
-- where RESTAURANT_KEY = 5374;

-- SELECT * FROM dimension_restaurant where CAMIS = 50078481;

-- SELECT * FROM dimension_cuisine where Cuisine_Key = 3;
-- TODO: DATA CUBE

-- Replace 'your_camis_id' with the actual CAMIS ID you are interested in
WITH CamisQuery AS (SELECT Restaurant_Key
                    FROM dimension_Restaurant
                    WHERE CAMIS = '41086770')

SELECT dr.NAME                   AS RestaurantName,
       dr.PHONE                  AS RestaurantPhone,
       dc.TYPE                   AS CuisineType,
       dl.BuildingName,
       dl.StreetName,
       dl.ZipCode,
       dl.BoroughKey,
       dv.Violation_Code,
       dv.Violation_Description,
       dit.Inspection_Type       AS InspectionType,
       dd_complete.Complete_Date AS InspectionDate,
       dcf.Flag                  AS CriticalFlag,
       dgt.Grade_Type            AS GradeType,
       dat.Action_Type           AS ActionType,
       Fi.Score
FROM Fact_Inspection fi
         JOIN dimension_Restaurant dr ON fi.Restaurant_Key = dr.RESTAURANT_KEY
         JOIN dimension_cuisine dc ON fi.CUISINE_KEY = dc.CUISINE_KEY
         JOIN Dimension_Location dl ON fi.LOCATION_KEY = dl.LocationKey
         JOIN dimension_Violation dv ON fi.Violation_Key = dv.Violation_Key
         JOIN dimension_Inspection_Type dit ON fi.Inspection_Type_Key = dit.Inspection_Type_Key
         JOIN dimension_Date dd_complete ON fi.Inspection_Date_Key = dd_complete.Date_Key
         JOIN dimension_critical_flag dcf ON fi.Critical_Flag_Key = dcf.Critical_Flag_Key
         JOIN dimension_Grade_Type dgt ON fi.Grade_Type_Key = dgt.Grade_Type_Key
         JOIN dimension_action_type dat ON fi.Action_Type_Key = dat.Action_Type_Key
WHERE fi.Restaurant_Key IN (SELECT Restaurant_Key FROM CamisQuery);

-- TODO : Which borough has the highest percentage of restaurants with A grades?

WITH GradeA_Percentage AS (SELECT dl.BoroughKey,
                                  (COUNT(dl.BoroughKey) FILTER (WHERE dgt.Grade_Type = 'A')) AS PercentageGradeA
                           FROM Fact_Inspection fi
                                    JOIN Dimension_Location dl ON fi.Location_Key = dl.LocationKey
                                    JOIN Dimension_Grade_Type dgt ON fi.Grade_Type_Key = dgt.Grade_Type_Key
                           GROUP BY dl.BoroughKey)
SELECT db.BoroughName,
       ROUND(PercentageGradeA, 2) AS PercentageGradeA
FROM GradeA_Percentage GA
         JOIN dimension_borough db on db.BoroughKey = GA.BoroughKey
ORDER BY PercentageGradeA DESC;

-- TODO:
WITH ViolationsByBorough AS (SELECT dl.BoroughKey,
                                    SUM(CASE WHEN dcf.Flag = 'Critical' THEN 1 ELSE 0 END)       AS CriticalViolations,
                                    SUM(CASE WHEN dcf.Flag = 'Not Critical' THEN 1 ELSE 0 END)   AS NotCriticalViolations,
                                    SUM(CASE WHEN dcf.Flag = 'Not Applicable' THEN 1 ELSE 0 END) AS NotApplicableViolations
                             FROM Fact_Inspection fi
                                      JOIN Dimension_Location dl ON fi.Location_Key = dl.LocationKey
                                      JOIN Dimension_Critical_Flag dcf ON fi.Critical_Flag_Key = dcf.Critical_Flag_Key
                             GROUP BY dl.BoroughKey)
SELECT db.BoroughName,
       VBB.CriticalViolations,
       VBB.NotCriticalViolations,
       VBB.NotApplicableViolations
FROM ViolationsByBorough VBB
         LEFT JOIN dimension_borough db on VBB.BoroughKey = db.BoroughKey;


-- -- TODO TEST FACT TABLE
-- CREATE TABLE Fact_Inspection_Test
-- (
--     Restaurant_Key      INT,
--     Cuisine_Key         INT,
--     Location_Key        INT,
--     Violation_Key       INT,
--     Inspection_Type_Key INT,
--     Inspection_Date_Key INT,
--     Critical_Flag_Key   INT,
--     Grade_Type_Key      INT,
--     Action_Type_Key     INT,
--     Score               DOUBLE PRECISION,
--     FOREIGN KEY (Restaurant_Key) REFERENCES dimension_Restaurant (Restaurant_Key),
--     FOREIGN KEY (Cuisine_Key) REFERENCES dimension_cuisine (Cuisine_Key),
--     FOREIGN KEY (Location_Key) REFERENCES dimension_location (LocationKey),
--     FOREIGN KEY (Violation_Key) REFERENCES dimension_Violation (Violation_Key),
--     FOREIGN KEY (Inspection_Type_Key) REFERENCES dimension_Inspection_Type (Inspection_Type_Key),
--     FOREIGN KEY (Inspection_Date_Key) REFERENCES dimension_date (date_key),
--     FOREIGN KEY (Critical_Flag_Key) REFERENCES dimension_critical_flag (critical_flag_key),
--     FOREIGN KEY (Grade_Type_Key) REFERENCES dimension_Grade_Type (grade_type_key),
--     FOREIGN KEY (Action_Type_Key) REFERENCES dimension_action_type (Action_Type_Key)
-- );
--
-- INSERT INTO Fact_Inspection_Test (Restaurant_Key,
--                                   Cuisine_Key,
--                                   Location_Key,
--                                   Violation_Key,
--                                   Inspection_Type_Key,
--                                   Inspection_Date_Key,
--                                   Critical_Flag_Key,
--                                   Grade_Type_Key,
--                                   Action_Type_Key,
--                                   Score)
-- SELECT tres.id,
--        tres.cuisine_id,
--        dl.LocationKey,
--        dv.Violation_Key,
--        dit.Inspection_Type_Key,
--        di.Date_Key as Inspection_Date_Key,
--        trslts.critical_flag_id,
--        trslts.grade_type_id,
--        trslts.action_id,
--        trslts."SCORE"
-- FROM table_inspection tri
--          LEFT JOIN table_restaurant tres ON tri.restaurant_info = tres.id
--          LEFT JOIN dimension_location dl ON  tres.address_id = dl.LocationKey
--          LEFT JOIN dimension_Violation dv ON tri.violation_id = dv.Violation_Key
--          LEFT JOIN dimension_Inspection_Type dit ON tri.inspection_type_id = dit.Inspection_Type_Key
--          LEFT JOIN dimension_Date di ON tri."INSPECTION DATE"::DATE = di.Complete_Date
--          LEFT JOIN table_results trslts ON trslts.id = tri.inspection_result;
--
