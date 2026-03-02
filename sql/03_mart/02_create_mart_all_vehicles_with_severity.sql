/*
02_create_mart_all_vehicles_with_severity.sql

Vehicle-level join layer for the predicting_premium_risk mart schema.

Purpose:
- Attach vehicle-level severity outcomes onto the full set of 
  collision-involved vehicles.
- Ensure vehicles with no linked casualty rows are retained for 
  downstream frequency calculations.

Design choices:
- LEFT JOIN: keeps all vehicles from stg.vehicles_2015_2024, even when 
  no severity row exists.
- COALESCE to zero: treats missing severity as zero injuries, so later 
  aggregation can sum cleanly without NULL handling.
- No banding and no aggregation: this script is only about building 
  a clean vehicle-level base table for later steps.
*/

DROP TABLE IF EXISTS mart.all_vehicles_with_severity_2015_2024;

CREATE TABLE mart.all_vehicles_with_severity_2015_2024 AS
SELECT
    v.collision_index,
    v.vehicle_reference,
    v.vehicle_type,
    v.propulsion_code,
    v.engine_capacity_cc,
    v.age_of_vehicle,
    COALESCE(s.slight_count, 0)::int             AS slight_count,
    COALESCE(s.serious_count, 0)::int            AS serious_count,
    COALESCE(s.fatal_count, 0)::int              AS fatal_count,
    COALESCE(s.weighted_severity_score, 0)::int  AS weighted_severity_score
FROM stg.vehicles_2015_2024 AS v
LEFT JOIN mart.vehicle_level_severity_2015_2024 AS s
    ON v.collision_index = s.collision_index
    AND v.vehicle_reference = s.vehicle_reference;

ALTER TABLE mart.all_vehicles_with_severity_2015_2024
    ADD CONSTRAINT pk_all_vehicles_with_severity_2015_2024
    PRIMARY KEY (collision_index, vehicle_reference);