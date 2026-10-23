"""EVENT-BUILT: upload the three reviewed L2P skill folders to a dedicated internal stage.

Only skills/l2p-*/SKILL.md are uploaded. Records local SHA256 and staged MD5 to evidence/skills_stage.json.
"""
import hashlib
import json
from pathlib import Path

from run_sql import connect, ROOT

PROJECT = ROOT.parents[1]
SKILLS = ["l2p-hana-interpretation", "l2p-qlik-interpretation", "l2p-create-data-product"]
STAGE = "HACKATHON_D2K_PREWORK.L2P.SKILL_STAGE"

conn = connect()
cur = conn.cursor()
cur.execute(f"CREATE STAGE IF NOT EXISTS {STAGE} DIRECTORY = (ENABLE = TRUE) "
            "COMMENT = 'EVENT-BUILT: reviewed L2P builder skill files only (SKILL.md). No scripts.'")
records = []
for s in SKILLS:
    f = PROJECT / "skills" / s / "SKILL.md"
    sha = hashlib.sha256(f.read_bytes()).hexdigest()
    cur.execute(f"PUT 'file://{f.as_posix()}' @{STAGE}/skills/{s}/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE")
    put_qid = cur.sfqid
    records.append({"skill": s, "local_path": f"skills/{s}/SKILL.md", "sha256": sha, "put_query_id": put_qid})
cur.execute(f"ALTER STAGE {STAGE} REFRESH")
cur.execute(f"LIST @{STAGE}")
listing = [{"name": r[0], "size": r[1], "md5": r[2], "last_modified": r[3]} for r in cur.fetchall()]
out = {"stage": STAGE, "uploaded": records, "list": listing, "list_query_id": cur.sfqid}
(ROOT / "evidence" / "skills_stage.json").write_text(json.dumps(out, indent=1), encoding="utf-8")
print(json.dumps(out, indent=1))
conn.close()
