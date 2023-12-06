-- Dimension Tables

-- TODO : DIMENSION LOCATION
CREATE TABLE Dimension_Location
(
    LocationKey  INT PRIMARY KEY,
    BuildingName TEXT,
    StreetName   TEXT,
    ZipCode      DOUBLE PRECISION,
    Borough      INT
);

-- Insert data into dimension_Grade_Type from source_table
INSERT INTO Dimension_Location (LocationKey, BuildingName, StreetName, ZipCode, Borough)
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
    PHONE          VARCHAR(15),
    CUISINE_KEY    INT,
    LOCATION_KEY   INT,
    FOREIGN KEY (CUISINE_KEY) REFERENCES dimension_Cuisine (Cuisine_Key),
    FOREIGN KEY (LOCATION_KEY) REFERENCES dimension_location (LocationKey)
);

INSERT INTO dimension_restaurant (RESTAURANT_KEY, CAMIS, NAME, Phone, Cuisine_Key,location_key)
SELECT tr.id, tr.camis, tr.dba, tr.Phone, dc.Cuisine_Key,tr.address_id
FROM table_restaurant tr
         JOIN dimension_cuisine dc on dc.Cuisine_Key = tr.cuisine_id;

SELECT *
FROM dimension_Restaurant where RESTAURANT_KEY=1;

SELECT * FROM table_restaurant where id =1;

