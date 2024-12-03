SELECT * FROM md_water_services.employee;
use md_water_services;

-- join visits and locstion table
SELECT
    location.province_name,
    location.town_name,
    visits.visit_count,
    visits.location_id
FROM
    location
JOIN
    visits ON location.location_id = visits.location_id;
-- join water_source on they shared between water_source and visits

SELECT
    location.province_name,
    location.town_name,
    visits.visit_count,
    visits.location_id,
    water_source.type_of_water_source,
    water_source.number_of_people_served
FROM
    location
JOIN
    visits ON location.location_id = visits.location_id
JOIN
    water_source ON visits.source_id = water_source.source_id;
-- WHERE visits.visit_count = 1;

SELECT
    location.province_name,
    location.town_name,
    visits.visit_count,
    visits.location_id,
    water_source.type_of_water_source,
    water_source.number_of_people_served
FROM
    location
JOIN
    visits ON location.location_id = visits.location_id
JOIN
    water_source ON visits.source_id = water_source.source_id
WHERE 
    visits.visit_count = 1;
--  remove the location_id and visit_count columns. add location_type and time_in_queue
SELECT
    location.province_name,
    location.town_name,
	water_source.type_of_water_source,
    location.location_type,
    water_source.number_of_people_served,
    visits.time_in_queue
FROM
    location
JOIN
    visits ON location.location_id = visits.location_id
JOIN
    water_source ON visits.source_id = water_source.source_id
