/*
01_stg_collisions_2015_2024.sql

Staging layer for collision-level records within the predicting_premium_risk database.

Purpose:
- Time-scope data (2015-2024) to establish the master temporal filter for downstream joins.
- Standardise 'raw' TEXT strings into deliberate typed formats (DATE, INT, NUMERIC).
- Resolve ambiguity by renaming generic terms to clear column names (e.g., date -> accident_date).

Design Choices:
- Filter logic: Direct date casting from raw source to define the 10-year study period.
- Data Sanitization: Trims whitespace and converts 'NA' literals to NULL prior to casting.
- Schema Integrity: Uses explicit casting to enforce data types early in the pipeline.

Fields Dropped (Redundant/Obsolete):
- collision_ref_no, junction_detail_historic, pedestrian_crossing_human_control_historic, pedestrian_crossing_physical_facilities_historic, carriageway_hazards_historic
*/

DROP TABLE IF EXISTS stg.collisions_2015_2024;

CREATE TABLE stg.collisions_2015_2024 AS
SELECT
  collision_index,
  NULLIF(NULLIF(TRIM(collision_year), ''), 'NA')::int AS collision_year,
  NULLIF(NULLIF(TRIM(location_easting_osgr), ''), 'NA')::numeric AS location_easting_osgr,
  NULLIF(NULLIF(TRIM(location_northing_osgr), ''), 'NA')::numeric AS location_northing_osgr,
  NULLIF(NULLIF(TRIM(longitude), ''), 'NA')::numeric AS longitude,
  NULLIF(NULLIF(TRIM(latitude), ''), 'NA')::numeric AS latitude,
  NULLIF(NULLIF(TRIM(police_force), ''), 'NA')::int AS police_force,
  NULLIF(NULLIF(TRIM(local_authority_district), ''), 'NA')::int AS local_authority_district,
  NULLIF(NULLIF(TRIM(local_authority_ons_district), ''), 'NA') AS local_authority_ons_district,
  NULLIF(NULLIF(TRIM(local_authority_highway), ''), 'NA') AS local_authority_highway,
  NULLIF(NULLIF(TRIM(local_authority_highway_current), ''), 'NA') AS local_authority_highway_current,
  NULLIF(NULLIF(TRIM(collision_severity), ''), 'NA')::int AS collision_severity,
  NULLIF(NULLIF(TRIM(number_of_vehicles), ''), 'NA')::int AS number_of_vehicles,
  NULLIF(NULLIF(TRIM(number_of_casualties), ''), 'NA')::int AS number_of_casualties,
  to_date(NULLIF(NULLIF(TRIM(date), ''), 'NA'), 'DD/MM/YYYY') AS accident_date,
  NULLIF(NULLIF(TRIM(day_of_week), ''), 'NA')::int AS day_of_week,
  NULLIF(NULLIF(TRIM(time), ''), 'NA') AS accident_time,
  NULLIF(NULLIF(TRIM(first_road_class), ''), 'NA')::int AS first_road_class,
  NULLIF(NULLIF(TRIM(first_road_number), ''), 'NA')::int AS first_road_number,
  NULLIF(NULLIF(TRIM(road_type), ''), 'NA')::int AS road_type,
  NULLIF(NULLIF(TRIM(speed_limit), ''), 'NA')::int AS speed_limit,
  NULLIF(NULLIF(TRIM(junction_detail), ''), 'NA')::int AS junction_detail,
  NULLIF(NULLIF(TRIM(junction_control), ''), 'NA')::int AS junction_control,
  NULLIF(NULLIF(TRIM(second_road_class), ''), 'NA')::int AS second_road_class,
  NULLIF(NULLIF(TRIM(second_road_number), ''), 'NA')::int AS second_road_number,
  NULLIF(NULLIF(TRIM(pedestrian_crossing), ''), 'NA')::int AS pedestrian_crossing,
  NULLIF(NULLIF(TRIM(light_conditions), ''), 'NA')::int AS light_conditions,
  NULLIF(NULLIF(TRIM(weather_conditions), ''), 'NA')::int AS weather_conditions,
  NULLIF(NULLIF(TRIM(road_surface_conditions), ''), 'NA')::int AS road_surface_conditions,
  NULLIF(NULLIF(TRIM(special_conditions_at_site), ''), 'NA')::int AS special_conditions_at_site,
  NULLIF(NULLIF(TRIM(carriageway_hazards), ''), 'NA')::int AS carriageway_hazards,
  NULLIF(NULLIF(TRIM(urban_or_rural_area), ''), 'NA')::int AS urban_or_rural_area,
  NULLIF(NULLIF(TRIM(did_police_officer_attend_scene_of_accident), ''), 'NA')::int AS did_police_officer_attend_scene_of_accident,
  NULLIF(NULLIF(TRIM(trunk_road_flag), ''), 'NA')::int AS trunk_road_flag,
  NULLIF(NULLIF(TRIM(lsoa_of_accident_location), ''), 'NA') AS lsoa_of_accident_location,
  NULLIF(NULLIF(TRIM(enhanced_severity_collision), ''), 'NA')::int AS enhanced_severity_collision,
  NULLIF(NULLIF(TRIM(collision_injury_based), ''), 'NA')::int AS collision_injury_based,
  NULLIF(NULLIF(TRIM(collision_adjusted_severity_serious), ''), 'NA')::numeric AS collision_adjusted_severity_serious,
  NULLIF(NULLIF(TRIM(collision_adjusted_severity_slight), ''), 'NA')::numeric AS collision_adjusted_severity_slight
FROM raw.collisions
WHERE
  to_date(NULLIF(NULLIF(TRIM(date), ''), 'NA'), 'DD/MM/YYYY') >= DATE '2015-01-01'
  AND to_date(NULLIF(NULLIF(TRIM(date), ''), 'NA'), 'DD/MM/YYYY') <  DATE '2025-01-01';
