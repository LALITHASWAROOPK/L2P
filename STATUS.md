> Historical checkpoint log. For current event behavior and limitations, see [START-HERE](event/l2p/START-HERE.md).

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
- Stoweaway and employer objects: untouched.
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


- Public repository published: https://github.com/LALITHASWAROOPK/L2P
  Branch hackathon-prework; baseline eaca841 retained, search extension 3833f37.
  Only reviewed public-source and synthetic files published; screenshots and UI traces
  remain local and ignored. No private company assets or credentials included.

## Connected synthetic scenarios
- Nine original source artifacts prepared for Northstar Supply: two normalized HANA
  model XML files plus SQL equivalents, Qlik load script and chart metadata, Spotfire
  source SQL and visual metadata, and business definitions. No native HANA/QVF/DXP
  deployment or validation is claimed.
- Five local checks passed: both model joins preserve line grain, both totals match
  independent Decimal calculations, and both BI projections resolve to model columns.
- Independent expected daily product has 241 date/customer/product groups.
- All-date ordered value 65893.02; invoice sales 53589.47; difference 12303.55.
  Naive product-group join inflates invoice sales to 64027.32.
- Repeated generation produced identical files. Evaluation answers are stored only
  under evaluation/ and excluded from the search ingestion allowlist.
- Nine connected documents loaded to the existing Snowflake catalog; total 24
  documents (9 connected, 12 public SQL, 3 synthetic reports). Refresh requested.
- Existing two-tool starter updated to recognize the new synthetic artifact type.
  No additional tools, role grants, native connections or product-writing actions.
- Fresh-thread connected discovery test found both BI fixtures and distinguished
  order/invoice definitions, date basis and shared tax treatment. Search trace
  succeeded in 453ms; agent 21.3s. Request 29efec26-4bd8-42ce-ae67-f4ddb5d684a7,
  thread 875088652. This is discovery evidence, not full lineage validation.
- Remaining wording issues observed: "never invoiced" should mean not invoiced in
  this snapshot; "invoice data here has no order tables" is too broad. RAW orders
  exist but are not exposed by the current InvoiceData semantic tool. Add orders
  query coverage during the event before demonstrating numeric reconciliation.
- Product-generation and stock-group ambiguity agent scenarios are not yet tested.
  Their prepared fixtures and independent oracles are available for event work.

## EVENT BUILD (hackathon 2026-10-23) — L2P Logic to Product (in progress)
Everything below was built during the event on branch l2p-hackathon-build, starting
from prework baseline commit 659671ba0744b1126d043af3c25843c6249538bb. Code: event/l2p/, skills/.
Status is updated as work proceeds; items marked PENDING have not been run yet.

Deployed (new schemas only; RAW, ANALYTICS, starter agent and catalog untouched):
- L2P (registry, contract, recipes, builder procs, skill stage), L2P_STAGE (snapshots, candidates),
  L2P_RELEASE (released versions), L2P_CONSUMER (read procs + consumer agent).
- Agents: L2P.L2P_BUILDER and L2P_CONSUMER.L2P_CONSUMER, both on claude-opus-5-5 (verified in
  DESCRIBE AGENT). Builder: catalog search + 7 bounded procs. Consumer: 3 read-only procs only.

Step A baseline (live): 96 invoices, 243 lines, 53589.47 excl. tax, 241 expected grain rows,
stock-group join fanout 293 rows.

Contract regression, direct procedure calls (NOT agent evidence): 32/32 asserts PASS.
- Pre-release discovery: no product; ranking refuses.
- B stock-group fanout: FAILED (line coverage, grouped + total reconciliation); not released; consumer saw nothing.
- Single-group omission: FAILED on dropped lines. Order-date basis: totals PASS but grouped
  reconciliation FAILS, so blocked (proves totals alone are insufficient).
- C correct recipe: 11/11 checks PASS, released v1 = L2P_RELEASE.DAILY_INVOICED_SALES_V0001
  (241 rows, 53589.47). Consumer ranking equals independent snapshot ranking.
- D bad candidate after release: release and consumer results unchanged.
- E: repeated release rejected; post-validation tamper rejected (CHANGED_AFTER_VALIDATION);
  unknown/malformed IDs, unsupported recipe, unvalidated release, re-create all rejected.
