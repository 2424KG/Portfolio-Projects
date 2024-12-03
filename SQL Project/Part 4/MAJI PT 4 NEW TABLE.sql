 CREATE TABLE Project_progress (
 Project_id SERIAL PRIMARY KEY,
 source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
 Address VARCHAR(50),
 Town VARCHAR(30),
 Province VARCHAR(30),
 Source_type VARCHAR(50),
 Improvement VARCHAR(50),
 Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
 Date_of_completion DATE,
 Comments TEXT
 );
 
  -- Project_progress_query
 SELECT
 location.address,
 location.town_name,
 location.province_name,
 water_source.source_id,
 water_source.type_of_water_source,
 well_pollution.results
 FROM
 water_source
 LEFT JOIN
 well_pollution ON water_source.source_id = well_pollution.source_id
 INNER JOIN
 visits ON water_source.source_id = visits.source_id
 INNER JOIN
 location ON location.location_id = visits.location_id;
 
 -- 11:06
 -- Project_progress_query with filters +  a. Where shared taps have queue times over 30 min.

SELECT 
    location.address, 
    location.town_name, 
    location.province_name, 
    water_source.source_id,
    water_source.type_of_water_source, 
    well_pollution.results 
FROM water_source 
LEFT JOIN well_pollution ON water_source.source_id = well_pollution.source_id 
INNER JOIN visits ON water_source.source_id = visits.source_id 
INNER JOIN location ON location.location_id = visits.location_id
WHERE 
    visits.visit_count = 1
    AND (
        (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue > 30)
    );
-- IMPROVEMENTS COLOUMN
-- Project_progress_query with Improvements column
SELECT 
    water_source.source_id, 
    location.address, 
    location.town_name, 
    location.province_name, 
    water_source.type_of_water_source,
    CASE 
        WHEN water_source.type_of_water_source = 'river' THEN 'Drill wells'
        WHEN water_source.type_of_water_source = 'well' AND well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN water_source.type_of_water_source = 'well' AND well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN concat('Install ',FLOOR(visits.time_in_queue/ 30), ' taps nearby')
        WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS Improvement
FROM water_source 
JOIN visits ON water_source.source_id = visits.source_id 
JOIN location ON location.location_id = visits.location_id
LEFT JOIN well_pollution ON water_source.source_id = well_pollution.source_id 
WHERE 
    visits.visit_count = 1
 AND (
        well_pollution.results != 'Clean'
        OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
    ); -- 25398 ROWS RETURNED!!
    
    -- INSERT INTO Project_progress_query
    insert into project_progress (source_id, Address, Town, Province, Source_type, Improvement)
    SELECT 
    water_source.source_id, 
    location.address, 
    location.town_name, 
    location.province_name, 
    water_source.type_of_water_source,
    CASE 
        WHEN water_source.type_of_water_source = 'river' THEN 'Drill wells'
        WHEN water_source.type_of_water_source = 'well' AND well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN water_source.type_of_water_source = 'well' AND well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN concat('Install ',FLOOR(visits.time_in_queue/ 30), ' taps nearby')
        WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS Improvement
FROM water_source 
JOIN visits ON water_source.source_id = visits.source_id 
JOIN location ON location.location_id = visits.location_id
LEFT JOIN well_pollution ON water_source.source_id = well_pollution.source_id 
WHERE 
    visits.visit_count = 1
 AND (
        well_pollution.results != 'Clean'
        OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
    );
    
    select *
    from project_progress;
    
    