/*
Project Title: Predicting Premium Risk - UK STATS19 Analytics
Database Name: predicting_premium_risk

Purpose:
This script creates the core schemas used in the project. It assumes the database already exists locally.
A medallion-style data architecture informs the schema structure, progressing from raw source data to staged data to analysis-ready tables.
Schemas separate transformation stages and make data lineage explicit, which supports debugging and reproducibility.

Schemas:
- raw  : Faithful, unmodified representations of the three source CSVs in /data/raw:
         collisions_master.csv, vehicles_master.csv, casualties_master.csv.
- stg  : Tables that are cleaned, explicitly type-cast, and scoped to the project’s analytical time window (intermediate layer).
- mart : Analysis-ready tables aligned to the motor insurance risk business task, designed for downstream analysis in R.
*/

CREATE SCHEMA IF NOT EXISTS raw;  -- Raw source layer
CREATE SCHEMA IF NOT EXISTS stg;  -- Staging layer
CREATE SCHEMA IF NOT EXISTS mart; -- Analysis-ready data mart
