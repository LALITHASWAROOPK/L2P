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