- Defect found and fixed: a validation crash during development left candidate C00001 in
  CREATED with run V00001 RUNNING (never releasable, but unexplained). Validation now records
  FAILED with the error. C00001 retained as evidence.

Agent orchestration (step F), via SNOWFLAKE.CORTEX.DATA_AGENT_RUN on saved agents:
- C1 consumer account review: PASS. Called DiscoverReleasedProduct + RankCustomersBySales,
  named version 1 and the queried object, top 5 = customers 10, 8, 19, 18, 4, which matches the
  independent snapshot ranking exactly. Stated consent/margin/response/uplift boundary. 24.7s.
- Consumer uplift/consent/send and raw-SQL/release escape prompts: correct refusals; no send, no builder tools.
- Builder Spotfire and Qlik traces: correct chains with version citations; ordered 65893.02 vs
  invoiced 53589.47, gap 12303.55 = 24 uninvoiced orders (matches prework oracle).
- Builder agent-driven build: fanout candidate FAILED and rejected; correct candidate released.
- Starter comparison (same prompts): starter traced the Spotfire measure from search only (no exact
  retrieval tool) and, asked to build, refused and offered proposed SQL plus a preview query via
  system_execute_sql. It has no product, validation or release path. Observed outcomes only.

Compact agent evaluation suite v2 (event/l2p/eval/agent_eval_cases.json; tests/eval_agents.py):
- Grading: structured tool results + registry state + oracle from the released version's own
  snapshot; claim-level citation support against retrieved content; wording regexes are review flags only.
- Run run_20261023_133220: 19/19 runs PASS across 10 cases, all repeats consistent.
  Cases: consumer normal x2 (top-5 x3, date-filtered top-3), boundary (consent/uplift/send x3),
  failure (raw SQL + release), builder Spotfire trace x3, Qlik trace + reconciliation,
  negative order-date candidate x3 (GROUPED_RECONCILIATION FAIL while TOTAL PASS, not released),
  positive build x2 (documented versioning), boundary arbitrary-table release, stock-group additivity.
  Latency 8.7s-84.3s. Manual interventions: none (PAT auth; one-time PAT setup by user).
- Follow-up runs run_20261023_134813 (5/5) and run_20261023_140625 (2/2) after the fix below.
- Open review flag (real unsupported claim): builder Qlik answer said invoices run "about 2 days"
  after orders; no tool computed this. Not fixed.
- Agent-level missing-product case: UNTESTED (would require deleting releases). Procedure-level
  evidence retained (regression E0).
- 19/19 is a small fixed suite on synthetic data, not a general reliability claim.

Defects found by evaluation:
- Release version numbers came from a NOORDER sequence and could be out of release order
  (v401 released before v302). The current-release pointer was always correct. Fixed: version =
  MAX(released)+1, with a concurrent duplicate failing on the clone name. Verified v601-v603 sequential.
  Earlier versions 1, 101, 102, 201, 202, 301, 302, 401, 501 remain as evidence; all have identical
  content hash 118407673939843085 (same data, 241 rows).

Skills: authored (3 reviewed SKILL.md files, original) -> staged on @L2P.SKILL_STAGE (hashes in
event/l2p/evidence/skills_stage.json) -> ATTACHED to L2P_BUILDER only (verified in DESCRIBE AGENT).
Invocation: NOT DEMONSTRATED. Across all DATA_AGENT_RUN responses (eval and ad hoc), zero
skill-selection or skill-loading events appeared. Answers were correct, but that does not prove
skill use. Next step: inspect a Snowsight thinking-step trace for one builder prompt; if skills
still do not load, report it as a blocker. The instruction fallback is not enabled.

Remaining blockers / not done:
- Native skill invocation evidence (above).
- Retrieval baseline vs chunked vs skills comparison: NOT RUN. The current 24 short documents are
  retrieved whole; no chunking implemented.
- Cross-layer Qlik business-rule (report filter) scenario: NOT BUILT. Existing Qlik fixture only
  renames and sums, so it does not demonstrate Qlik-side business logic.
- Per-user RBAC separation between builder and consumer: not configured (single ATTENDEE_ROLE).

Limitations: enforcement is procedure/tool-level under one role (ATTENDEE_ROLE); separate per-user
RBAC for builder vs consumer is not configured or tested. The object owner can still alter
tables directly; the release/consumer hash checks detect, but cannot prevent, such changes.
Python test runs authenticate with a user-created PAT read from a local file outside the repo.
