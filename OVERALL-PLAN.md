# D2K-inspired hackathon: overall plan and checkpoint

Updated: 2026-10-23 (America/Los_Angeles).
Status: pre-work foundation complete; main competition functionality not implemented.
Baseline commit: `eaca841` on `codex/hackathon-prework`.

## What we are building

A small synthetic enterprise assistant for a data developer who asks:

> Find existing sales reports, explain ordered versus invoiced sales and where their
> fields come from, then prepare a reusable daily invoiced-sales data product.

The intended sequence is **discover -> understand -> trace -> reuse/build -> validate**.
The user should not have to know the table name, report acronym or exact code location.
This is a scoped demonstration of D2K's approach, not a copy of Agilent's D2K assets.

## Where the D2K flavor comes from

| D2K capability | Hackathon equivalent | Current status |
|---|---|---|
| Business-language discovery across catalogs | Find reports, tables and SQL using names, descriptions and field evidence | Pending |
| Technical source inspection | Retrieve preserved SQL and inspect executable Snowflake definitions | Original public SQL saved locally; not connected to agent |
| Field and transformation lineage | Follow explicit relationships from a report field through a transformation to source columns | Pending |
| Reconcile incomplete metadata | Compare catalog claims with current definitions; distinguish missing evidence from absence | Pending |
| Help build a data product | Generate a specification, mappings, SQL and checks from supported sources | Pending |
| Grounded answers and uncertainty | Show verified results; ask about material ambiguity; do not invent dependencies | Basic starter only; not generally evaluated |
| Reuse across users | Register an approved product so a subsequent request can discover it | Stretch goal |

Synthetic rows alone do not create this value. The added capability is gathering and
reconciling technical and business context, then checking the resulting product.
No real HANA, Qlik, Spotfire or Fabric connection is planned for this demo. Any report
fixtures we author must be labeled synthetic and must not claim actual platform coverage.

## What is complete

1. Confirmed the separate hackathon account and supplied Stoweaway components.
2. Downloaded 14 public Microsoft source files, including MIT license, eight table
   definitions, selected views, an invoicing procedure and README. Source pinned to
   `dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a`; URLs and SHA256 recorded.
3. Created a simplified Snowflake schema adaptation with independently generated rows.
   This is not a Microsoft database export and not a full operational WWI migration.
4. Loaded eight tables / 818 rows in `HACKATHON_D2K_PREWORK.RAW`:

| Table | Rows |
|---|---:|
| CUSTOMERS | 20 |
| STOCKITEMS | 15 |
| STOCKGROUPS | 3 |
| STOCKITEMSTOCKGROUPS | 18 |
| ORDERS | 120 |
| ORDERLINES | 303 |
| INVOICES | 96 |
| INVOICELINES | 243 |

5. Passed 20 local integrity checks; verified Snowflake row counts and monetary totals.
6. Created `HACKATHON_D2K_PREWORK.ANALYTICS.SV_INVOICE_STARTER` and
   `HACKATHON_D2K_PREWORK.ANALYTICS.PREWORK_QUERY_AGENT` (Prework Synthetic Sales).
   One Analyst tool, InvoiceData; explicit Claude model matching the supplied lab.
7. Tested the saved draft in Agent Studio Preview. Actual SQL execution returned:
   sales excluding tax 53,589.47; tax 5,359.07; including tax 58,948.54; 96 invoices.
   Local calculation and direct Snowflake query agree. See STATUS.md for trace IDs.
8. Saved reproducible generation/loading scripts and an isolated local Git baseline.

No Agilent data/code/skills/logs/credentials were copied. Stoweaway is unchanged.
No GitHub publication, additional role grants, schedules or external integrations.

## Known limitations of the foundation

- Starter answers invoice questions; it does not discover code, trace lineage or build products.
- Original SQL Server sources contain dependencies omitted from the simplified dataset.
  Label original versus adapted artifacts separately; never claim operational equivalence.
- No currency is modeled. The smoke-test answer nevertheless used a dollar sign.
- It offered scheduling despite having no configured scheduling tool. No schedule was created.
- One successful smoke test does not establish general answer reliability.
- No returns, discounts, cancellations or currency conversion are modeled.
- Stock-group membership is many-to-many and can multiply totals if joined carelessly.
- Agent is saved in Preview, not published to CoWork or granted to other roles.

## Event implementation order

