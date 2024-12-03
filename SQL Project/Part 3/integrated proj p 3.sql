-- 11:44 view the auditor report coulumn, location_id and true_water_source_score

SELECT * FROM md_water_services.auditor_report;
use md_water_services;

SELECT location_id,true_water_source_score
from auditor_report;

-- join the visits table to the auditor_report table. use subjective_quality_score, record_id and location_id.

SELECT
 auditor_report.location_id AS audit_location,
 auditor_report.true_water_source_score,
 visits.location_id AS visit_location,
 visits.record_id
 FROM
 auditor_report
 JOIN
 visits
 ON auditor_report.location_id = visits.location_id;
 
 -- 12:04  JOIN the visits table and the water_quality table, using the record_id as the connecting key.
  use md_water_services;
SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score,
    visits.location_id AS visit_location,
    visits.record_id,
    water_quality.subjective_quality_score
FROM
    auditor_report
JOIN
    visits ON auditor_report.location_id = visits.location_id
JOIN
    water_quality ON visits.record_id = water_quality.record_id;

-- 12:17  Since it is a duplicate, we can drop one of the location_id columns. Let's leave record_id and rename the scores to surveyor_score and auditor_score to make it clear which scoreswe're looking at in the results set.

SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
    visits ON auditor_report.location_id = visits.location_id
JOIN
    water_quality ON visits.record_id = water_quality.record_id;
-- 12:19 - 12:28

 SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
    visits ON auditor_report.location_id = visits.location_id
JOIN
    water_quality ON visits.record_id = water_quality.record_id
WHERE
    auditor_report.true_water_source_score = water_quality.subjective_quality_score
    AND visits.visit_count = 1
LIMIT 10000;
 -- 12:47 finding incorrect records
 
SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id,
    water_quality.subjective_quality_score AS surveyor_score,
    (auditor_report.true_water_source_score - water_quality.subjective_quality_score) AS score_difference
FROM
    auditor_report
JOIN
    visits ON auditor_report.location_id = visits.location_id
JOIN
    water_quality ON visits.record_id = water_quality.record_id
WHERE
    visits.visit_count = 1
HAVING
    score_difference != 0
LIMIT 10000;

-- 13:02 
SELECT
    visits.location_id,
    auditor_report.type_of_water_source AS auditor_source,
    water_source.type_of_water_source AS survey_source,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    visits
JOIN
    auditor_report
ON
    auditor_report.location_id = visits.location_id
JOIN
    water_quality 
ON 
visits.record_id = water_quality.record_id
JOIN
    water_source 
    ON 
    visits.source_id = water_source.source_id
WHERE
water_quality.subjective_quality_score != auditor_report.true_water_source_score
AND 
visits.visit_count = 1;

-- 13:15

SELECT
    visits.location_id,
    auditor_report.true_water_source_score AS auditor_source,
    visits.record_id,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    visits
JOIN
    auditor_report
ON
    auditor_report.location_id = visits.location_id
JOIN
    water_quality 
ON 
visits.record_id = water_quality.record_id
JOIN
    water_source 
    ON 
    visits.source_id = water_source.source_id
WHERE
water_quality.subjective_quality_score != auditor_report.true_water_source_score
AND 
visits.visit_count = 1;

-- 13:26
SELECT
    visits.location_id,
    visits.record_id,visits.assigned_employee_id,
        auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
    
FROM
    visits
JOIN
    auditor_report
ON
    auditor_report.location_id = visits.location_id
JOIN
    water_quality 
ON 
visits.record_id = water_quality.record_id
JOIN
    water_source 
    ON 
    visits.source_id = water_source.source_id
WHERE
water_quality.subjective_quality_score != auditor_report.true_water_source_score
AND 
visits.visit_count = 1
LIMIT 10000;

-- 13:41
SELECT
    visits.location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    visits
JOIN
    auditor_report ON auditor_report.location_id = visits.location_id
JOIN
    water_quality ON visits.record_id = water_quality.record_id
JOIN
    water_source ON visits.source_id = water_source.source_id
JOIN
    employee ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE
    water_quality.subjective_quality_score != auditor_report.true_water_source_score
    AND visits.visit_count = 1
LIMIT 10000;

-- 13:57 create cte

WITH Incorrect_records AS (
    SELECT
        visits.location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        water_quality.subjective_quality_score AS surveyor_score
    FROM
        visits
    JOIN
        auditor_report ON auditor_report.location_id = visits.location_id
    JOIN
        water_quality ON visits.record_id = water_quality.record_id
    JOIN
        water_source ON visits.source_id = water_source.source_id
    JOIN
        employee ON visits.assigned_employee_id = employee.assigned_employee_id
    WHERE
        water_quality.subjective_quality_score != auditor_report.true_water_source_score
        AND visits.visit_count = 1
    LIMIT 10000
)

SELECT DISTINCT employee_name
FROM incorrect_records;

-- 14:07 how many mistakes each employee made

