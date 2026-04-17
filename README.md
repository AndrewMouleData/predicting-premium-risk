
# Predicting Premium Risk: UK Road Safety Analytics

This project demonstrates an end-to-end data analytics pipeline using UK
STATS19 road safety data. It develops a frequency × severity proxy for
the purpose of assessing relative third-party motor insurance risk, from
the perspective of an insurer seeking to understand broad risk profiles
in support of premium pricing decisions.

The result is an exploration of how publicly available UK road collision
data can be used to generate business insights that strengthen
data-driven decision-making in motor insurance risk. From sourcing and
ingestion through to transformation, validation, exploratory analysis,
analytical scoping, and visual communication, this project demonstrates
a professional-grade application of data analytics to a commercially
relevant risk problem.

**Defining heuristic and proxy:** In this project, **heuristic** refers
to the simplified, rule-based methodology used to approximate risk where
richer actuarial claims, exposure, and pricing data are unavailable. In
practice, that includes assigning fixed weights to casualty severity
levels as a reasonable stand-in for likely third-party payout severity,
on the assumption that more severe injuries are generally associated
with greater insurer liability. **Proxy** refers to the resulting
frequency × severity measure, used as a practical stand-in for fuller
actuarial assessment of relative third-party motor insurance risk.

### Business Task

How can UK road safety data be used to estimate the relative risk
profile of different vehicle characteristics in order to support
third-party motor insurance premium pricing decisions?

### Context and Scope

The analysis is explicitly framed around third-party motor insurance,
which exists to provide financial cover for people injured as a result
of an insured driver’s actions. Within that context, injury severity and
collision frequency are treated as the key drivers of relative financial
exposure, which is why their combination is used here as a proxy for
third-party liability risk.

To maintain a clear purpose and disciplined scope, the project examines
collisions only in relation to broad, vehicle-intrinsic characteristics:
including vehicle type, engine capacity, propulsion type, and vehicle
age. More granular factors, such as individual vehicle models or driver
demographics, are deliberately excluded, as modelling these responsibly
would require additional exposure, behavioural, and claims data beyond
what STATS19 can provide.

### Not in Scope

- Exposure-adjusted rates (for example per vehicle-mile or per
  registered vehicle)
- Claim or collision probability modelling
- Claim cost estimation, reserving, or full premium modelling
- Causal inference across vehicle, driver, or environmental factors
- Driver behaviour, demographics, or fault attribution

### Project Structure