WHERE 
    visits.visit_count = 1;
    
 -- This table assembles data from different tables into one to simplify analysis
 SELECT
 water_source.type_of_water_source,
 location.town_name,
 location.province_name,
 location.location_type,
 water_source.number_of_people_served,
 visits.time_in_queue,
 well_pollution.results
 FROM
 visits
 LEFT JOIN
 well_pollution
 ON well_pollution.source_id = visits.source_id
 INNER JOIN
 location
 ON location.location_id = visits.location_id
 INNER JOIN
 water_source
 ON water_source.source_id = visits.source_id
 WHERE
 visits.visit_count = 1;
 
  CREATE VIEW combined_analysis_table AS
 -- This view assembles data from different tables into one to simplify analysis
 SELECT
 water_source.type_of_water_source AS source_type,
 location.town_name,
 location.province_name,
 location.location_type,
 water_source.number_of_people_served AS people_served,
 visits.time_in_queue,
 well_pollution.results
 FROM
 visits
 LEFT JOIN
 well_pollution
 ON well_pollution.source_id = visits.source_id
 INNER JOIN
 location
 ON location.location_id = visits.location_id
 INNER JOIN
 water_source
 ON water_source.source_id = visits.source_id
 WHERE
 visits.visit_count = 1;
 
 -- 09:21
 WITH province_totals AS (-- This CTE calculates the population of each province
 SELECT
 province_name,
 SUM(people_served) AS total_ppl_serv
 FROM
 combined_analysis_table
 GROUP BY
 province_name
 )
 SELECT
 ct.province_name,-- These case statements create columns for each type of source.-- The results are aggregated and percentages are calculated
 ROUND((SUM(CASE WHEN source_type = 'river'
 THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
 ROUND((SUM(CASE WHEN source_type = 'shared_tap'
 THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
 ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
 THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
 ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
 THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
 ROUND((SUM(CASE WHEN source_type = 'well'
 THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
 FROM
 combined_analysis_table ct
 JOIN
 province_totals pt ON ct.province_name = pt.province_name
 GROUP BY
 ct.province_name
 ORDER BY
 ct.province_name;
 
 CREATE VIEW province_water_sources AS
WITH province_totals AS (
    -- This CTE calculates the population of each province
    SELECT 
        province_name, 
        SUM(people_served) AS total_ppl_serv 
    FROM 
        combined_analysis_table 
    GROUP BY 
        province_name 
) 
SELECT 
    ct.province_name,
    -- These case statements create columns for each type of source.
    -- The results are aggregated and percentages are calculated
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well 
FROM 
    combined_analysis_table ct 
JOIN 
    province_totals pt ON ct.province_name = pt.province_name 
GROUP BY 
    ct.province_name 
ORDER BY 
    ct.province_name;
    
 WITH province_totals AS (
    -- This CTE calculates the population of each province
    SELECT 
        province_name, 
        SUM(people_served) AS total_ppl_serv 
    FROM 
        combined_analysis_table 
    GROUP BY 
        province_name 
) 
SELECT * FROM province_totals;
   
-- 09:25
WITH province_totals AS (
    SELECT province_name, SUM(people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name
)
SELECT ct.province_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN province_totals pt ON ct.province_name = pt.province_name
GROUP BY ct.province_name
ORDER BY ct.province_name;
 -- 09:03 
 WITH province_totals AS (
    SELECT province_name, SUM(people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name
)
SELECT ct.province_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN province_totals pt ON ct.province_name = pt.province_name
GROUP BY ct.province_name, pt.total_ppl_serv
ORDER BY ct.province_name;

-- 09:36

WITH province_totals AS (
    SELECT province_name, SUM(people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name
)
SELECT ct.province_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN province_totals pt ON ct.province_name = pt.province_name
GROUP BY ct.province_name, pt.total_ppl_serv
ORDER BY ct.province_name;
-- 09:54 aggregate per town
WITH province_totals AS (
    SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name, town_name
)
SELECT ct.province_name, ct.town_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN province_totals pt ON ct.province_name = pt.province_name AND ct.town_name = pt.town_name
GROUP BY ct.province_name, ct.town_name, pt.total_ppl_serv
ORDER BY ct.province_name, ct.town_name;

-- 09:55
WITH province_totals AS (
    SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name, town_name
)
SELECT ct.province_name, ct.town_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN province_totals pt ON ct.province_name = pt.province_name AND ct.town_name = pt.town_name
GROUP BY ct.province_name, ct.town_name, pt.total_ppl_serv
ORDER BY ct.province_name, ct.town_name;

-- 10:01 
 WITH town_totals AS (-- This CTE calculates the population of each town
 -- Since there are two Harare towns, we have to group by province_name and town_name
 SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
 FROM combined_analysis_table
 GROUP BY province_name,town_name
 )
 SELECT
 ct.province_name,
 ct.town_name,
 ROUND((SUM(CASE WHEN source_type = 'river'
 THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
 ROUND((SUM(CASE WHEN source_type = 'shared_tap'
 THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
 ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
 THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
 ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
 THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
 ROUND((SUM(CASE WHEN source_type = 'well'
 THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
 FROM
 combined_analysis_table ct
 JOIN -- Since the town names are not unique, we have to join on a composite key
 town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
 GROUP BY -- We group by province first, then by town.
 ct.province_name,
 ct.town_name
 ORDER BY
 ct.town_name;
 
-- 10:17
 CREATE TEMPORARY TABLE town_aggregated_water_access
  WITH town_totals AS (-- This CTE calculates the population of each town
 -- Since there are two Harare towns, we have to group by province_name and town_name
 SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
 FROM combined_analysis_table
 GROUP BY province_name,town_name
 )
 SELECT
 ct.province_name,
 ct.town_name,
 ROUND((SUM(CASE WHEN source_type = 'river'
 THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
 ROUND((SUM(CASE WHEN source_type = 'shared_tap'
 THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
 ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
 THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
 ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
 THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
 ROUND((SUM(CASE WHEN source_type = 'well'
 THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
 FROM
 combined_analysis_table ct
 JOIN -- Since the town names are not unique, we have to join on a composite key
 town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
 GROUP BY -- We group by province first, then by town.
 ct.province_name,
 ct.town_name
 ORDER BY
 ct.town_name;
 -- 10:17 results of temp table
 select *
 from town_aggregated_water_access;
 -- 10:25  which town has the highest ratio of people who have taps, but have no running water?
 
   SELECT
 province_name,
 town_name,
 ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
from  town_aggregated_water_access;

-- summary report (insights)
-- 1
select 
location_type, count(*) as number_of_records
from location
group by location_type
order by number_of_records;
-- 2
select distinct 
type_of_water_source,round((sum(number_of_people_served)/27638148)*100,0) as percentage_people_served
from water_source
group by type_of_water_source
order by percentage_people_served desc;
-- 3,4 and 5 use below code
select distinct 
type_of_water_source,round((sum(number_of_people_served)/27638148)*100,0) as percentage_people_served
from water_source
group by type_of_water_source
order by percentage_people_served desc;

-- 6
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
 
 -- 
 WITH town_totals AS (
    SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
    FROM combined_analysis_table
    WHERE province_name = 'Amanzi'
    GROUP BY province_name, town_name
),
river_usage AS (
    SELECT
        ca.province_name,
        ca.town_name,
        SUM(CASE WHEN ca.source_type = 'river' THEN ca.people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv AS river_percentage
    FROM combined_analysis_table ca
    JOIN town_totals tt ON ca.province_name = tt.province_name AND ca.town_name = tt.town_name
    WHERE ca.province_name = 'Amanzi'
    GROUP BY ca.province_name, ca.town_name, tt.total_ppl_serv
)
SELECT 
    town_name, 
    MAX(river_percentage) AS max_river_percentage
FROM 
    river_usage
GROUP BY 
    town_name
ORDER BY 
    max_river_percentage DESC
LIMIT 1;

WITH town_totals AS (
    SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name, town_name
),
tap_access AS (
    SELECT
        ca.province_name,
        ca.town_name,
        SUM(CASE WHEN ca.source_type IN ('tap_in_home', 'tap_in_home_broken') THEN ca.people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv AS tap_percentage
    FROM combined_analysis_table ca
    JOIN town_totals tt ON ca.province_name = tt.province_name AND ca.town_name = tt.town_name
    GROUP BY ca.province_name, ca.town_name, tt.total_ppl_serv
),
province_check AS (
    SELECT 
        province_name,
        MIN(tap_percentage) AS min_tap_percentage
    FROM 
        tap_access
    GROUP BY 
        province_name
)
SELECT 
    province_name 
FROM 
    province_check
WHERE 
    min_tap_percentage < 50;
