-- Dimension Tables

-- TODO: DIMENSION RESTAURANT DONE
CREATE TABLE dimension_Restaurant
(
    Restaurant_Key SERIAL PRIMARY KEY,
    CAMIS          BIGINT,
    Name           VARCHAR(255),
    Phone          VARCHAR(15)
);

INSERT INTO dimension_Restaurant (CAMIS, Name, Phone)
SELECT DISTINCT CAMIS, dba, Phone
FROM table_restaurant;

SELECT *
FROM dimension_Restaurant;


-- TODO: DIMENSION VIOLATION DONE
CREATE TABLE dimension_Violation
(
    Violation_Key         SERIAL PRIMARY KEY,
    Violation_Code        VARCHAR(10),
    Violation_Description TEXT
);

-- Insert data into dimension_Violation from another table
INSERT INTO dimension_Violation (Violation_Code, Violation_Description)
SELECT code,
       description
FROM table_violation;

SELECT *
FROM dimension_Violation;

-- TODO: DIMENSION INSPECTION DONE
CREATE TABLE dimension_Inspection_Type
(
    Inspection_Type_Key SERIAL PRIMARY KEY,
    Inspection_Type     TEXT
);

-- Assuming source_table has the same structure as dimension_Inspection_Type
INSERT INTO dimension_Inspection_Type (Inspection_Type)
SELECT type
FROM table_inspection_type;

SELECT *
FROM dimension_Inspection_Type;

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
FROM GENERATE_SERIES('2013-01-01'::date, CURRENT_DATE, '1 day') AS date_series;

SELECT *
FROM dimension_Date;


-- TODO: DIMENSION CUISINE
CREATE TABLE dimension_Cuisine
(
    Cuisine_Key  SERIAL PRIMARY KEY,
    Cuisine_Type VARCHAR(100)
);

INSERT INTO dimension_Cuisine (Cuisine_Type)
SELECT DISTINCT type
FROM table_cuisine;
--

-- TODO: DIMENSION GRADE TYPE
-- Create dimension_Grade_Type table
CREATE TABLE dimension_Grade_Type
(
    Grade_Type_Key SERIAL PRIMARY KEY,
    Grade_Type     VARCHAR(5)
);

-- Insert data into dimension_Grade_Type from source_table
INSERT INTO dimension_Grade_Type (Grade_Type)
SELECT DISTINCT type
FROM table_grade_type;

SELECT *
FROM dimension_Grade_Type;
-- Fact Table

CREATE TABLE Fact_Inspection
(
    Restaurant_Key      INT,
    Violation_Key       INT,
    Inspection_Type_Key INT,
    Inspection_Date_Key INT,
    Grade_Date_Key      INT,
    Cuisine_Key         INT,
    Grade_Type_Key      INT,
    Score               DOUBLE PRECISION,
    FOREIGN KEY (Restaurant_Key) REFERENCES dimension_Restaurant (Restaurant_Key),
    FOREIGN KEY (Violation_Key) REFERENCES dimension_Violation (Violation_Key),
    FOREIGN KEY (Inspection_Type_Key) REFERENCES dimension_Inspection_Type (Inspection_Type_Key),
    FOREIGN KEY (Inspection_Date_Key) REFERENCES dimension_date (date_key),
    FOREIGN KEY (Grade_Date_Key) REFERENCES dimension_date (date_key),
    FOREIGN KEY (Cuisine_Key) REFERENCES dimension_Cuisine (cuisine_key),
    FOREIGN KEY (Grade_Type_Key) REFERENCES dimension_Grade_Type (grade_type_key)

);


-- Insert data into Fact_Inspection
INSERT INTO Fact_Inspection (Restaurant_Key,
                             Violation_Key,
                             Inspection_Type_Key,
                             Inspection_Date_Key,
                             Grade_Date_Key,
                             Cuisine_Key,
                             Grade_Type_Key,
                             Score)
SELECT dr.Restaurant_Key,
       dv.Violation_Key,
       dit.Inspection_Type_Key,
       di.Date_Key as Inspection_Date_Key,
       dg.Date_Key as Grade_Date_Key,
       dc.Cuisine_Key,
       dgt.Grade_Type_Key,
       tri."SCORE"
FROM table_restaurant_inspection_dataset tri
         RIGHT JOIN dimension_Restaurant dr ON tri."CAMIS" = dr.CAMIS
         RIGHT JOIN dimension_Violation dv ON tri."VIOLATION CODE" = dv.Violation_Code
         RIGHT JOIN dimension_Inspection_Type dit ON tri."INSPECTION TYPE" = dit.Inspection_Type
         RIGHT JOIN dimension_Date di ON tri."INSPECTION DATE" = di.Complete_Date
         RIGHT JOIN dimension_Date dg ON tri."GRADE DATE" = dg.Complete_Date
         RIGHT JOIN dimension_Cuisine dc ON tri."CUISINE DESCRIPTION"= dc.Cuisine_Type
         RIGHT JOIN dimension_Grade_Type dgt ON tri."GRADE" = dgt.Grade_Type;


SELECT *
FROM Fact_Inspection;

SELECT count(*)
FROM Fact_Inspection;