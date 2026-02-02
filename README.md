
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

### Not in scope

- Exposure-adjusted rates (for example per vehicle-mile or per
  registered vehicle)
- Claim cost estimation or reserving
- Causal inference (such as driver age, vehicle brand, or similar
  coincidental factors)
- Driver behaviour, demographics, or fault attribution beyond what
  STATS19 supports

## Project Structure

- **sql/**  
  SQL scripts for data ingestion, staging, and transformation of raw
  STATS19 data.

- **r/**  
  R scripts for exploratory analysis, feature aggregation, and risk
  proxy construction.

- **data/**

  - **raw/**: Unmodified STATS19 CSV files (gitignored due to size).  
  - **sample/**: Small representative samples used to demonstrate
    reproducible transformations.

- **outputs/**  
  Generated tables, figures, and model outputs produced during analysis
  (gitignored - final figures/tables are promoted to the README or docs
  when ready).

- **docs/**  
  Supporting documentation covering methodology, assumptions and
  decision rationale.

## Reproducing the analysis

1.  Download the required STATS19 files (collisions, vehicles,
    casualties) for the project time window.
2.  Place the raw CSVs in `data/raw/` (this folder is gitignored by
    design).
3.  Run the SQL scripts in `sql/` in numeric order to create staged and
    aggregated tables.
4.  Run the R scripts in `r/` to generate summary tables and figures.
