/*
03_stg_casualties_2015_2024.sql

Staging layer for casualty-level records within the predicting_premium_risk database.

Purpose:
- Time-scope data (2015-2024) via semi-join with stg.collisions.
- Standardise 'raw' TEXT strings into deliberate typed formats (INT, NUMERIC).
- Prepare casualty records for downstream joins at the vehicle and collision grain.

Design Choices:
- Filter logic: Scoped by collision_index as source lacks native date fields.
- Data Sanitization: Trims whitespace and converts 'NA' literals to NULL prior to casting.
- Lineage: Preserves original categorical and sentinel codes (-1) exactly as defined.
- Fractional Values: Enhanced severity and adjusted fields cast to NUMERIC.

Fields Dropped (Redundant/Obsolete):
- collision_ref_no
*/

DROP TABLE IF EXISTS stg.casualties_2015_2024;

CREATE TABLE stg.casualties_2015_2024 AS
SELECT
  collision_index,
  NULLIF(NULLIF(TRIM(collision_year), ''), 'NA')::int AS collision_year,
  NULLIF(NULLIF(TRIM(vehicle_reference), ''), 'NA')::int AS vehicle_reference,
  NULLIF(NULLIF(TRIM(casualty_reference), ''), 'NA')::int AS casualty_reference,
  NULLIF(NULLIF(TRIM(casualty_class), ''), 'NA')::int AS casualty_class,
  NULLIF(NULLIF(TRIM(sex_of_casualty), ''), 'NA')::int AS sex_of_casualty,
  NULLIF(NULLIF(TRIM(age_of_casualty), ''), 'NA')::int AS age_of_casualty,
  NULLIF(NULLIF(TRIM(age_band_of_casualty), ''), 'NA')::int AS age_band_of_casualty,
  NULLIF(NULLIF(TRIM(casualty_severity), ''), 'NA')::int AS casualty_severity,
  NULLIF(NULLIF(TRIM(pedestrian_location), ''), 'NA')::int AS pedestrian_location,
  NULLIF(NULLIF(TRIM(pedestrian_movement), ''), 'NA')::int AS pedestrian_movement,
  NULLIF(NULLIF(TRIM(car_passenger), ''), 'NA')::int AS car_passenger,
  NULLIF(NULLIF(TRIM(bus_or_coach_passenger), ''), 'NA')::int AS bus_or_coach_passenger,
  NULLIF(NULLIF(TRIM(pedestrian_road_maintenance_worker), ''), 'NA')::int AS pedestrian_road_maintenance_worker,
  NULLIF(NULLIF(TRIM(casualty_type), ''), 'NA')::int AS casualty_type,
  NULLIF(NULLIF(TRIM(casualty_imd_decile), ''), 'NA')::int AS casualty_imd_decile,
  NULLIF(NULLIF(TRIM(lsoa_of_casualty), ''), 'NA') AS lsoa_of_casualty,
  NULLIF(NULLIF(TRIM(enhanced_casualty_severity), ''), 'NA')::numeric AS enhanced_casualty_severity,
  NULLIF(NULLIF(TRIM(casualty_injury_based), ''), 'NA')::numeric AS casualty_injury_based,
  NULLIF(NULLIF(TRIM(casualty_adjusted_severity_serious), ''), 'NA')::numeric AS casualty_adjusted_severity_serious,
  NULLIF(NULLIF(TRIM(casualty_adjusted_severity_slight), ''), 'NA')::numeric AS casualty_adjusted_severity_slight,
  NULLIF(NULLIF(TRIM(casualty_distance_banding), ''), 'NA')::int AS casualty_distance_banding
FROM raw.casualties
WHERE
  collision_index IN (
    SELECT collision_index
    FROM stg.collisions_2015_2024
  );