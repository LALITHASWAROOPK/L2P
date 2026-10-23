"""EVENT-BUILT L2P helper: run a SQL file against the HACKATHON connection only.

Refuses to run unless the session is the expected hackathon account/role/warehouse.
Logs each statement's query ID to event/l2p/evidence/deploy_log.jsonl. Never prints credentials.
"""
import io
import json
import os
import sys
import time
from pathlib import Path

import snowflake.connector

EXPECTED = ("SFSEHOL", "ANTHROPIC_SNOWFLAKE_HACKATHON_BXVLTM", "ATTENDEE_ROLE", "DEFAULT_WH")
ROOT = Path(__file__).resolve().parents[1]
LOG = ROOT / "evidence" / "deploy_log.jsonl"


def connect():
    # Prefer a PAT injected at runtime (L2P_PAT env var, from the local secret store); fall back to SSO.
    extra = {}
    token = os.environ.get("L2P_PAT", "").strip()
    pat_file = os.environ.get("L2P_PAT_FILE")
    if not token and pat_file and Path(pat_file).exists():
        token = Path(pat_file).read_text(encoding="utf-8").strip()
    if token:
        extra = {"authenticator": "PROGRAMMATIC_ACCESS_TOKEN", "token": token}
    conn = snowflake.connector.connect(connection_name="HACKATHON", role="ATTENDEE_ROLE", warehouse="DEFAULT_WH",
        client_store_temporary_credential=False, client_request_mfa_token=False, **extra)
    got = conn.cursor().execute(
        "SELECT CURRENT_ORGANIZATION_NAME(), CURRENT_ACCOUNT_NAME(), CURRENT_ROLE(), CURRENT_WAREHOUSE()").fetchone()
    if tuple(got) != EXPECTED:
        conn.close()
        raise SystemExit(f"Refusing to run: session is {got}, expected {EXPECTED}")
    return conn


def run_file(conn, path):
    sql = Path(path).read_text(encoding="utf-8")
    results = []
    with LOG.open("a", encoding="utf-8") as log:
        for cur in conn.execute_stream(io.StringIO(sql), remove_comments=True):
            row = cur.fetchone() if cur.description else None
            rec = {"ts": time.strftime("%Y-%m-%dT%H:%M:%S%z"), "file": str(Path(path).name),
                   "query_id": cur.sfqid, "first_row": None if row is None else [str(v)[:300] for v in row]}
            log.write(json.dumps(rec) + "\n")
            results.append(rec)
    return results


if __name__ == "__main__":
    c = connect()
    try:
        for f in sys.argv[1:]:
            out = run_file(c, f)
            print(f"{f}: {len(out)} statements OK; last query_id={out[-1]['query_id'] if out else None}")
    finally:
        c.close()

