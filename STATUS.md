# Pre-work status

Date: 2026-10-23, America/Los_Angeles.

- Public source download: complete, pinned commit and MIT license retained.
- Dataset generation: complete, seed 231026, 8 tables / 818 rows.
- Local dataset-integrity validation: 20 checks passed.
- Snowflake load: complete in the supplied hackathon account under ATTENDEE_ROLE,
  database HACKATHON_D2K_PREWORK, RAW schema. All eight row counts match.
- Starter semantic view: deployed as ANALYTICS.SV_INVOICE_STARTER.
- Starter agent: deployed as ANALYTICS.PREWORK_QUERY_AGENT (Prework Synthetic Sales).
- Snowflake aggregate verification: 53589.47 sales excluding tax, 5359.07 tax,
  58948.54 including tax; 243 invoice lines. Matches local calculation.
- Agent natural-language smoke test: passed for numeric correctness in Agent Studio
  Preview (Draft). Prompt: "For all available synthetic invoices, what are total
  sales excluding tax, total tax, and total including tax? Query the data."
  Returned 53589.47 / 5359.07 / 58948.54 and 96 invoices, matching independent totals.
  Trace confirms InvoiceData executed SQL against RAW.INVOICELINES successfully;
  verified-query-used=false. Request c718c839-4a39-4636-baba-590fb61c2a89;
  query 01c7eba2-010c-6e5f-0034-28cb001b3146; reported duration 12.4 seconds.
  This is one setup smoke test, not a general reliability evaluation.
- Known starter response limitations: added a dollar symbol despite no modeled currency
  and offered to schedule the summary despite no scheduling tool being configured.
  Neither was acted on. Record as baseline weaknesses; do not present as polished behavior.
- Agent is saved and usable in Preview; not published to CoWork or shared with new roles.
- Public GitHub publication: not performed. Local isolated Git baseline only.
- Stoweaway and Agilent objects: untouched.
- New grants, schedules, external integrations: none.
- Core discovery/lineage/product-building workflow: not built; reserved for event.

Screenshots load-proof.png and totals-proof.png are local verification evidence.
Original SQL source is local reference material, not yet searchable by the starter agent.
The account expires 2026-10-27 22:00 Pacific according to the supplied guide.


## Basic catalog/search extension — October 23, pre-event

- Three synthetic executable report views deployed: daily invoice sales, daily ordered

  sales and customer invoice sales. These are fixtures, not published BI dashboards.

- T_PREWORK_CATALOG holds three report definitions plus twelve original public SQL

  reference files; source hashes verified locally, license retained.

- CSS_PREWORK_CATALOG created; ReportCodeSearch connected alongside InvoiceData.

- Local report checks: daily invoices 48 dates / 96 invoices; customer report 20

  customers / 96 invoices; orders 53 dates / 120 orders. Both invoice reports

  reconcile to 53589.47 excluding tax. Direct Snowflake daily-report totals also

  returned 96 / 53589.47 / 5359.07 / 58948.54.

- Fresh-thread discovery smoke test passed: found all three synthetic reports,

  explained the correct revenue expression and joins, distinguished reference SQL

  from deployed fixtures, and did not claim full lineage or product creation.

  Request 3860349f-2c70-4ef3-b6be-040c64503dcd; thread 875088648.

  Agent Studio trace: successful Cortex Search call, 439ms; agent 17.9s.

- Currency/scheduling rules tightened. Rollback restores the original agent spec

  using rollback_search.sql; the data/search artifacts are retained for inspection.

- Earlier status entries above describe the original baseline, not this extension.

- Custom lineage/reconciliation and product creation remain unimplemented.

- Follow-up regression passed: invoice totals unchanged, no currency symbol,

  scheduling request declined. Trace confirms semantic context and SQL execution.

  Request ea06ec0a-45e3-4e28-9018-b108829b1e2d; agent duration 19.1s.

  These two sampled tests are setup checks, not a broad reliability claim.


- Public repository published: https://github.com/LALITHASWAROOPK/d2k-inspired-sales-hackathon
  Branch codex/hackathon-prework; baseline eaca841 retained, search extension 3833f37.
  Only reviewed public-source and synthetic files published; screenshots and UI traces
  remain local and ignored. No private company assets or credentials included.
