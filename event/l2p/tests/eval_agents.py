"""EVENT-BUILT L2P compact agent evaluation (grader v2).

Fixed prompts/facts: event/l2p/eval/agent_eval_cases.json (kept out of retrieval and agent context).
Grading uses structured tool results, registry state and independent oracles computed from the
released version's source snapshot. Wording regexes are review flags only.
Output: event/l2p/evidence/eval/<run_tag>/results.json and summary.md
Usage: python eval_agents.py [case_id ...]
"""
import hashlib
import json
import re
import sys
import time

from run_sql import connect, ROOT
import test_agents as ta

CASES = json.loads((ROOT / "eval" / "agent_eval_cases.json").read_text(encoding="utf-8"))
FACTS = CASES["expected_facts"]
AGENTS = {"builder": ta.BUILDER, "consumer": ta.CONSUMER}
HEX64 = re.compile(r"\b[0-9a-fA-F]{64}\b")
TRUNC = re.compile(r"\b([0-9a-fA-F]{8})[0-9a-fA-F]*\s?(?:…|\.\.\.)\s?([0-9a-fA-F]{4})\b")


def q(cur, sql, *a):
    cur.execute(sql, a)
    return cur.fetchall()


def state(cur):
    cur_rel = q(cur, "SELECT VERSION, CANDIDATE_ID, RELEASE_OBJECT, SNAPSHOT_ID FROM HACKATHON_D2K_PREWORK.L2P.RELEASES WHERE IS_CURRENT")
    return {"current": [list(map(str, r)) for r in cur_rel],
            "n_releases": q(cur, "SELECT COUNT(*) FROM HACKATHON_D2K_PREWORK.L2P.RELEASES")[0][0],
            "ts": q(cur, "SELECT CURRENT_TIMESTAMP()")[0][0]}


def agent_config(cur, fqn):
    cur.execute(f"DESCRIBE AGENT {fqn}")
    row = dict(zip([d[0].lower() for d in cur.description], cur.fetchone()))
    spec = json.loads(row["agent_spec"])
    return {"agent": fqn, "model": spec.get("models", {}).get("orchestration"),
            "spec_sha256": hashlib.sha256(row["agent_spec"].encode()).hexdigest(),
            "tools": [t["tool_spec"]["name"] for t in spec.get("tools", [])],
            "skills": [s["name"] for s in spec.get("skills", [])], "version": row.get("default_version_name")}


def proc_results(rec):
    """Parse the JSON returned by each custom-tool procedure from the agent trace."""
    out = []
    for c in rec["tool_trace"]:
        if c["kind"] != "tool_result":
            continue
        try:
            for item in json.loads(c.get("full") or "[]"):
                r = (item.get("json") or {}).get("result")
                if isinstance(r, str):
                    try:
                        out.append(json.loads(r))
                    except ValueError:
                        pass
        except (ValueError, TypeError, AttributeError):
            pass
    return out


def consumer_oracle(cur, rel, top_n, start, end):
    """Expected ranking from the released version's own source snapshot (not live RAW)."""
    p = f"HACKATHON_D2K_PREWORK.L2P_STAGE.SNAP_{rel[3]}_"
    where = []
    if start:
        where.append(f"h.INVOICEDATE >= '{start}'")
    if end:
        where.append(f"h.INVOICEDATE <= '{end}'")
    rows = q(cur, f"""SELECT h.CUSTOMERID, SUM(l.EXTENDEDPRICE) - SUM(l.TAXAMOUNT) S FROM {p}INVOICELINES l
                      JOIN {p}INVOICES h ON h.INVOICEID = l.INVOICEID {('WHERE ' + ' AND '.join(where)) if where else ''}
                      GROUP BY 1 ORDER BY S DESC, 1 LIMIT {int(top_n)}""")
    return [[int(c), round(float(s), 2)] for c, s in rows]


def nums_in(text):
    return {round(float(x.replace(",", "")), 2) for x in re.findall(r"\d[\d,]*\.\d{2}", text or "")}


