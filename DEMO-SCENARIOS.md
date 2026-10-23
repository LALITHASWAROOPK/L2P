# Connected synthetic sales demo — prepared fixtures, not completed workflows

Fictional company: Northstar Supply. Existing WWI-adapted synthetic CSVs are reused.
All new metadata is original synthetic authoring. No company data/code is included.

## Status and honesty boundary

- HANA: two normalized XML model descriptions plus executable relational SQL equivalents.
  These are **not SAP-native .hdbcalculationview files** and have not been deployed to HANA.
- Qlik: a proposed load script plus normalized sheet/chart/measure metadata. No QVF
  was created, and the script has not been run in Qlik.
- Spotfire: source SQL plus normalized analysis/visual/calculated-column metadata.
  No DXP was created, and expressions have not been evaluated in Spotfire.
- SQLite validates both underlying relational SQL definitions against the synthetic CSVs.
  That proves fixture joins and arithmetic, not native platform compatibility.
- No full lineage engine, product writer or automated reconciliation was implemented.
- Scenario prompts and expected answers remain outside the agent search corpus.

## 1. Discover and understand reporting

Prompt: **Do we have customer sales reports in Qlik or Spotfire? What does sales mean in each?**

Expected behavior: find Qlik Sales Performance and Spotfire Customer Sales. Explain
that the first measures orders and the second invoices, both excluding tax. Identify
their specific chart expressions, aliases and underlying model definitions. Make clear
that these are synthetic metadata examples, not real deployed dashboards.

Artifacts: `fixtures/qlik/`, `fixtures/spotfire/`, `fixtures/hana/`.
Failure: claiming one report is absent based on top-ranked results; merging both
definitions into one generic revenue metric; inventing native runtime validation.

## 2. Explain conflicting totals

Prompt: **Why does Qlik Sales Performance show more sales than Spotfire Customer Sales?**

Expected behavior: inspect load scripts and model definitions before deciding why.
Qlik uses ordered value on order date; Spotfire uses invoiced sales on invoice date.
Both exclude tax. On the full dataset the difference is uninvoiced order value;
monthly differences also reflect invoice-date shifts. Do not call one report wrong.

Independent ground truth is in `evaluation/fixture-checks.json`, never in retrieval.
The current starter can retrieve definitions but does not yet have a connected orders
query model or a reconciliation tool. Numeric end-to-end proof is event work.

## 3. Build a reusable product

Prompt: **Build daily invoiced sales by customer and product, excluding tax, in Snowflake.**

Expected behavior: propose grain (invoice date, customer ID, stock item ID), source
mappings and SQL; distinguish proposal from execution. When the event workflow is
implemented, create only in an isolated draft schema and check uniqueness, source
coverage, null keys, and total reconciliation before calling it validated.

Reference output: `evaluation/expected_daily_customer_product.csv`. This is an
independent test oracle, not a delivered product or a searchable canned answer.
No calendar zero-fill, currency or allocation policy should be silently invented.

## 4. Optional follow-up: aggregation ambiguity

Prompt: **Now add stock group and show total sales across all groups.**

Expected behavior: inspect the product/group bridge. Some products have more than one
group. Explain that group totals overlap unless a primary-group or allocation rule
is chosen. Ask for that decision; do not silently duplicate sales or invent weights.

## 5. Optional change-impact question

Prompt: **If ExtendedPrice is replaced, which synthetic reports need review?**

Expected behavior: follow the invoice model's amount calculation into Spotfire's
SalesAmount and relevant prework SQL reports. Qlik's ordered value derives from
quantity and unit price, not ExtendedPrice. Limit completeness claims to the loaded
fixture inventory; this is not a scan of real HANA/Qlik/Spotfire servers.

## Reproduce

1. `python prepare.py` — regenerate original synthetic dataset.
2. `python prepare_connected_fixtures.py` — author metadata and run fixture checks.
3. Inspect `fixtures/source-register.json` for identity, hashes and validation status.
4. Index only the explicit documents in `fixtures/search_documents.json`.
5. Keep `evaluation/` and this demo script out of all search ingestion.

The three core scenarios form one story: discover existing work, explain the business
definition difference, then build a consistent reusable product. Do not claim all
three workflows work merely because the fixture preparation tests pass.
