/*
01_create_raw_collisions_table.sql

This script creates the raw.collisions table inside the predicting_premium_risk.raw schema. All columns are accounted for with exact matching to the source data/raw/collisions_master.csv.

Design choices (raw layer):
- Column names are pasted to match the CSV header exactly
- All columns are type TEXT to accomodate unexpected values
- No constraints are enforced at this stage

Typing, cleaning, and time scoping (2015–2024) will happen in the stg layer.
*/

DROP TABLE IF EXISTS raw.collisions;

CREATE TABLE raw.collisions (
  collision_index TEXT,
  collision_year TEXT,
  collision_ref_no TEXT,
  location_easting_osgr TEXT,
  location_northing_osgr TEXT,
  longitude TEXT,
  latitude TEXT,
  police_force TEXT,
  collision_severity TEXT,
  number_of_vehicles TEXT,
  number_of_casualties TEXT,
  date TEXT,
  day_of_week TEXT,
  time TEXT,
  local_authority_district TEXT,
  local_authority_ons_district TEXT,
  local_authority_highway TEXT,
  local_authority_highway_current TEXT,
  first_road_class TEXT,
  first_road_number TEXT,
  road_type TEXT,
  speed_limit TEXT,
  junction_detail_historic TEXT,
  junction_detail TEXT,
  junction_control TEXT,
  second_road_class TEXT,
  second_road_number TEXT,
  pedestrian_crossing_human_control_historic TEXT,
  pedestrian_crossing_physical_facilities_historic TEXT,
  pedestrian_crossing TEXT,
  light_conditions TEXT,
  weather_conditions TEXT,
  road_surface_conditions TEXT,
  special_conditions_at_site TEXT,
  carriageway_hazards_historic TEXT,
  carriageway_hazards TEXT,
  urban_or_rural_area TEXT,
  did_police_officer_attend_scene_of_accident TEXT,
  trunk_road_flag TEXT,
  lsoa_of_accident_location TEXT,
  enhanced_severity_collision TEXT,
  collision_injury_based TEXT,
  collision_adjusted_severity_serious TEXT,
  collision_adjusted_severity_slight TEXT
);