WITH incorrect_records AS (
    SELECT
        visits.location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        water_quality.subjective_quality_score AS surveyor_score
    FROM
        visits
    JOIN
        auditor_report ON auditor_report.location_id = visits.location_id
    JOIN
        water_quality ON visits.record_id = water_quality.record_id
    JOIN
        water_source ON visits.source_id = water_source.source_id
    JOIN
        employee ON visits.assigned_employee_id = employee.assigned_employee_id
    WHERE
        water_quality.subjective_quality_score != auditor_report.true_water_source_score
        AND visits.visit_count = 1
    LIMIT 10000
)
SELECT
    employee_name,
    COUNT(*) AS number_of_mistakes
FROM
    incorrect_records
GROUP BY
    employee_name;
--  1. We have to first calculate the number of times someone's name comes up. (we just did that in the previous query). Let's call it error_count.
--  2. Then, we need to calculate the average number of mistakes employees made. We can do that by taking the average of the previous query's

WITH Incorrect_records AS (
    SELECT
        visits.location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        water_quality.subjective_quality_score AS surveyor_score
    FROM
        visits
    JOIN
        auditor_report ON auditor_report.location_id = visits.location_id
    JOIN
        water_quality ON visits.record_id = water_quality.record_id
    JOIN
        water_source ON visits.source_id = water_source.source_id
    JOIN
        employee ON visits.assigned_employee_id = employee.assigned_employee_id
    WHERE
        water_quality.subjective_quality_score != auditor_report.true_water_source_score
        AND visits.visit_count = 1
    LIMIT 10000
),
Error_counts AS (
    SELECT
        employee_name,
        COUNT(*) AS error_count
    FROM
        Incorrect_records
    GROUP BY
        employee_name
)
SELECT * FROM Error_counts;
-- question 2

WITH Incorrect_records AS (
    SELECT
        visits.location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        water_quality.subjective_quality_score AS surveyor_score
    FROM
        visits
    JOIN
        auditor_report ON auditor_report.location_id = visits.location_id
    JOIN
        water_quality ON visits.record_id = water_quality.record_id
    JOIN
        water_source ON visits.source_id = water_source.source_id
    JOIN
        employee ON visits.assigned_employee_id = employee.assigned_employee_id
    WHERE
        water_quality.subjective_quality_score != auditor_report.true_water_source_score
        AND visits.visit_count = 1
    LIMIT 10000
),
Error_counts AS (
    SELECT
        employee_name,
        COUNT(*) AS error_count
    FROM
        Incorrect_records
    GROUP BY
        employee_name
),
Avg_error_count_per_empl AS (
    SELECT 
        AVG(error_count) AS avg_error_count_per_empl 
    FROM 
        Error_counts
)
SELECT * FROM Avg_error_count_per_empl;
-- question 3 MOST MISTAKES PER EMPLOYEE
WITH Incorrect_records AS (
    SELECT
        visits.location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        water_quality.subjective_quality_score AS surveyor_score
    FROM
        visits
    JOIN
        auditor_report ON auditor_report.location_id = visits.location_id
    JOIN
        water_quality ON visits.record_id = water_quality.record_id
    JOIN
        water_source ON visits.source_id = water_source.source_id
    JOIN
        employee ON visits.assigned_employee_id = employee.assigned_employee_id
    WHERE
        water_quality.subjective_quality_score != auditor_report.true_water_source_score
        AND visits.visit_count = 1
    LIMIT 10000
),
Error_counts AS (
    SELECT
        employee_name,
        COUNT(*) AS error_count
    FROM
        Incorrect_records
    GROUP BY
        employee_name
),
Avg_error_count_per_empl AS (
    SELECT 
        AVG(error_count) AS avg_error_count_per_empl 
    FROM 
        Error_counts
)
SELECT 
    employee_name, 
    error_count 
FROM 
    Error_counts 
WHERE 
    error_count > (SELECT avg_error_count_per_empl FROM Avg_error_count_per_empl);

-- 14:28 create VIEW 
 CREATE VIEW Incorrect_records AS (
 SELECT
 auditor_report.location_id,
 visits.record_id,
 employee.employee_name,
 auditor_report.true_water_source_score AS auditor_score,
 wq.subjective_quality_score AS surveyor_score,
 auditor_report.statements AS statements
 FROM
 auditor_report
 JOIN
 visits
 ON auditor_report.location_id = visits.location_id
 JOIN
 water_quality AS wq
 ON visits.record_id = wq.record_id
 JOIN
 employee
 ON employee.assigned_employee_id = visits.assigned_employee_id
 WHERE
 visits.visit_count =1
 AND auditor_report.true_water_source_score != wq.subjective_quality_score);
 
 -- 14:30
 SELECT * FROM Incorrect_records;
 
 -- 14:33 conver query error_count