### 1. Prepare the small evidence collection
Create two or three executable synthetic report queries and short business definitions.
Inventory deployed columns and definitions. Keep source system, object identity, artifact
type, original/adapted status and version on every asset. Introduce at most one documented
stale catalog snapshot to exercise reconciliation. Keep reference answers outside retrieval.

### 2. Add discovery and lineage
Provide semantic discovery for business wording and exact structured lookups for object
and field coverage. Retrieve relevant code sections and explicit dependency edges.
Support a bounded SQL subset; flag unsupported syntax rather than promising a universal
parser. Do not equate top-ranked search results with exhaustive coverage or infer absence
from a missing catalog row. Avoid unnecessary tools and a sprawling global prompt.

### 3. Build one product workflow
Capture intended grain, keys, date basis, measures, tax treatment and dimensions.
Clarify only business choices that materially affect the result. Propose source mappings,
generate SQL into an isolated draft schema, execute it with bounded permissions, and
validate counts, uniqueness, missing references and reconciled totals.
Keep proposed, executed and validated states distinct.

### 4. Test the actual differentiation
Use a reasonable CoCo baseline with the same assets and access. Compare source discovery,
definition correctness, lineage completeness, validation results and user intervention.
Include a second request or data variation not used to tune the workflow. Do not claim
improvement unless the observed results support it. A simple semantic-view-generation
prompt is not sufficient differentiation.

### 5. Package the result and demonstrate
Minimum outcome: an executable draft product, field mappings, lineage and test report.
Stretch: explicit approval-controlled registration, then discover/reuse the new product.
Do not silently overwrite source objects or publish an unvalidated product.
Create a public repository containing only redistributable assets, preserve attribution,
and clearly separate pre-work, supplied demo and event-built code.
Prepare the required one-minute video and approximately three-minute live demonstration.

## Proposed demonstration

1. "Where can I find sales reporting?" -> finds relevant synthetic reports by meaning.
2. "Why do ordered sales and invoiced sales differ?" -> inspects actual definitions.
3. "Build daily invoiced sales by customer and product, excluding tax." -> proposes
   specification, creates a draft and reconciles it against source invoice lines.
4. Optional: request stock-group breakdown -> recognize many-to-many allocation ambiguity
   instead of presenting duplicated money as valid totals.

Keep the user-facing answer brief. Source details and validation should be inspectable,
without overwhelming the business summary. The example is a proposed story, not a claim
that these capabilities are already implemented or that a particular failure will occur.

## Preparation boundary and event rules

The technical guide explicitly encourages account setup, data loading and creating a
starter Cortex agent before the event. Those steps are complete.

The participant guide requires a public repository and requires the demo to highlight
features/code/functionality built during the hackathon, clearly identifying new work.
It excludes basic RAG applications and dashboard-led entries. The published schedule is
October 23, 11:00 a.m.–4:30 p.m. Pacific for building, with submissions due at 4:30 p.m.

We can technically build everything beforehand, but cannot claim pre-event functionality
as event-built work. Before the official start, stop at this foundation unless organizers
explicitly clarify a broader allowance. Once the event begins, implement the pending
workflow and keep the new commits distinct. Do not assume that calling work "pre-work"
makes an otherwise completed entry eligible. This plan is guidance, not organizer approval.

CoCo and Claude are encouraged development tools. The published rules do not explicitly
address Codex; confirm with organizers if using it during the competition.

Rules: https://cerebralvalley.ai/e/intelligence-at-work-hackathon/details
Technical guide: https://docs.google.com/document/d/17O5M8jxzpjuVORgnxvOwcT4hwdU5N1sKVYWTWOg6Nqo/edit

## Files and resume point

- README.md: provenance, scope, reproduction and limitations.
- STATUS.md: deployment/test evidence and known issues.
- prepare.py, data/: deterministic synthetic data and local checks.
- 01_load.sql: one-time isolated database load; do not blindly rerun.
- 02_starter.sql: basic semantic model and starter agent.
- source/manifest.json and source/: original public source evidence and license.
- validation.json: dataset integrity results and expected setup totals.

Next implementation step at the event: add the small report/code evidence collection,
then discovery and lineage. Do not spend the event rebuilding the starter or importing
an entire enterprise database. Keep generated products isolated from the baseline.
Save artifacts locally: the supplied account expires October 27 at 10 p.m. Pacific.
