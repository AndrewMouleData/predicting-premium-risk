/*
02_stg_vehicles_2015_2024.sql

Staging layer for vehicle-level records within the predicting_premium_risk database.

Purpose:
- Time-scope data (2015-2024) via semi-join with stg.collisions.
- Standardise 'raw' TEXT type strings into deliberate typed formats.
- Maintain lineage by preserving original categorical codes and sentinel values (e.g., -1).
- Remove ONLY redundant identifiers where: 1. A more authoritative alternative exists 2. Fields that have been replaced by a current equivalent.

Design Choices:
- Filter logic: Vehicles are scoped by collision_index as the source lacks native date fields.
- Type casting: Strings are trimmed and 'NA' literals converted to NULL prior to casting to prevent execution failure.
- Business Logic: None. Modelling and semantic recoding are deferred to downstream layers.
- Fractional Values: Engine/severity fields cast to NUMERIC where precision is required.

Fields Dropped (Redundant/Obsolete):
- collision_ref_no, vehicle_manoeuvre_historic, vehicle_location_restricted_lane_historic, journey_purpose_of_driver_historic
*/

DROP TABLE IF EXISTS stg.vehicles_2015_2024;

CREATE TABLE stg.vehicles_2015_2024 AS
SELECT
  collision_index,
  NULLIF(NULLIF(TRIM(collision_year), ''), 'NA')::int AS collision_year,
  NULLIF(NULLIF(TRIM(vehicle_reference), ''), 'NA')::int AS vehicle_reference,
  NULLIF(NULLIF(TRIM(vehicle_type), ''), 'NA')::int AS vehicle_type,
  NULLIF(NULLIF(TRIM(towing_and_articulation), ''), 'NA')::int AS towing_and_articulation,
  NULLIF(NULLIF(TRIM(vehicle_manoeuvre), ''), 'NA')::int AS vehicle_manoeuvre,
  NULLIF(NULLIF(TRIM(vehicle_direction_from), ''), 'NA')::int AS vehicle_direction_from,
  NULLIF(NULLIF(TRIM(vehicle_direction_to), ''), 'NA')::int AS vehicle_direction_to,
  NULLIF(NULLIF(TRIM(vehicle_location_restricted_lane), ''), 'NA')::int AS vehicle_location_restricted_lane,
  NULLIF(NULLIF(TRIM(junction_location), ''), 'NA')::int AS junction_location,
  NULLIF(NULLIF(TRIM(skidding_and_overturning), ''), 'NA')::int AS skidding_and_overturning,
  NULLIF(NULLIF(TRIM(hit_object_in_carriageway), ''), 'NA')::int AS hit_object_in_carriageway,
  NULLIF(NULLIF(TRIM(vehicle_leaving_carriageway), ''), 'NA')::int AS vehicle_leaving_carriageway,
  NULLIF(NULLIF(TRIM(hit_object_off_carriageway), ''), 'NA')::int AS hit_object_off_carriageway,
  NULLIF(NULLIF(TRIM(first_point_of_impact), ''), 'NA')::int AS first_point_of_impact,
  NULLIF(NULLIF(TRIM(vehicle_left_hand_drive), ''), 'NA')::int AS vehicle_left_hand_drive,
  NULLIF(NULLIF(TRIM(journey_purpose_of_driver), ''), 'NA')::int AS journey_purpose_of_driver,
  NULLIF(NULLIF(TRIM(sex_of_driver), ''), 'NA')::int AS sex_of_driver,
  NULLIF(NULLIF(TRIM(age_of_driver), ''), 'NA')::int AS age_of_driver,
  NULLIF(NULLIF(TRIM(age_band_of_driver), ''), 'NA')::int AS age_band_of_driver,
  NULLIF(NULLIF(TRIM(engine_capacity_cc), ''), 'NA')::int AS engine_capacity_cc,
  NULLIF(NULLIF(TRIM(propulsion_code), ''), 'NA')::int AS propulsion_code,
  NULLIF(NULLIF(TRIM(age_of_vehicle), ''), 'NA')::int AS age_of_vehicle,
  NULLIF(NULLIF(TRIM(generic_make_model), ''), 'NA') AS generic_make_model,
  NULLIF(NULLIF(TRIM(driver_imd_decile), ''), 'NA')::int AS driver_imd_decile,
  NULLIF(NULLIF(TRIM(lsoa_of_driver), ''), 'NA') AS lsoa_of_driver,
  NULLIF(NULLIF(TRIM(escooter_flag), ''), 'NA')::int AS escooter_flag,
  NULLIF(NULLIF(TRIM(driver_distance_banding), ''), 'NA')::int AS driver_distance_banding
FROM raw.vehicles
WHERE
  collision_index IN (
    SELECT collision_index
    FROM stg.collisions_2015_2024
  );