/*
01_create_mart_vehicle_level_severity.sql

Vehicle-level severity aggregation layer for the predicting_premium_risk mart schema.

Purpose:
- Aggregate casualties (severity & count) to the vehicle involvement grain: 
  1 row per (collision_index, vehicle_reference) for vehicles with linked 
  casualty rows.
- Produce casualty severity counts per vehicle alongside a derived 
  weighted severity score.
- Create a table that can be safely joined onto stg.vehicles_2015_2024 
  in later mart steps.

Design choices:
- Vehicles with associated casualties only: this table includes only 
  vehicles with linked casualty rows; vehicles with no casualties will 
  be brought back later via LEFT JOIN from stg.vehicles with COALESCE to zero.
- Vehicle-first aggregation: severity is aggregated at the vehicle 
  involvement level before any vehicular profile grouping to preserve 
  granularity at this moment.
- Heuristic weighting: severity is represented using three fixed 
  constants aligned to the ordinal injury categories in STATS19. This 
  enables building of a heuristic risk profile consistent with the 
  aims of the business task.
*/

DROP TABLE IF EXISTS mart.vehicle_level_severity_2015_2024;

CREATE TABLE mart.vehicle_level_severity_2015_2024 AS
WITH s AS (
    SELECT
        1::int  AS slight_weight,
        15::int AS serious_weight,
        60::int AS fatal_weight
),

v AS (
    SELECT
        casualties.collision_index,
        casualties.vehicle_reference,
        SUM(CASE WHEN casualties.casualty_severity = 3 THEN 1 ELSE 0 END)::int AS slight_count,
        SUM(CASE WHEN casualties.casualty_severity = 2 THEN 1 ELSE 0 END)::int AS serious_count,
        SUM(CASE WHEN casualties.casualty_severity = 1 THEN 1 ELSE 0 END)::int AS fatal_count
    FROM stg.casualties_2015_2024 AS casualties
    GROUP BY
        casualties.collision_index,
        casualties.vehicle_reference
)

SELECT
    v.collision_index,
    v.vehicle_reference,
    v.slight_count,
    v.serious_count,
    v.fatal_count,
    (
          (v.slight_count  * s.slight_weight)
        + (v.serious_count * s.serious_weight)
        + (v.fatal_count   * s.fatal_weight)
    )::int AS weighted_severity_score
FROM v
CROSS JOIN s;

ALTER TABLE mart.vehicle_level_severity_2015_2024
    ADD CONSTRAINT pk_vehicle_level_severity_2015_2024
    PRIMARY KEY (collision_index, vehicle_reference);