def grade(cur, case, rec, before, after, catalog_versions):
    text = rec.get("final_text") or ""
    tools = [c["name"] for c in rec["tool_trace"] if c["kind"] == "tool_use"]
    pres = proc_results(rec)
    checks, flags, oracle_info = [], [], {}

    def chk(name, ok, detail=None):
        checks.append({"check": name, "pass": bool(ok), "detail": detail})

    chk("no_run_error", rec.get("error") is None, rec.get("error"))
    for t in case.get("require_tools", []):
        chk(f"tool_called:{t}", t in tools, tools)
    for pre in case.get("forbid_tools_prefix", []):
        bad = [t for t in tools if t and t.startswith(pre)]
        chk(f"tool_not_called:{pre}*", not bad, bad)
    for group in case.get("require_concepts", []):
        chk(f"addresses:{'|'.join(group)}", any(g.lower() in text.lower() for g in group))
    for rx in case.get("flag_regex", []):
        for m in re.finditer(rx, text):
            s = max(0, m.start() - 60)
            flags.append(f"review[{rx}]: ...{text[s:m.end() + 60]}...".replace("\n", " "))

    # Consumer: structured ranking vs oracle from the released version's snapshot.
    if case.get("consumer_oracle"):
        o = case["consumer_oracle"]
        rel = after["current"][0]
        exp = consumer_oracle(cur, rel, o["top_n"], o["start"], o["end"])
        oracle_info = {"release_version": rel[0], "release_object": rel[2], "snapshot_id": rel[3], "expected": exp}
        ranks = [r for r in pres if "ranking" in r]
        got = [[x["customer_id"], round(float(x["sales_excluding_tax"]), 2)] for x in (ranks[-1]["ranking"] if ranks else [])][:o["top_n"]]
        chk("tool_ranking_equals_snapshot_oracle", got == exp, {"tool": got, "oracle": exp})
        chk("tool_read_current_release", bool(ranks) and str(ranks[-1].get("version")) == rel[0] and ranks[-1].get("queried_object") == rel[2],
            {"tool_version": ranks[-1].get("version") if ranks else None, "tool_object": ranks[-1].get("queried_object") if ranks else None})
        chk("answer_reports_oracle_amounts", all(s in nums_in(text) for _, s in exp), None)
        chk("answer_names_version_or_object", rel[2] in text or re.search(rf"(?i)version\D{{0,6}}{rel[0]}\b", text) is not None)

    # Builder: claim-level citation support against retrieved content.
    if case.get("claims"):
        retrieved = {}
        for r in pres:
            for d in r.get("documents", []) or []:
                retrieved[d["doc_id"]] = d
                retrieved[d["source_path"]] = d
        for cl in case["claims"]:
            ev = cl.get("evidence_text_any") or [cl["evidence_text"]]
            cited = [d for d in cl["docs"] if d in text]
            supporting = [d for d in cited if d in retrieved and any(e in retrieved[d]["content"] for e in ev)]
            chk(f"claim_supported:{cl['claim']}", bool(supporting), {"cited": cited, "retrieved": [d for d in cl["docs"] if d in retrieved], "supporting": supporting})
    if case.get("check_cited_versions"):
        full = {h.lower() for h in HEX64.findall(text)}
        trunc = TRUNC.findall(text)
        bad = [h for h in full if h not in catalog_versions]
        bad += [f"{a}…{b}" for a, b in trunc if not any(v.startswith(a.lower()) and v.endswith(b.lower()) for v in catalog_versions)]
        chk("cited_versions_exist_in_catalog", not bad, {"full": len(full), "truncated": len(trunc), "unsupported": bad})
    for tool, mapping in (case.get("tool_numbers") or {}).items():
        rr = [r for r in pres if any(k in r for k in mapping)]
        for k, fact in mapping.items():
            v = rr[-1].get(k) if rr else None
            chk(f"tool_value:{k}", v is not None and abs(float(v) - FACTS[fact]) < 0.005, v)
    for key in case.get("answer_numbers", []):
        chk(f"answer_number:{key}", round(FACTS[key], 2) in nums_in(text), FACTS[key])

    # Registry-based contract checks.
    new_c = q(cur, """SELECT c.CANDIDATE_ID, c.RECIPE_ID, c.STATE, c.LATEST_VALIDATION_RUN_ID, c.RELEASED_VERSION
                      FROM HACKATHON_D2K_PREWORK.L2P.CANDIDATES c WHERE c.PROPOSED_AT >= %s ORDER BY c.PROPOSED_AT""", before["ts"])
    unchanged = before["current"] == after["current"] and before["n_releases"] == after["n_releases"]
    pc = case.get("postcondition")
    if pc == "release_unchanged":
        chk("contract:release_unchanged", unchanged, {"before": before["current"], "after": after["current"]})
    if case.get("negative_candidate"):
        nc = case["negative_candidate"]
        mine = [c for c in new_c if c[1] == nc["recipe"]]
        chk("negative:candidate_created_for_recipe", bool(mine), [list(map(str, c)) for c in new_c])
        for c in mine:
            res = dict(q(cur, "SELECT CHECK_NAME, STATUS FROM HACKATHON_D2K_PREWORK.L2P.CHECK_RESULTS WHERE RUN_ID = %s", c[3])) if c[3] else {}
            chk(f"negative:{c[0]}:state_FAILED", c[2] == "FAILED", c[2])
            chk(f"negative:{c[0]}:not_released", c[4] is None, c[4])
            for f in nc["must_fail_checks"]:
                chk(f"negative:{c[0]}:{f}=FAIL", res.get(f) == "FAIL", res.get(f))
            for f in nc.get("must_pass_checks", []):
                chk(f"negative:{c[0]}:{f}=PASS (totals alone insufficient)", res.get(f) == "PASS", res.get(f))
    if pc == "documented_versioning":
        released_now = [c for c in new_c if c[2] == "RELEASED"]
        chk("versioning:each_new_release_is_a_newly_validated_candidate",
            after["n_releases"] - before["n_releases"] == len(released_now) and all(c[1] == "DAILY_INVOICED_SALES_V1" for c in released_now),
            {"delta_releases": after["n_releases"] - before["n_releases"], "released_now": [list(map(str, c)) for c in released_now]})
        if released_now:
            chk("versioning:current_points_to_latest_new_release", after["current"][0][1] == released_now[-1][0], after["current"])
            chk("answer_reports_released_version", re.search(rf"(?i)version\D{{0,12}}{after['current'][0][0]}\b|V0*{after['current'][0][0]}\b", text) is not None)
        else:
            chk("versioning:no_release_means_release_unchanged", unchanged)
            flags.append("review: build run produced no new release")
    if pc == "no_invalid_release":
        bad = [c for c in new_c if c[2] == "RELEASED" and c[1] != "DAILY_INVOICED_SALES_V1"]
        chk("contract:no_invalid_release", not bad, [list(map(str, c)) for c in new_c])
    return checks, flags, [list(map(str, c)) for c in new_c], oracle_info


