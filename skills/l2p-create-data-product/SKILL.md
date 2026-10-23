---
name: l2p-create-data-product
description: Propose and build L2P daily invoiced-sales products from supported source mappings using configured bounded candidate, validation and release tools. Use only for the builder agent; it does not grant SQL access or replace the enforced release contract.
---

# Create a contract-gated data product

Use only configured bounded tools. This skill grants no additional permissions and must not introduce shell access, arbitrary SQL, arbitrary object identifiers or a path around validation. It is original hackathon authoring, not a company procedure.

Resolve the requested definition from retrieved source evidence. Record grain, keys, date basis, amount formula, dimensions, scope and source versions. For the supported daily invoiced-sales recipe, the requested grain is invoice date/customer ID/stock item ID; verify the source mapping for invoice-line ExtendedPrice minus TaxAmount and header date/customer. Do not silently substitute ordered sales, assume currency, zero-fill dates or invent allocation rules. Ask only about material business choices the request and evidence leave unresolved.

Present the proposed specification separately from execution. When creation is authorized, call the registered candidate tool with its supported parameters. Reject unsupported recipes through the tool boundary. Save the returned candidate ID, source snapshot, contract version, definition hashes, executed SQL identity and state. Never report a proposal as a created product or a tool error as success.

Invoke the contract validator on that candidate. Require typed fields, non-null keys, unique grain, source referential integrity, full source coverage without dropped or multiplied lines, dimension/scope consistency, grouped reconciliation and overall amount reconciliation against the same snapshot. Source reconciliation must be independent of the candidate transformation. Do not substitute a remembered expected total for these checks.

Release only through the controlled release tool after a passing validation. The tool must enforce that the exact validated candidate is released, reject stale or changed candidates, and update release identity consistently. A skill instruction, agent judgment or status badge is not enforcement. If the tool cannot demonstrate these properties, report the gap and do not claim a governed release. A failed candidate must leave the existing passing release intact.

After release, read back the released object/version and validation run. Return the product's definition, lineage references, state, checks, failure reasons when applicable, and release identity. Hand off only the released product identity and supported contract context to the consumer agent. The consumer queries it through its own read-only tools; do not answer the consumer's closing question from RAW or evaluator files on its behalf.

For an explicitly requested negative test, use a bounded test recipe/candidate. Never corrupt RAW or bypass the gate to stage a convincing demo. Record actual failures and query IDs. Revalidate after changes; a passing snapshot is not approval for future data or production use.

Document the enforcement boundary accurately. Procedure/tool restrictions do not establish separate per-user RBAC unless configured and tested. No campaign sends, schedules, public publishing or external side effects are authorized by this skill. Sales can support account-review prioritization; it does not establish consent, margin, response or causal uplift.
