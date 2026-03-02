/*
05_mart_quality_checks.sql

Quality assurance checks for mart.vehicle_level_severity_2015_2024.

Purpose:
- Validate structural integrity of the vehicle-level severity aggregation layer.
- Confirm grain enforcement at (collision_index, vehicle_reference).
- Ensure casualty counts and weighted severity calculations reconcile exactly with staging data.
- Provide explicit, auditable confirmation that no rows were lost, duplicated, 
  or miscalculated during aggregation.

Design choices:
- Checks focus on mart.vehicle_level_severity_2015_2024 because it is the first 
  transformation that changes grain and introduces weighted severity logic; 
  any error here would cascade through the remainder of the mart pipeline.
- Grain validation: duplicate detection query ensures the composite primary key
  is functionally unique prior to constraint enforcement.
- Row-count reconciliation: mart row count is compared to DISTINCT (collision_index, vehicle_reference)
  combinations from stg.casualties_2015_2024 to confirm one-to-one collapse from casualty to vehicle involvement level.
- Deterministic weight verification: weighted_severity_score is
  recomputed inline to ensure no arithmetic drift or CASE logic misalignment.
- Casualty parity check: total slight/serious/fatal counts in the mart must equal total
  casualty rows in staging, confirming no loss or double-counting.
- Severity domain validation: confirms only expected STATS19 severity codes 
  (1, 2, 3) are present; any “Unexpected” values indicate upstream anomalies in the data.
*/

-- Check Primary key uniqueness (should return 0 rows)
SELECT
  collision_index,
  vehicle_reference,
  COUNT(*) AS n
FROM mart.vehicle_level_severity_2015_2024
GROUP BY collision_index, vehicle_reference
HAVING COUNT(*) > 1;

-- Check Mart row count equals distinct collision/vehicle combinations from Staging (should be equal)
SELECT
  (SELECT COUNT(*)
   FROM mart.vehicle_level_severity_2015_2024) AS mart_rows,

  (SELECT COUNT(*)
   FROM (
     SELECT DISTINCT collision_index, vehicle_reference
     FROM stg.casualties_2015_2024
   ) d) AS distinct_vehicle_in_casualties;

SELECT
  mart_rows,
  distinct_vehicle_in_casualties,
  (mart_rows = distinct_vehicle_in_casualties) AS counts_match
FROM (
  SELECT
    (SELECT COUNT(*) FROM mart.vehicle_level_severity_2015_2024) AS mart_rows,
    (SELECT COUNT(*) FROM (SELECT DISTINCT collision_index, vehicle_reference
                           FROM stg.casualties_2015_2024) d) AS distinct_vehicle_in_casualties
) x;

-- Check weighted severity score integrity across mart rows (should return value of 0)
SELECT COUNT(*) AS mismatched_rows
FROM mart.vehicle_level_severity_2015_2024
WHERE weighted_severity_score <>
      (slight_count * 1 + serious_count * 15 + fatal_count * 60);

-- Check mart casualties across severities matches casualty count in Staging
SELECT
  (SELECT COUNT(*) FROM stg.casualties_2015_2024) AS stg_casualty_rows,

  (SELECT
     SUM(slight_count + serious_count + fatal_count)
   FROM mart.vehicle_level_severity_2015_2024) AS summed_mart_casualty_counts;

-- Check only fatal, serious and slight casualties are represented in the severity codes
SELECT
  CASE casualty_severity
  WHEN 1 THEN 'Fatal'
  WHEN 2 THEN 'Serious'
  WHEN 3 THEN 'Slight'
  ELSE 'Unexpected'
  END AS severity,
  COUNT(*) AS n
FROM stg.casualties_2015_2024
GROUP BY severity
ORDER BY severity;