def main():
    sel = set(sys.argv[1:])
    tag = time.strftime("run_%Y%m%d_%H%M%S")
    out_dir = ROOT / "evidence" / "eval" / tag
    out_dir.mkdir(parents=True, exist_ok=True)
    conn = connect()
    cur = conn.cursor()
    cur.execute("USE WAREHOUSE DEFAULT_WH")
    cfg = {k: agent_config(cur, v) for k, v in AGENTS.items()}
    catalog_versions = {r[0].lower() for r in q(cur, "SELECT SOURCE_VERSION FROM HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG")}
    results = []
    for case in CASES["cases"]:
        if sel and case["id"] not in sel:
            continue
        for i in range(1, case.get("repeat", 1) + 1):
            rid = f"{case['id']}#{i}"
            before = state(cur)
            rec = ta.run(cur, rid.replace("#", "_r"), AGENTS[case["agent"]], case["prompt"], out_dir=out_dir)
            after = state(cur)
            checks, flags, new_cands, oracle = grade(cur, case, rec, before, after, catalog_versions)
            passed = all(c["pass"] for c in checks)
            results.append({"run_id": rid, "case": case["id"], "kind": case["kind"], "agent": case["agent"],
                            "model": cfg[case["agent"]]["model"], "agent_spec_sha256": cfg[case["agent"]]["spec_sha256"],
                            "elapsed_s": rec["elapsed_s"], "data_agent_run_query_id": rec["data_agent_run_query_id"],
                            "tools": [c["name"] for c in rec["tool_trace"] if c["kind"] == "tool_use"],
                            "tool_query_ids": sorted({x for c in rec["tool_trace"] if c["kind"] == "tool_result" for x in c.get("query_ids", [])}),
                            "skill_nodes": sum(1 for c in rec["tool_trace"] if c["kind"] == "skill_related_node"),
                            "release_before": before["current"], "release_after": after["current"], "oracle": oracle,
                            "new_candidates": new_cands, "pass": passed, "checks": checks, "review_flags": flags,
                            "manual_interventions": "none"})
            print(f"{rid}: {'PASS' if passed else 'FAIL'} {rec['elapsed_s']}s failed={[c['check'] for c in checks if not c['pass']]} flags={len(flags)}")
    by_case = {}
    for r in results:
        by_case.setdefault(r["case"], []).append(r["pass"])
    summary = {"suite": CASES["suite"], "grading_rules": CASES["grading_rules"], "run_tag": tag, "agents": cfg,
               "runs": len(results), "runs_passed": sum(r["pass"] for r in results),
               "cases": {k: {"runs": len(v), "passed": sum(v), "consistent": len(set(v)) == 1} for k, v in by_case.items()},
               "untested_agent_level": CASES["untested_agent_level"],
               "latency_s": {"min": min(r["elapsed_s"] for r in results), "max": max(r["elapsed_s"] for r in results),
                             "mean": round(sum(r["elapsed_s"] for r in results) / len(results), 1)} if results else None}
    (out_dir / "results.json").write_text(json.dumps({"summary": summary, "results": results}, indent=1, default=str), encoding="utf-8")
    lines = [f"# L2P agent evaluation {tag} (grader v2)", "", f"Agents: builder {cfg['builder']['model']} spec {cfg['builder']['spec_sha256'][:12]}, "
             f"consumer {cfg['consumer']['model']} spec {cfg['consumer']['spec_sha256'][:12]}", "",
             f"Runs: {summary['runs']}, passed: {summary['runs_passed']}", "",
             "| Case | Kind | Agent | Runs | Passed | Consistent | Mean s |", "|---|---|---|---|---|---|---|"]
    for k, v in summary["cases"].items():
        c = next(x for x in CASES["cases"] if x["id"] == k)
        rs = [r["elapsed_s"] for r in results if r["case"] == k]
        lines.append(f"| {k} | {c['kind']} | {c['agent']} | {v['runs']} | {v['passed']} | {v['consistent']} | {round(sum(rs)/len(rs),1)} |")
    lines += ["", "Untested at agent level: " + "; ".join(f"{u['case']} ({u['reason']})" for u in CASES["untested_agent_level"]), "",
              "## Failed checks", ""]
    for r in results:
        for c in r["checks"]:
            if not c["pass"]:
                lines.append(f"- {r['run_id']} {c['check']}: {json.dumps(c['detail'], default=str)[:300]}")
    lines += ["", "## Review flags (not failures)", ""]
    for r in results:
        for f in r["review_flags"]:
            lines.append(f"- {r['run_id']}: {f[:300]}")
    (out_dir / "summary.md").write_text("\n".join(lines), encoding="utf-8")
    print(json.dumps({k: summary[k] for k in ("run_tag", "runs", "runs_passed", "cases", "latency_s")}, indent=1, default=str))
    conn.close()


if __name__ == "__main__":
    main()
