/*
05_create_raw_casualties_table.sql

This script creates the raw.casualties table inside the predicting_premium_risk.raw schema. All columns are accounted for with exact matching to the source data/raw/casualties_master.csv.

Design choices (raw layer):
- Column names are pasted to match the CSV header exactly
- All columns are type TEXT to accomodate unexpected values
- No constraints are enforced at this stage

Typing, cleaning, and time scoping (2015–2024) will happen in the stg layer.
*/

DROP TABLE IF EXISTS raw.casualties;

CREATE TABLE raw.casualties (
    collision_index TEXT,
    collision_year TEXT,
    collision_ref_no TEXT,
    vehicle_reference TEXT,
    casualty_reference TEXT,
    casualty_class TEXT,
    sex_of_casualty TEXT,
    age_of_casualty TEXT,
    age_band_of_casualty TEXT,
    casualty_severity TEXT,
    pedestrian_location TEXT,
    pedestrian_movement TEXT,
    car_passenger TEXT,
    bus_or_coach_passenger TEXT,
    pedestrian_road_maintenance_worker TEXT,
    casualty_type TEXT,
    casualty_imd_decile TEXT,
    lsoa_of_casualty TEXT,
    enhanced_casualty_severity TEXT,
    casualty_injury_based TEXT,
    casualty_adjusted_severity_serious TEXT,
    casualty_adjusted_severity_slight TEXT,
    casualty_distance_banding TEXT
);