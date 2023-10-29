


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

-- TODO : TABLE FOR RESTAURANT INFORMATION

CREATE TABLE table_restaurant_info
(
    ID                  SERIAL PRIMARY KEY,
    CAMIS               bigint,
    DBA                 TEXT,
    PHONE               TEXT,
    ADDRESS_ID          INT,
    CUISINE_ID INT,

    CONSTRAINT fk_address FOREIGN KEY (ADDRESS_ID) REFERENCES table_address (id),
    CONSTRAINT fk_cuisine FOREIGN KEY (CUISINE_ID) REFERENCES table_cuisine (id)

);

INSERT INTO table_restaurant_info (CAMIS, DBA,PHONE)
SELECT DISTINCT "CAMIS", "DBA", "PHONE"
FROM table_restaurant_inspection_dataset;

SELECT count(*) FROM table_restaurant_info;

-- TODO : TABLE FOR INSPECTION

CREATE TABLE table_restaurant
(
    ID                  SERIAL PRIMARY KEY,
    RESTAURANT_INFO     INT,
    VIOLATION_ID INT,
    "INSPECTION DATE" text,
    "GRADE DATE" text,
    INSPECTION_RESULT int,
    CONSTRAINT fk_restaurant_info FOREIGN KEY (RESTAURANT_INFO) REFERENCES table_restaurant_info (id),
    CONSTRAINT fk_violation FOREIGN KEY (VIOLATION_ID) REFERENCES table_violation (id),
    CONSTRAINT fk_inspection_result FOREIGN KEY (INSPECTION_RESULT) REFERENCES table_inspection_results (id)
);

SELECT * from table_address;


INSERT INTO table_restaurant (
    RESTAURANT_INFO,
    ADDRESS,
    PHONE,
    CUISINE_DESCRIPTION,
    VIOLATION_ID,
    "INSPECTION DATE",
    "GRADE DATE",
    INSPECTION_RESULT
)
SELECT
    ri.id,
    ta.id,
    M."PHONE",
    C.id,
    V.id,
    M."INSPECTION DATE",
    M."GRADE DATE",
   IR.ID as "INSPECTION RESULT"
FROM public.table_restaurant_inspection_dataset M
LEFT JOIN table_restaurant_info ri ON M."CAMIS" = ri.CAMIS
LEFT JOIN table_cuisine C ON M."CUISINE DESCRIPTION" = C.cuisine_description
LEFT JOIN table_violation V ON M."VIOLATION CODE" = V.violation_code

LEFT JOIN table_inspection_results IR ON IR.refer_id = M."ID"
WHERE M."DBA" IS NOT NULL;

SELECT"CAMIS", "DBA", "PHONE" FROM  public.table_restaurant_inspection_dataset;


SELECT COUNT(*) FROM (
    SELECT DISTINCT "CAMIS", "DBA" FROM  public.table_restaurant_inspection_dataset
                     ) as subquery;
SELECT "DBA","CUISINE DESCRIPTION"  FROM table_restaurant_inspection_dataset where "DBA" = 'BLEECKER SREET PIZZA';

SELECT  "DBA" FROM table_restaurant_inspection_dataset;







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