WITH error_count AS (
 SELECT
 employee_name,
 COUNT(employee_name) AS number_of_mistakes
 FROM
 Incorrect_records 
 GROUP BY
 employee_name)
 
 SELECT * FROM error_count;
 -- 14:35 calculate the average of the number_of_mistakes in error_count. 
 WITH Incorrect_records AS (
    SELECT
        visits.location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        water_quality.subjective_quality_score AS surveyor_score
    FROM
        visits
    JOIN
        auditor_report ON auditor_report.location_id = visits.location_id
    JOIN
        water_quality ON visits.record_id = water_quality.record_id
    JOIN
        water_source ON visits.source_id = water_source.source_id
    JOIN
        employee ON visits.assigned_employee_id = employee.assigned_employee_id
    WHERE
        water_quality.subjective_quality_score != auditor_report.true_water_source_score
        AND visits.visit_count = 1
    LIMIT 10000
),
error_count AS (
    SELECT 
        employee_name, 
        COUNT(employee_name) AS number_of_mistakes 
    FROM 
        Incorrect_records  
    GROUP BY 
        employee_name
)
SELECT 
    AVG(number_of_mistakes) AS avg_number_of_mistakes 
FROM 
    error_count;
-- 14:37 

WITH Incorrect_records AS (
    SELECT
        visits.location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        water_quality.subjective_quality_score AS surveyor_score
    FROM
        visits
    JOIN
        auditor_report ON auditor_report.location_id = visits.location_id
    JOIN
        water_quality ON visits.record_id = water_quality.record_id
    JOIN
        water_source ON visits.source_id = water_source.source_id
    JOIN
        employee ON visits.assigned_employee_id = employee.assigned_employee_id
    WHERE
        water_quality.subjective_quality_score != auditor_report.true_water_source_score
        AND visits.visit_count = 1
    LIMIT 10000
),
error_count AS (
    SELECT 
        employee_name, 
        COUNT(employee_name) AS number_of_mistakes 
    FROM 
        Incorrect_records  
    GROUP BY 
        employee_name
)
SELECT 
    employee_name, 
    number_of_mistakes 
FROM 
    error_count 
WHERE 
    number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count);
-- Convert the suspect_list to a CTE

WITH Incorrect_records AS (
    SELECT
        visits.location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        water_quality.subjective_quality_score AS surveyor_score
    FROM
        visits
    JOIN
        auditor_report ON auditor_report.location_id = visits.location_id
    JOIN
        water_quality ON visits.record_id = water_quality.record_id
    JOIN
        water_source ON visits.source_id = water_source.source_id
    JOIN
        employee ON visits.assigned_employee_id = employee.assigned_employee_id
    WHERE
        water_quality.subjective_quality_score != auditor_report.true_water_source_score
        AND visits.visit_count = 1
    LIMIT 10000
),
error_count AS (
    SELECT 
        employee_name, 
        COUNT(employee_name) AS number_of_mistakes 
    FROM 
        Incorrect_records  
    GROUP BY 
        employee_name
),
avg_error_count_per_empl AS (
    SELECT 
        AVG(number_of_mistakes) AS avg_error_count_per_empl 
    FROM 
        error_count
),
suspect_list AS (
    SELECT 
        employee_name, 
        number_of_mistakes 
    FROM 
        error_count 
    WHERE 
        number_of_mistakes > (SELECT avg_error_count_per_empl FROM avg_error_count_per_empl)
)
SELECT 
    employee_name, 
    number_of_mistakes 
FROM 
    suspect_list;
-- 14:44 
 WITH error_count AS (
 SELECT
 employee_name,
 COUNT(employee_name) AS number_of_mistakes
 FROM
 Incorrect_records
 GROUP BY
 employee_name),
 suspect_list AS (
 SELECT
 employee_name,
 number_of_mistakes
 FROM
 error_count
 WHERE
 number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
 SELECT
 employee_name,
 location_id,
 statements
 FROM
 Incorrect_records
 WHERE
 employee_name in (SELECT employee_name FROM suspect_list);
 
 -- filter records that refer to "cash"
 
 WITH error_count AS (
 SELECT
 employee_name,
 COUNT(employee_name) AS number_of_mistakes
 FROM
 Incorrect_records
 GROUP BY
 employee_name),
 suspect_list AS (
 SELECT
 employee_name,
 number_of_mistakes
 FROM
 error_count
 WHERE
 number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
 SELECT
 employee_name,
 location_id,
 statements
 FROM
 Incorrect_records
 WHERE 
    employee_name IN (SELECT employee_name FROM suspect_list)
    AND statements LIKE '%cash%';
    
  -- 14:58
  WITH error_count AS (
 SELECT
 employee_name,
 COUNT(employee_name) AS number_of_mistakes
 FROM
 Incorrect_records
 GROUP BY
 employee_name),
 suspect_list AS (
 SELECT
 employee_name,
 number_of_mistakes
 FROM
 error_count
 WHERE
 number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
 SELECT
 employee_name,
 location_id,
 statements
 FROM
 Incorrect_records
 WHERE 
    employee_name NOT IN (SELECT employee_name FROM suspect_list)
    AND statements LIKE '%cash%';
-- EMPTY RESULT!! so no one, except the four suspects, has these allegations of bribery.
  