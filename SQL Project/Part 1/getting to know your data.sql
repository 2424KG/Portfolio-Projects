-- show tables in database
use md_water_services;
show tables; 

-- show all from Location table and limit to 5
describe location;
 select *
 from location limit 5;
 
 describe visits;
 select *
 from visits limit 5;  
 
 describe water_source;
 select *
 from water_source limit 5;
 
 select distinct type_of_water_source
 from water_source;
 
 select *
 from visits
 where time_in_queue > 500;
 
 select *
 from visits
 where time_in_queue = 0;
 
 select * from water_source
 where
 source_id = 'AkKi00881224'
 OR
 source_id = 'AkLu01628224'
OR
 source_id = 'AkRu05234224'
 OR
 source_id = 'HaRu19601224'
 OR
 source_id = 'HaZa21742224'
 OR
 source_id = 'SoRu36096224'
 OR
 source_id = 'SoRu37635224'
 OR 
 source_id = 'SoRu38776224';

describe water_quality;

select *
from water_quality
where subjective_quality_score= 10
and visit_count = 2 ;

select *
from well_pollution
limit 50;

select *
from well_pollution
where results = 'clean'
and biological > 0.01;

SELECT *FROM
 well_pollution
 WHERE
 description LIKE 'Clean_%';

SELECT * FROM
 Well_pollution
 WHERE
 pollutant_ppm > 0.01
 AND description LIKE'Clean_%';
 
 CREATE TABLE
 md_water_services.well_pollution_copy
 AS (
 SELECT
 *
 FROM
 md_water_services.well_pollution
 );
SET
 sql_safe_updates = 0;
 UPDATE
 well_pollution_copy
 SET
 description = 'Bacteria: E. coli'
 WHERE
 description = 'Clean Bacteria: E. coli';
 UPDATE
 well_pollution_copy
 SET
 description = 'Bacteria: Giardia Lamblia'
 WHERE
 description = 'Clean Bacteria: Giardia Lamblia';
 UPDATE
 well_pollution_copy
 SET
 results = 'Contaminated: Biological'
 WHERE
 biological > 0.01 AND results = 'Clean';
 
SELECT
 *
 FROM
 well_pollution_copy
 WHERE
 description LIKE "Clean_%"
 OR (results = "Clean" AND biological > 0.01);
 
  UPDATE
 well_pollution_copy
 SET
 description = 'Bacteria: E. coli'
 WHERE
 description = 'Clean Bacteria: E. coli';
 UPDATE
 well_pollution_copy
 SET
 description = 'Bacteria: Giardia Lamblia'
 WHERE
 description = 'Clean Bacteria: Giardia Lamblia';
 UPDATE
 well_pollution_copy
 SET
 results = 'Contaminated: Biological'
 DROP TABLE
 WHERE
 biological > 0.01 AND results = 'Clean';
 md_water_services.well_pollution_copy;

SELECT *
FROM well_pollution
WHERE description LIKE 'Clean_%' OR results = 'Clean' AND biological < 0.01 ;

SELECT * 
FROM well_pollution
WHERE description
IN ('Parasite: Cryptosporidium', 'biologically contaminated')
OR (results = 'Clean' AND biological > 0.01);