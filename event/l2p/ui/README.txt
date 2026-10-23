L2P local demo interface — event-built by Codex

Architecture: browser -> local Python HTTP backend -> saved Snowflake Cortex agent
-> bounded tools -> contract/registry -> released product.

Requires Python with snowflake-connector-python, a configured HACKATHON connection,
and the L2P repository's event/l2p/tests helpers. The account/role/warehouse guard in
run_sql.connect() is retained. Agents and tools were built with Cortex Code.

Set these environment variables before running python server.py:
L2P_PROJECT: absolute path to the L2P repository
L2P_PAT_FILE: absolute path to the existing local credential file (never commit it)
L2P_DEMO_EVIDENCE: local output directory for generated run traces

Open http://127.0.0.1:8765 in a local browser. Server binds only to loopback.
No public hosting or remote-user authentication is implemented.

The Build tab offers evidence tracing, report reconciliation, and a bounded
negative/positive build demonstration. Test and release a product writes new
candidates and may create a new release version; its button states this explicitly.
The Use tab calls the read-only consumer agent. Every button starts a fresh turn.
Only one request can run at a time. Agent responses are displayed as safe plain text.
Query IDs, latency and actual tool traces are available under Execution evidence.

Do not include credential files or private source material in the submission.
These files contain no credentials. Runtime traces are written outside this folder.
