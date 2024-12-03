SELECT * FROM md_water_services.employee;

use md_water_services;
 SELECT LOWER(REPLACE(employee_name,' ','.'))
 FROM employee;

 SELECT
 CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email
 FROM
 employee;
 
 
set sql_safe_updates = 0;
 UPDATE employee
 SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),
 '@ndogowater.gov');
 
Select TRIM(phone_number) AS trimmed_phone_number
FROM employee;
set sql_safe_updates = 0;
UPDATE employee
SET phone_number = TRIM(phone_number)
WHERE LENGTH(phone_number) = 13;

SELECT town_name, COUNT(*) AS num_employees
FROM employee
GROUP BY town_name;

-- top 3 employee
SELECT assigned_employee_id, count(*) 
as number_of_visits
from visits
group by assigned_employee_id
order by number_of_visits desc
limit 3;

select *
from employee
where assigned_employee_id = '0' 
or assigned_employee_id = '1'
or assigned_employee_id = '2'
or assigned_employee_id = '30'
or assigned_employee_id = '34';

-- create a query that counts the number of records PER TOWN
describe location;
select town_name, count(*) as records_per_town
from location
group by town_name
order by records_per_town desc;

-- create a query that counts the number of records PER PROVINCED
select province_name, count(*) as records_per_province
from location
group by province_name
order by records_per_province desc;

SELECT 
    province_name, 
    town_name, 
    COUNT(*) AS records_per_town
FROM 
    location
GROUP BY 
    province_name, 
    town_name
ORDER BY 
    province_name asc ,
    records_per_town desc;

-- percentage of water sources in rural communities
-- Formula: (Number of rural water source/Total number of water sources) * 100

SELECT 23740 / (15910 + 23740) * 100 as rural_percentage;

-- Calculate the number of people surveyed
-- summing the 'number_of_people_served' column from the 'water_source' table


-- Count and sort different water source types
-- Group by type_of_water_source, counts occurances, and sorts in descending order

select type_of_water_source, count(type_of_water_source)
as number_of_sources
from water_source
group by type_of_water_source
order by number_of_sources desc;

-- Calculate the average number of people served per each water source type
-- Provide the average count of people served for each type of water source

select type_of_water_source, round( avg(number_of_people_served),0)
as average_people_per_source
from water_source
group by type_of_water_source
order by average_people_per_source;
 
 -- Order the results in descending order based on the total number of people served
select type_of_water_source, sum(number_of_people_served)
as population_served
from water_source
group by type_of_water_source
order by population_served desc;

-- Divide the sum of people served for each sorce type by the total number of citizens
-- Total number of citizens served: 27,628,140

select distinct type_of_water_source,
round((sum(number_of_people_served)/27628140)*100,0)
as percentage_people_served_per_source
from water_source
group by type_of_water_source
order by percentage_people_served_per_source desc;

--  use a window function on the total people served column, converting it into a rank.
 SELECT DISTINCT
 type_of_water_source,
 SUM(number_of_people_served) AS people_served,
 RANK()OVER(ORDER BY SUM(number_of_people_served)DESC)AS
 rank_by_population
 FROM
 water_source
 WHERE
 type_of_water_source != 'tap_in_home'
 GROUP BY
 type_of_water_source
 LIMIT 50;
 
 
 SELECT DISTINCT
 source_id,
 type_of_water_source,
 number_of_people_served,
 DENSE_RANK() OVER(ORDER BY number_of_people_served DESC) AS
 priority_rank
 FROM
 water_source
 WHERE
 type_of_water_source != 'tap_in_home'
 LIMIT 50;
 
 -- (PAGE 27) 1. How long did the survey take?
 
  Select
 timestampdiff(day,min(time_of_record),max(time_of_record)) AS Duration
 FROM
 visits;

 -- 2. What is the average total queue time for water?
 
  Select
 AVG(NULLIF(time_in_queue,0)) AS AVG_time_in_queue
 from
 visits;
 --  3. What is the average queue time on different days?
 SELECT 
    DAYNAME(time_of_record) AS day_of_week ,
    round( AVG(NULLIF(time_in_queue,0))) AS avg_queue_time
FROM 
    visits
GROUP BY day_of_week
ORDER BY day_of_week;

 --  4. How can we communicate this information efficiently?
SELECT
 TIME_FORMAT(TIME(time_of_record),'%H:00') AS hour_of_day,
 ROUND(AVG(NULLIF(time_in_queue,0)))AS avg_queue_time
 FROM
 visits
 GROUP BY
 hour_of_day
 ORDER BY
 hour_of_day;
 
 -- page 33
 SELECT
 TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
 ROUND(AVG(
 CASE
 WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
 ELSE NULL
 END
 ),0) AS Sunday,ROUND(AVG(
 CASE
 WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
 ELSE NULL
 END
 ),0) AS Monday, ROUND(AVG(
 CASE
 WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
 ELSE NULL
 END
 ),0) AS Tuesday ,ROUND(AVG(
 CASE
 WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
 ELSE NULL
 END
 ),0) AS Wednesday, ROUND(AVG(
 CASE
 WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
 ELSE NULL
 END
 ),0) AS Thursday, ROUND(AVG(
 CASE
 WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
 ELSE NULL
 END
 ),0) AS Friday, ROUND(AVG(
 CASE
 WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
 ELSE NULL
 END
 ),0) AS Saturday
 FROM
 visits
 WHERE
 time_in_queue != 0 
 GROUP BY
 hour_of_day
 ORDER BY
 hour_of_day;