/*
04_stg_indexes_and_constraints.sql

Structural integrity and performance layer for the predicting_premium_risk staging schema.

Purpose:
- Enforce Primary Keys to guarantee relational uniqueness and table grain.
- Implement Foreign Keys to ensure strict collision membership across entities.
- Add additional indexing to support future temporal querying on accident_date.

Design choices:
- Constraints added after table creation: keys applied post-staging creation for loading speed and clear workflow.
- Grain definition: formalises collision-level, vehicle-level, and casualty-level hierarchy with simple and composite primary keys.
- Performance: indexes target primary join keys (via PKs) and accident_date for common filtering and validation.
- Safety net: BEGIN...COMMIT wrap allows ROLLBACK to ensure non-partial script execution and key creation.

Note:
- STATS19 guidance specifies casualty_reference should be unique within a single collision_index, but observed data contains rare violations.
- Therefore, while the expected grain is (collision_index, casualty_reference), the staging PK reflects the extract grain: (collision_index, vehicle_reference, casualty_reference).
- Mart logic will aggregate severity at vehicle level in a way that avoids double counting.
*/

BEGIN;

ALTER TABLE stg.collisions_2015_2024
  ADD CONSTRAINT pk_stg_collisions_2015_2024
  PRIMARY KEY (collision_index);

ALTER TABLE stg.vehicles_2015_2024
  ADD CONSTRAINT pk_stg_vehicles_2015_2024
  PRIMARY KEY (collision_index, vehicle_reference);

ALTER TABLE stg.casualties_2015_2024
  ADD CONSTRAINT pk_stg_casualties_2015_2024
  PRIMARY KEY (collision_index, vehicle_reference, casualty_reference);

ALTER TABLE stg.vehicles_2015_2024
  ADD CONSTRAINT fk_stg_vehicles_to_collisions_2015_2024
  FOREIGN KEY (collision_index)
  REFERENCES stg.collisions_2015_2024 (collision_index);

ALTER TABLE stg.casualties_2015_2024
  ADD CONSTRAINT fk_stg_casualties_to_collisions_2015_2024
  FOREIGN KEY (collision_index)
  REFERENCES stg.collisions_2015_2024 (collision_index);

CREATE INDEX IF NOT EXISTS ix_stg_collisions_2015_2024_accident_date
  ON stg.collisions_2015_2024 (accident_date);

COMMIT;