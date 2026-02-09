/*
02_ingest_raw_collisions.sql

Purpose:
Client-side ingestion of all observations from data/raw/collisions_master.csv into the raw.collisions table.

Execution guide (IMPORTANT):
- This script must be executed via the PostgreSQL command-line client (psql).
- It cannot be run directly in GUI query tools (e.g. pgAdmin), because \copy is a psql meta-command (client-side), not standard SQL.
- Run from any shell application you prefer (cmd, PowerShell, Bash, etc.) with the working directory set to the project root so relative file paths resolve correctly.

Example CLI Execution:
> cd Predicting-Premium-Risk
> psql -d predicting_premium_risk -f sql/01_raw/02_ingest_raw_collisions.sql

Design choices (raw layer):
- Use of client-side \copy avoids PostgreSQL server file permission constraints on local installs.
- No filtering, transformation, or type casting is applied at this stage.
*/

\copy raw.collisions FROM 'data/raw/collisions_master.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL '', QUOTE '"');
