# L2P — Logic to Product

**Event build, October 23, 2026.** Use branch `l2p-hackathon-build`. The preparation baseline is commit `659671ba0744b1126d043af3c25843c6249538bb`; it is not claimed as event work.

“Moving data is easier. What we are doing now is moving knowledge, with Snowflake, CoCo and Claude.” Here, knowledge means the business definitions embedded in reports and source models.

## Review the demonstration

- Video is withheld pending the owner's review and approval.
- [Editable presentation](submission/L2P-Submission-Deck.pptx).
- [Case study](submission/L2P-CASE-STUDY.txt).
- [Technical architecture](submission/L2P-Technical-Architecture.png).
- [Submission narrative and limitations](submission/L2P-SUBMISSION-FINAL.txt).
- [Recorded walkthrough](demo-evidence/index.html), usable locally in a browser. Source tool traces are beside it.
- Live local two-chat UI: see [UI instructions](ui/README.txt).

The presenter reports Snowflake CoWork access is working. The custom chat remains a separate local interface. Judge access requires appropriate account permissions.

## What works

Two saved Cortex Agents use explicit `claude-opus-5-5`. The Builder retrieves synthetic definitions and uses bounded recipes to propose, create, validate and release a product. Eleven deterministic checks gate release. A failed fanout candidate was refused; a correct daily product passed and was released. The consumer uses Cortex Analyst over a guarded semantic view. The chat backend verifies recorded passing checks and current release integrity before and after answering, including result-version checks.

The matched positive Builder/Consumer demo evidence uses release 603, with 241 rows and 53,589.47 invoiced sales excluding tax. The earlier fanout rejection is a separate recorded negative test. A later read-only registry review found current release 604 with eleven recorded PASS checks. Its rejected negative candidate also logged an extra SCHEMA_EXACT error, which remains unresolved. No currency is modeled.

## Evidence scope

| Evidence | Result | Scope |
|---|---|---|
| Procedure regression | 32/32 | Historical backend revision; not agent tests |
| Custom agent suite `run_20261023_133220` | 19/19 | Ten fixed synthetic cases; review findings remain |
| Post-version-fix `run_20261023_140625` | 2/2 | Two agent-driven builds |
| Native `L2P_SEMANTIC_20261023_1405` | Four correctness scores 1.00 | Two read-only cases per agent; one Builder consistency score 0.67 |
| Final semantic verification + UI | Passing, release 603 | Actual contract/integrity checks and semantic ranking |

The Builder consistency finding concerns a citation drawn from a search snippet without retrieving its full definition. An unsupported invoice-delay claim in an earlier custom run also remains a finding. These small suites are not production reliability estimates.

## Deployment order

Use the existing project setup for synthetic data/catalog/search first, followed by the event SQL in order: control, Builder procedures, Consumer procedures, initial agent definitions and staged skills. Then apply `sql/50_semantic_product.sql`, `sql/51_builder_semantic_update.sql`, and `sql/52_consumer_semantic_update.sql`. The last two use ALTER, preserving existing agents and evaluation history. **Do not rerun initial CREATE OR REPLACE AGENT statements over evaluated agents.** After a valid release, call `L2P.PUBLISH_RELEASED_SEMANTIC_PRODUCT()` to publish its guarded semantic source.

Use the HACKATHON account/role guard in `tests/run_sql.py`. Never commit a PAT. Native evaluations require the relevant evaluation permissions, including EXECUTE TASK in this workshop setup. The UI is loopback-only, with no public hosting or multi-user authentication.

## Explicit boundaries

All rows are independently generated synthetic data for fictional Northstar Supply. The simplified schema adapts public Microsoft Wide World Importers under MIT; retain the source license. HANA/Qlik/Spotfire definitions are normalized fixtures, not live BI connectors. Qlik currently demonstrates aliases and aggregation, not a rich cross-layer filter scenario. Spotfire has one fixture and no dedicated skill. Three skills are attached; invocation is unverified. Retrieval uses whole documents, not chunking. Tool separation uses one workshop role, not independent user RBAC. No campaigns are sent, and consent, margin, uplift and production savings are not established.

CoCo built the core backend and custom suite. Supplementary engineering added the local UI, native evaluations, semantic extension and submission artifacts. Snowflake Decision and enterprise MCP/Fabric adapters are future experiments, not integrated features.

## Package and history

The public submission directory contains one current deck, architecture, case study and form narrative. Video is withheld; internal presenter scripts, Q&A and planning notes are not part of the current package. Earlier commits remain available for provenance.

The baseline is on `hackathon-prework`; event work is on `l2p-hackathon-build`. Keep raw fixtures, source licenses, SQL, skills, tests and recorded evaluation evidence. Do not treat old test results as proof of later revisions. Example-question-only agent edits preserved all other live specification fields and existing native evaluations; they were not a new evaluation run.
