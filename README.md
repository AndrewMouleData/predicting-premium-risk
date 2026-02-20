
# Predicting Premium Risk: UK Road Safety Analytics

An end-to-end analytics project using UK STATS19 road safety data to
assess third-party motor insurance risk through a frequency–severity
proxy, supporting premium pricing decisions.

This project explores how UK road collision data can be used to assess
motor insurance risk at the point of quote. Using the UK government’s
STATS19 collision, vehicle, and casualty datasets, it builds a
frequency–severity risk proxy to profile broad vehicle characteristics
and their relative risk to an insurer.

## Business Task

How can UK road safety data be used to estimate the relative risk
profile of different vehicle characteristics in order to support
third-party motor insurance premium pricing decisions?

## Context and Scope

The analysis is explicitly framed around third-party motor insurance,
which exists to provide financial cover for people injured as a result
of an insured driver’s actions. Within this context, injury severity
represents the primary driver of financial exposure and is therefore
treated as a proxy for relative third-party liability risk.

To maintain a clear purpose and disciplined scope, the project examines
injury severity only in relation to broad, vehicle-intrinsic
characteristics, including vehicle type, engine capacity, propulsion
type, and vehicle age. More granular factors, such as individual vehicle
models or driver demographics, are deliberately excluded, as modelling
these responsibly would require additional exposure, behavioural, and
claims data beyond what STATS19 can provide.

The project is designed as an end-to-end analytics exercise,
demonstrating large-scale data ingestion, SQL-based transformation,
statistical analysis in R, and the communication of business-relevant
insights in a way that mirrors real-world insurance pricing and
underwriting workflows.

### Not in Scope

- Exposure-adjusted rates (for example per vehicle-mile or per
  registered vehicle)
- Claim cost estimation or reserving
- Causal inference (such as driver age, vehicle brand, or similar
  coincidental factors)
- Driver behaviour, demographics, or fault attribution beyond what
  STATS19 can defensibly support

## Project Structure

- **sql/**  
  SQL scripts for data ingestion, staging, and transformation of raw
  STATS19 data.

- **r/**  
  R scripts for exploratory analysis, feature aggregation, and risk
  proxy construction.

- **data/**

  - **raw/**: Renamed, but otherwise unmodified STATS19 CSV files
    (gitignored due to size).  
  - **sample/**: Small representative samples used to demonstrate
    reproducible transformations.

- **outputs/**  
  Generated tables, figures, and model outputs produced during analysis
  (gitignored - final figures/tables are promoted to the README or docs
  when ready).

- **docs/**  
  Supporting documentation covering methodology, assumptions and
  decision rationale.

## Data Architecture

The project follows a layered relational structure:

1.  **Raw** (`raw` schema) Exact mirror of the official STATS19 CSV
    files. All columns stored as TEXT. No filtering or transformation
    applied.

2.  **Staging** (`stg` schema) Applies the analytical time window
    (2015–2024), performs explicit type casting, normalises missing
    values, and enforces relational grain via primary and foreign keys.
    No aggregation is introduced at this stage. A single source-level
    anomaly in casualty numbering is acknowledged and handled
    structurally without dropping records.

3.  **Mart** (`mart` schema) Analysis-ready tables used to construct the
    frequency × severity risk proxy, with downstream analysis performed
    in R.

## Requirements

This project is implemented using a PostgreSQL and R-based analytics
stack. It assumes basic command-line familiarity for raw data ingestion,
where the PostgreSQL client (`psql`) is used to load local CSV files via
client-side operations that sit outside the PostgreSQL database server.

### Database

- **PostgreSQL** - *The relational database*
- **psql** - *psql – PostgreSQL command-line client used for client-side
  raw CSV ingestion*

### R Environment

- **R (v4.4.3 +)** - *Recommended with RStudio IDE (optional)*

**Required R Packages**

*Note: you may want to install these by running following script:*

`install.packages(c("tidyverse", "DBI", "RPostgres", "knitr", "rmarkdown"))`

- tidyverse
- DBI
- RPostgres
- knitr
- rmarkdown

## Reproducing the Analysis

To reproduce the analysis locally, follow the steps below.

1.  Download the UK STATS19 master CSV files (Collisions, Vehicles,
    Casualties) in full from the official GOV.UK source. These files
    contain all available historical data (1979–present).

2.  Rename the files to the following standardised names:

    - collisions_master.csv
    - vehicles_master.csv
    - casualties_master.csv

3.  Place the raw CSV files in the local `data/raw/` directory.  
    This directory is intentionally gitignored and raw data files are
    never committed to the repository.

4.  Run the SQL scripts in numeric order:

- sql/00_setup/
- sql/01_raw/
- sql/02_stg/

*Raw ingestion scripts must be executed via psql in a shell Staging,
constraint and mart scripts execute server-side.*

5.  Run the R scripts in the `r/` directory to generate validation
    checks, summary tables, and figures used in the analysis and
    documentation.

## Running SQL Raw Ingestion Scripts

Raw data ingestion scripts use the PostgreSQL psql command-line client
and the client-side command to ingest local CSV files. This is a
necessity caused by PostgreSQL databases not having access to the
client’s local file system where the raw source csv data resides. Using
`psql` inside a shell application bridges this gap by streaming data
*over* the connection, a capability that scripts executed wholly within
the database server lack due to security and permission constraints.

Execute the raw ingestion scripts (*02, 04 and 06*) inside`sql/01_raw/`
from a shell environment (e.g. cmd, PowerShell, Bash) with the working
directory set to the project root so relative file paths
(e.g. `data/raw/`) resolve correctly.

*Example command order:*

1.  `cd Predicting-Premium-Risk` - *Sets the shell working directory to
    the root of the repository so relative file paths resolve
    correctly.*

2.  `psql -d predicting_premium_risk -f sql/01_raw/02_ingest_raw_collisions.sql` -
    *Launches the PostgreSQL command-line client and connects to the
    `predicting_premium_risk` database. Then, executes the specified SQL
    script file, running its contents sequentially against the connected
    database.*
