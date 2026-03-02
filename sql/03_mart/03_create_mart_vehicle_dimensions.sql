/*
03_create_mart_vehicle_dimensions.sql

Dimension prep layer for the predicting_premium_risk mart schema.

Purpose:
- Enrich mart.all_vehicles_with_severity_2015_2024 with analysis-ready dimensions.
- Decode coded categorical fields (vehicle_type, propulsion_code) into 
  human-readable labels.
- Convert continuous numeric variables (engine_capacity_cc, age_of_vehicle) into 
  stable bands for downstream GROUP BY.

Design choices:
- Separation of semantics & structure:
  1. Categorical decoding for readable meaning is performed in the CTE.
  2. Banding of continuous variables explicitly shapes future grouping structure 
     and is applied in the outer SELECT.
- Categorical preservation: original coded fields are retained alongside decoded 
  labels and derived bands at this stage to preserve traceability and allow 
  future refinement before final aggregation.
- Engine capacity banding handling: bands are designed in accordance with dataset 
  distribution. Certain propulsion types (electric, fuel-cell, etc.) are handled 
  with N/A, while NULL and negative coded values are treated as Unknown.
- Explicit unknown handling: NULL values and undefined codes (e.g., -1) are grouped 
  into labelled categories so they remain visible and auditable in downstream analysis.
*/

DROP TABLE IF EXISTS mart.vehicle_dimensions_2015_2024;

CREATE TABLE mart.vehicle_dimensions_2015_2024 AS
WITH decoded AS (
    SELECT
        vws.*,
        CASE vws.propulsion_code
            WHEN 1  THEN 'Petrol'
            WHEN 2  THEN 'Heavy oil'
            WHEN 3  THEN 'Electric'
            WHEN 4  THEN 'Steam'
            WHEN 5  THEN 'Gas'
            WHEN 6  THEN 'Petrol/Gas (LPG)'
            WHEN 7  THEN 'Gas/Bi-fuel'
            WHEN 8  THEN 'Hybrid electric'
            WHEN 9  THEN 'Gas Diesel'
            WHEN 10 THEN 'New fuel technology'
            WHEN 11 THEN 'Fuel cells'
            WHEN 12 THEN 'Electric diesel'
            WHEN -1 THEN 'Undefined'
            ELSE         'Unknown'
        END AS propulsion_label,
        CASE vws.vehicle_type
            WHEN 1  THEN 'Pedal cycle'
            WHEN 2  THEN 'Motorcycle 50cc and under'
            WHEN 3  THEN 'Motorcycle 125cc and under'
            WHEN 4  THEN 'Motorcycle over 125cc and up to 500cc'
            WHEN 5  THEN 'Motorcycle over 500cc'
            WHEN 8  THEN 'Taxi/Private hire car'
            WHEN 9  THEN 'Car'
            WHEN 10 THEN 'Minibus (8 - 16 passenger seats)'
            WHEN 11 THEN 'Bus or coach (17 or more pass seats)'
            WHEN 16 THEN 'Ridden horse'
            WHEN 17 THEN 'Agricultural vehicle'
            WHEN 18 THEN 'Tram'
            WHEN 19 THEN 'Van / Goods 3.5 tonnes mgw or under'
            WHEN 20 THEN 'Goods over 3.5t. and under 7.5t'
            WHEN 21 THEN 'Goods 7.5 tonnes mgw and over'
            WHEN 22 THEN 'Mobility scooter'
            WHEN 23 THEN 'Electric motorcycle'
            WHEN 90 THEN 'Other vehicle'
            WHEN 97 THEN 'Motorcycle - unknown cc'
            WHEN 98 THEN 'Goods vehicle - unknown weight'
            WHEN 99 THEN 'Unknown vehicle type (self rep only)'
            ELSE         'Unknown'
        END AS vehicle_type_label
    FROM mart.all_vehicles_with_severity_2015_2024 AS vws
)

SELECT
    collision_index,
    vehicle_reference,
    vehicle_type,
    vehicle_type_label,
    propulsion_code,
    propulsion_label,
    engine_capacity_cc,
    CASE
      WHEN propulsion_code IN (3, 8, 11, 12)        THEN 'N/A'
      WHEN engine_capacity_cc IS NULL               THEN 'Unknown'
      WHEN engine_capacity_cc < 0                   THEN 'Unknown'
      WHEN engine_capacity_cc BETWEEN 0 AND 499     THEN '0–499 cc'
      WHEN engine_capacity_cc BETWEEN 500 AND 999   THEN '500–999 cc'
      WHEN engine_capacity_cc BETWEEN 1000 AND 1499 THEN '1000–1499 cc'
      WHEN engine_capacity_cc BETWEEN 1500 AND 1999 THEN '1500–1999 cc'
      WHEN engine_capacity_cc BETWEEN 2000 AND 2999 THEN '2000–2999 cc'
      WHEN engine_capacity_cc >= 3000               THEN '3000+ cc'
      ELSE                                               'Unknown'
    END AS engine_capacity_band,
    age_of_vehicle,
    CASE
      WHEN age_of_vehicle IS NULL              THEN 'Unknown'
      WHEN age_of_vehicle BETWEEN 0 AND 2      THEN '0–2 years'
      WHEN age_of_vehicle BETWEEN 3 AND 5      THEN '3–5 years'
      WHEN age_of_vehicle BETWEEN 6 AND 10     THEN '6–10 years'
      WHEN age_of_vehicle BETWEEN 11 AND 15    THEN '11–15 years'
      WHEN age_of_vehicle >= 16                THEN '16+ years'
      ELSE                                          'Unknown'
    END AS vehicle_age_band,
    slight_count,
    serious_count,
    fatal_count,
    weighted_severity_score
FROM decoded;

ALTER TABLE mart.vehicle_dimensions_2015_2024
    ADD CONSTRAINT pk_vehicle_dimensions_2015_2024
    PRIMARY KEY (collision_index, vehicle_reference);