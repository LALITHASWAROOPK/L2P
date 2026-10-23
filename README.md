# Hackathon pre-work baseline — 2026-10-23

This folder is preparation, not claimed as functionality built during the hackathon.
No Agilent datasets, definitions, agent instructions, skills, logs or credentials are included.

## Source and license
Microsoft sql-server-samples, MIT License, pinned commit
`dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a`.
Original files are preserved under `source/`; source/manifest.json records URLs and hashes.
Retain source/license.txt with any redistribution. Public repository:
https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/wide-world-importers

## Data origin and limitations
The eight table schemas are a **simplified adaptation** of Wide World Importers.
All rows are independently generated synthetic data, NOT an export of Microsoft's database.
The original SQL Server code is reference material only. It is not executed in Snowflake
and may refer to omitted tables and columns. Temporal tables, audit columns, operational
procedures, package types and SQL Server indexes are omitted. No claim of full WWI parity.
The invoice formula preserves the original meaning: ExtendedPrice includes tax;
subtract TaxAmount to obtain invoice sales excluding tax. Dates cover Jan–early Mar 2026.
No currency conversion, returns, discount or cancellation model is implemented.
The stock-group bridge is many-to-many; aggregating money across it can double count.

## Reproduce and validate
Run `python prepare.py` (standard library only). Fixed seed 231026 produces CSVs,
01_load.sql and validation.json, including SHA256 hashes and relational checks.
The current dataset has 818 rows across eight tables. Expected invoice totals:
sales excluding tax 53589.47; tax 5359.07; including tax 58948.54.
Local assertions check primary-key uniqueness, row shapes, all modeled foreign keys
and invoice arithmetic. These are dataset integrity checks, not competition evaluations.

## Snowflake setup
Only execute against the supplied SFSEHOL hackathon account.
01_load.sql creates a NEW HACKATHON_D2K_PREWORK database and RAW schema.
It intentionally does not use OR REPLACE/IF NOT EXISTS: do not rerun after a partial
load without inspecting which statements succeeded. No Stoweaway objects are touched.
02_starter.sql creates a simple invoice semantic view and query-only agent.
No new role grants, external integrations, schedules or autonomous write tools.
Deployment and response-test status is recorded in STATUS.md; file existence does not
mean that the SQL has been deployed or tested.

## Reserved for the event
New report/code discovery, metadata reconciliation, lineage traversal, business
clarification, product generation, independent evaluation and approval-controlled
publishing. No custom report fixtures or seeded metadata defects have been built here.
Confirm organizer rules before preparing further custom fixtures. Keep a starting
commit and disclose this baseline and public sources in the final submission.

## Account lifetime
The supplied guide says the account is removed 2026-10-28 05:00 UTC
(2026-10-27 22:00 America/Los_Angeles). Keep all source outside that account.