- **sql/**  
  SQL scripts for raw data ingestion, staging, mart construction, and
  core risk metric creation from STATS19 data.

- **r/**  
  R scripts for mart extraction, transfer validation, exploratory
  analysis, analytical scoping, visualisation, and interpretation.

- **data/**

  - **raw/**: Renamed, but otherwise unmodified STATS19 CSV files
    (gitignored due to size).  
  - **sample/**: Small representative samples used for demonstration and
    reproducibility support.

- **outputs/**  
  Generated figures, tables, and other derived outputs produced during
  analysis (gitignored - final visuals or summaries are promoted to the
  README or docs when ready).

- **docs/**  
  Supporting documentation covering methodology, assumptions, and
  decision rationale.

### Data Architecture

The project follows a layered relational structure:

1.  **Raw** (`raw` schema)  
    Exact mirror of the official STATS19 CSV files. All columns are
    stored as TEXT. No filtering or transformation is applied.

2.  **Staging** (`stg` schema)  
    Applies the analytical time window (2015–2024), performs explicit
    type casting, normalises missing values, and enforces relational
    grain via primary and foreign keys. No aggregation is introduced at
    this stage. A single source-level anomaly in casualty numbering is
    acknowledged and handled structurally without dropping records.

3.  **Mart** (`mart` schema)  
    Constructs analysis-ready business-grain tables used to implement
    the frequency × severity risk proxy.

This layer:

- Aggregates casualty-level records to vehicle involvement level
- Applies heuristic weighting across slight, serious, and fatal casualty
  severity categories
- Reintroduces the full collision-involved vehicle universe
- Decodes categorical variables and bands continuous variables for
  stable grouping
- Aggregates to a final risk profile grain defined by:
  `(vehicle_type, propulsion_code, engine_capacity_band, vehicle_age_band)`

*All core frequency and severity metrics are calculated in SQL.*  
*R is used for independent validation, exploratory analysis, scoping,
visualisation, and interpretation. It does not recalculate the core mart
metrics.*

### Analytical Framework

This project uses a frequency × severity framework to compare the
relative third-party injury risk associated with broad vehicle profiles.
The logic is intentionally simple. If a vehicle profile appears more
often in the collision dataset, it contributes more to the overall risk
landscape. If collisions involving that profile also tend to produce
more severe casualty outcomes, its relative risk increases further.

The framework therefore combines two distinct signals. The first is
frequency, which captures how large a profile’s presence is within the
collision-involved vehicle universe. The second is casualty severity,
which captures the average injury burden associated with each
collision-involved vehicle in that profile. Taken together, they provide
a practical basis for relative comparison across vehicle profiles
defined by broad, fixed vehicle characteristics.

A key advantage of this structure is that it preserves the distinction
between different kinds of high-risk profile. Some profiles may rank
highly because they appear frequently in the collision data. Others may
appear less often, but generate materially worse injury outcomes when
they do. Separating frequency from severity makes that difference
visible, which allows for greater clarity in the insights this analysis.

### Risk Metric Construction

The frequency × severity framework is implemented in the mart layer
through a set of deliberately ordered metric calculations.

A weighted severity measure is first constructed at the vehicle
involvement level. Casualty records are aggregated to one row per
`(collision_index, vehicle_reference)`, and injury severities are
converted into a weighted index using fixed constants:

- slight = 1
- serious = 15
- fatal = 60

This produces a `weighted_severity_score` for each collision-involved
vehicle.

Those vehicle-level rows are then aggregated to the project’s final
business grain:

`(vehicle_type, propulsion_code, engine_capacity_band, vehicle_age_band)`

At that profile level, the mart produces the project’s core metrics:

- `weighted_severity_total`: the summed vehicle-level severity score
  across all vehicles in the profile
- `avg_weighted_severity_per_vehicle`: the average weighted severity
  burden per collision-involved vehicle in the profile
- `frequency_share`: the profile’s share of all collision-involved
  vehicles in the dataset
- `risk_proxy_score`: the combined frequency × severity signal used for
  relative comparison
- `risk_rank`: a descending dense rank over `risk_proxy_score`

This structure preserves a clear distinction between vehicle-level
severity construction and profile-level risk comparison, while keeping
the final mart output directly interpretable for downstream validation,
analysis, and visualisation in R.

### Validation Approach

Before any exploratory analysis or visualisation takes place, the final
mart output is validated in R to confirm that it remains structurally
sound and mathematically consistent after SQL transformation and
transfer into the R environment.

This validation step checks that the core metric relationships still
hold after extraction from SQL, rather than assuming the mart output has
transferred perfectly into R. In practice, that includes confirming:

- `risk_proxy_score` matches
  `frequency_share × avg_weighted_severity_per_vehicle`
- `avg_weighted_severity_per_vehicle` matches
  `weighted_severity_total / vehicle_count`
- the final business-grain rows remain unique
- key metric and dimension fields contain no unexpected missing values
- `frequency_share` sums to 1 across the full mart output
- `risk_rank` is populated consistently
- column types and overall dataset dimensions are as expected

Where calculated values are compared, checks are applied with a small
floating point tolerance to account for minor machine-precision
differences between SQL and R. This keeps the validation strict without
treating negligible numerical noise as a data quality issue.

By separating metric construction in SQL from validation in R, the
project introduces an independent cross-layer check before
interpretation begins. That makes the downstream exploratory analysis,
scoping decisions, and visual outputs easier to trust, because they are
working from an output that has already been tested for internal
consistency.

### Scoping Decisions

Exploratory analysis was first carried out on the full unscoped mart
output before any analytical filtering was applied. This allowed profile
stability, coverage, and interpretability to be assessed across the
complete collision-involved vehicle universe.

The scoping rules introduced later in the pipeline were informed by
those observations, chiefly to address very low-count profiles,
out-of-scope vehicle types, and weakly defined groups that could not
support meaningful reporting. To preserve the integrity of the core
metrics, all scoping takes place after metric construction rather than
before it.

### Visual Outputs

The final visualisation stage translates the scoped analytical output
into a small set of README-facing figures designed to support
interpretation rather than extend the modelling logic. The charts use
consistent mappings between variables and visual encodings to support
direct comparison across views.

These figures focus on the reporting subset and are used to show the
project from several complementary angles:

- ranked high-risk profiles
- the relationship between frequency and severity across profiles
- the overall distribution of risk proxy scores
- aggregate risk contribution by vehicle type
- the distribution of profile vehicle counts
- coverage retained across the full, scoped, and reporting datasets

Together, they provide a concise view of both the analytical results and
the trade-offs introduced by scoping. Interpretive charts are built from
the reporting subset, while the coverage summary shows how much of the
full collision-involved vehicle universe remains represented after each
scoping stage.

### Requirements

This project is carried out using PostgreSQL and R within a simple
end-to-end analytics stack. It assumes basic command-line familiarity
for raw data ingestion, as the PostgreSQL client (`psql`) is used to
load local CSV files via client-side operations that sit outside the
database server.

### Database

- **PostgreSQL** - *Relational database management system (DBMS)*
- **psql** - *PostgreSQL command-line client used for client-side raw
  CSV ingestion*

### R Environment

- **R (v4.4.3+)** - *RStudio IDE is recommended, but optional*

**Required R Packages**

- tidyverse
- DBI
- RPostgres
- knitr
- rmarkdown

*If needed, the following command will install the packages above in
your local environment:*

`install.packages(c("tidyverse", "DBI", "RPostgres", "knitr", "rmarkdown"))`

### Reproducing the Analysis

To reproduce the analysis locally, follow the steps below.

1.  Download the UK STATS19 master CSV files (Collisions, Vehicles,
    Casualties) in full from the official GOV.UK source.  
    These files contain all available historical data (1979–present).

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
    - sql/03_mart/

    *Raw ingestion scripts must be executed via `psql` in a shell.
    Staging, constraint, and mart scripts run server-side.*

5.  Run the R scripts in the `r/` directory to generate validation
    checks, summary tables, and figures used in the analysis and
    documentation.

### Running SQL Raw Ingestion Scripts

Raw data ingestion scripts use the PostgreSQL `psql` command-line client
and the client-side `\copy` command to ingest local CSV files. This is
necessary because the database server cannot directly access the
client’s local file system where the raw source CSV files reside. Using
`psql` inside a shell application bridges this gap by streaming data
*over* the connection, a capability that scripts executed wholly within
the database server lack due to security and permission constraints.

Execute the raw ingestion scripts (02, 04 and 06) from a shell
environment with the working directory set to the project root, so
relative paths to files inside `sql/01_raw/` and `data/raw/` resolve
correctly.

*Example command order:*

1.  `cd Predicting-Premium-Risk` - *Sets the shell working directory to
    the root of the repository so relative file paths resolve
    correctly.*

2.  `psql -d predicting_premium_risk -f sql/01_raw/02_ingest_raw_collisions.sql` -
    *Launches the PostgreSQL command-line client, connects to the
    `predicting_premium_risk` database, and executes the specified SQL
    script sequentially against that connection.*