-- TODO: DIMENSION CRITICAL TYPE
-- Create dimension_Grade_Type table
-- DROP TABLE dimension_critical_flag;
CREATE TABLE dimension_critical_flag
(
    Critical_Flag_Key INT PRIMARY KEY,
    Flag     text
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

SELECT * FROM table_violation;

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

select * from table_inspection_type;

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
SELECT id,type
FROM table_action_type;

SELECT *
FROM dimension_action_type;




-- TODO: Fact Table

CREATE TABLE Fact_Inspection
(
    Restaurant_Key      INT,
    Violation_Key       INT,
    Inspection_Type_Key INT,
    Inspection_Date_Key INT,
    Grade_Date_Key      INT,
    Critical_Flag_Key   INT,
    Grade_Type_Key      INT,
    Action_Type_Key     INT,
    Score               DOUBLE PRECISION,
    FOREIGN KEY (Restaurant_Key) REFERENCES dimension_Restaurant (Restaurant_Key),
    FOREIGN KEY (Violation_Key) REFERENCES dimension_Violation (Violation_Key),
    FOREIGN KEY (Inspection_Type_Key) REFERENCES dimension_Inspection_Type (Inspection_Type_Key),
    FOREIGN KEY (Inspection_Date_Key) REFERENCES dimension_date (date_key),
    FOREIGN KEY (Grade_Date_Key) REFERENCES dimension_date (date_key),
    FOREIGN KEY (Critical_Flag_Key) REFERENCES dimension_critical_flag (critical_flag_key) ,
    FOREIGN KEY (Grade_Type_Key) REFERENCES dimension_Grade_Type (grade_type_key),
    FOREIGN KEY (Action_Type_Key) REFERENCES dimension_action_type (Action_Type_Key)

);

DROP TABLE fact_inspection;

-- Insert data into Fact_Inspection
INSERT INTO Fact_Inspection (Restaurant_Key,
                             Violation_Key,
                             Inspection_Type_Key,
                             Inspection_Date_Key,
                             Grade_Date_Key,
                             Critical_Flag_Key,
                             Grade_Type_Key,
                             Action_Type_Key,
                             Score)
SELECT dr.Restaurant_Key,
       dv.Violation_Key,
       dit.Inspection_Type_Key,
       di.Date_Key    as Inspection_Date_Key,
       dg.Date_Key    as Grade_Date_Key,
       trslts.critical_flag_id,
       trslts.grade_type_id,
       trslts.action_id,
       trslts."SCORE"
FROM table_inspection tri
         LEFT JOIN dimension_Restaurant dr ON tri.restaurant_info = dr.RESTAURANT_KEY
         LEFT JOIN dimension_Violation dv ON tri.violation_id = dv.Violation_Key
         LEFT JOIN dimension_Inspection_Type dit ON tri.inspection_type_id = dit.Inspection_Type_Key
         LEFT JOIN dimension_Date di ON tri."INSPECTION DATE"::DATE = di.Complete_Date
         LEFT JOIN dimension_Date dg ON tri."GRADE DATE"::DATE = dg.Complete_Date
         LEFT JOIN table_results trslts ON  trslts.id = tri.inspection_result;

SELECT DISTINCT * FROM Fact_Inspection ;



SELECT DISTINCT * from fact_inspection where Restaurant_Key = 59512;

SELECT * FROM dimension_restaurant where RESTAURANT_KEY = 59512;

SELECT * FROM dimension_restaurant where CAMIS = 41086770;

SELECT * FROM table_inspection where restaurant_info = 5374;
-- DATA CUBE




-- TODO: CORRECT FACT TABLE BELOW COMING SOON

SELECT dr.Restaurant_Key,
       dl.LocationKey
FROM table_inspection tri
         JOIN dimension_Restaurant dr ON tri.restaurant_info = dr.RESTAURANT_KEY
         JOIN dimension_location dl ON dl.LocationKey = (SELECT id FROM table_address ta where ta.id = dl.LocationKey)



-- TODO TEST FACT TABLE
CREATE TABLE Fact_Inspection_Test
(
    Restaurant_Key      INT,
    Violation_Key       INT,
    Inspection_Type_Key INT,
    Inspection_Date_Key INT,
    Grade_Date_Key      INT,
    Critical_Flag_Key   INT,
    Grade_Type_Key      INT,
    Action_Type_Key     INT,
    Score               DOUBLE PRECISION,
    FOREIGN KEY (Restaurant_Key) REFERENCES dimension_Restaurant (Restaurant_Key),
    FOREIGN KEY (Violation_Key) REFERENCES dimension_Violation (Violation_Key),
    FOREIGN KEY (Inspection_Type_Key) REFERENCES dimension_Inspection_Type (Inspection_Type_Key),
    FOREIGN KEY (Inspection_Date_Key) REFERENCES dimension_date (date_key),
    FOREIGN KEY (Grade_Date_Key) REFERENCES dimension_date (date_key),
    FOREIGN KEY (Critical_Flag_Key) REFERENCES dimension_critical_flag (critical_flag_key) ,
    FOREIGN KEY (Grade_Type_Key) REFERENCES dimension_Grade_Type (grade_type_key),
    FOREIGN KEY (Action_Type_Key) REFERENCES dimension_action_type (Action_Type_Key)
);

INSERT INTO Fact_Inspection_Test (
    Restaurant_Key,
    Violation_Key,
    Inspection_Type_Key,
    Inspection_Date_Key,
    Grade_Date_Key,
    Critical_Flag_Key,
    Grade_Type_Key,
    Action_Type_Key,
    Score
)
SELECT
    dr.Restaurant_Key,
    tv.Violation_Key,
    dit.Inspection_Type_Key,
    dd.Date_Key as Inspection_Date_Key,
    id.Date_Key as Grade_Date_Key,
    dcf.Critical_Flag_Key,
    dgt.Grade_Type_Key,
    dat.Action_Type_Key,
    data."SCORE"
FROM
    table_restaurant_inspection_dataset data
JOIN DIMENSION_RESTAURANT dr on dr.CAMIS = data."CAMIS"
JOIN dimension_Violation tv ON tv.violation_code = data."VIOLATION CODE" -- Assuming this is the correct column name
JOIN dimension_Inspection_Type dit ON dit.Inspection_Type = data."INSPECTION TYPE" -- Assuming this is the correct column name
JOIN dimension_Date dd ON dd.Complete_Date = data."INSPECTION DATE"
JOIN dimension_Date id ON id.Complete_Date = data."GRADE DATE"
JOIN dimension_Grade_Type dgt ON dgt.Grade_Type = data."GRADE" -- Assuming this is the correct column name
JOIN dimension_critical_flag dcf ON dcf.Flag = data."CRITICAL FLAG"
JOIN dimension_action_type dat ON dat.Action_Type = data."ACTION";


SELECT DISTINCT * from Fact_Inspection_Test where Restaurant_Key = 5374;

SELECT * FROM dimension_restaurant where RESTAURANT_KEY = 5374;
-- TODO: DATA CUBE

-- Replace 'your_camis_id' with the actual CAMIS ID you are interested in
WITH CamisQuery AS (
    SELECT Restaurant_Key
    FROM dimension_Restaurant
    WHERE CAMIS = '50066048'
)

SELECT fi.*,
       dr.NAME AS RestaurantName,
       dr.PHONE AS RestaurantPhone,
       dc.TYPE AS CuisineType,
       dl.BuildingName,
       dl.StreetName,
       dl.ZipCode,
       dl.Borough,
       dv.Violation_Code,
       dv.Violation_Description,
       dit.Inspection_Type AS InspectionType,
       dd_complete.Complete_Date AS InspectionDate,
       dd_grade.Complete_Date AS GradeDate,
       dcf.Flag AS CriticalFlag,
       dgt.Grade_Type AS GradeType,
       dat.Action_Type AS ActionType
FROM Fact_Inspection fi
         JOIN dimension_Restaurant dr ON fi.Restaurant_Key = dr.RESTAURANT_KEY
         JOIN dimension_cuisine dc ON dr.CUISINE_KEY = dc.CUISINE_KEY
         JOIN Dimension_Location dl ON dr.LOCATION_KEY = dl.LocationKey
         JOIN dimension_Violation dv ON fi.Violation_Key = dv.Violation_Key
         JOIN dimension_Inspection_Type dit ON fi.Inspection_Type_Key = dit.Inspection_Type_Key
         JOIN dimension_Date dd_complete ON fi.Inspection_Date_Key = dd_complete.Date_Key
         JOIN dimension_Date dd_grade ON fi.Grade_Date_Key = dd_grade.Date_Key
         JOIN dimension_critical_flag dcf ON fi.Critical_Flag_Key = dcf.Critical_Flag_Key
         JOIN dimension_Grade_Type dgt ON fi.Grade_Type_Key = dgt.Grade_Type_Key
         JOIN dimension_action_type dat ON fi.Action_Type_Key = dat.Action_Type_Key
WHERE fi.Restaurant_Key IN (SELECT Restaurant_Key FROM CamisQuery);








-- SELECT *
-- from table_restaurant;
--
--
-- select *
-- from dimension_restaurant
-- where RESTAURANT_KEY = 137;
--
-- select *
-- from table_restaurant
-- where id = 137;
--
-- select *
-- from dimension_location
-- where LocationKey = 19438;
--
-- select *
-- from table_address
-- where id = 19438;
--
--
-- SELECT count(*)
-- FROM table_results;
--
-- SELECT *
-- FROM table_restaurant where id = 10;
--
-- SELECT *
-- FROM dimension_Restaurant;
--
--
--
-- SELECT * from dimension_Date where Date_Key = 3557;
--
-- select * from table_violation where id = 91;
--
-- select * from dimension_Violation where Violation_Key = 91;
--
-- SELECT *
-- FROM Fact_Inspection fi
-- where fi.Restaurant_Key = 10;
--
-- SELECT * FROM table_inspection where restaurant_info = 10;
--
-- SELECT * from table_results tr where tr.id = 36628;
--
-- SELECT * FROM table_critical_flag where id = 3;
-- SELECT * FROM table_grade_type where id=1;