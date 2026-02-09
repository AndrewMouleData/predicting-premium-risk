/*
03_create_raw_vehicles_table.sql

This script creates the raw.vehicles table inside the predicting_premium_risk.raw schema. All columns are accounted for with exact matching to the source data/raw/collisions_master.csv.

Design choices (raw layer):
- Column names are pasted to match the CSV header exactly
- All columns are type TEXT to accomodate unexpected values
- No constraints are enforced at this stage

Typing, cleaning, and time scoping (2015–2024) will happen in the stg layer.
*/

DROP TABLE IF EXISTS raw.vehicles;

CREATE TABLE raw.vehicles (
collision_index TEXT,
collision_year TEXT,
collision_ref_no TEXT,
vehicle_reference TEXT,
vehicle_type TEXT,
towing_and_articulation TEXT,
vehicle_manoeuvre_historic TEXT,
vehicle_manoeuvre TEXT,
vehicle_direction_from TEXT,
vehicle_direction_to TEXT,
vehicle_location_restricted_lane_historic TEXT,
vehicle_location_restricted_lane TEXT,
junction_location TEXT,
skidding_and_overturning TEXT,
hit_object_in_carriageway TEXT,
vehicle_leaving_carriageway TEXT,
hit_object_off_carriageway TEXT,
first_point_of_impact TEXT,
vehicle_left_hand_drive TEXT,
journey_purpose_of_driver_historic TEXT,
journey_purpose_of_driver TEXT,
sex_of_driver TEXT,
age_of_driver TEXT,
age_band_of_driver TEXT,
engine_capacity_cc TEXT,
propulsion_code TEXT,
age_of_vehicle TEXT,
generic_make_model TEXT,
driver_imd_decile TEXT,
lsoa_of_driver TEXT,
escooter_flag TEXT,
driver_distance_banding TEXT
);
