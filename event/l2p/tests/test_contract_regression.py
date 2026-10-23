"""EVENT-BUILT L2P regression harness (direct procedure calls; NOT evidence of agent orchestration).

Runs scenarios B-E from the build spec through the controlled procedures only, and saves
results to event/l2p/evidence/regression_results.json. Independent verification queries read
the release snapshot sources directly, never the candidate transformation.
"""
import json
import time
from pathlib import Path

from run_sql import connect, ROOT

OUT = ROOT / "evidence" / "regression_results.json"
results = []


def call(cur, sql, label):
    t0 = time.time()
    cur.execute(sql)
    row = cur.fetchone()
    qid = cur.sfqid
    val = row[0] if row else None
    try:
        val = json.loads(val)
    except (TypeError, ValueError):
        pass
    rec = {"step": label, "sql": sql, "query_id": qid, "elapsed_s": round(time.time() - t0, 2), "result": val}
    results.append(rec)
    return val


def expect(label, cond, detail=None):
    results.append({"assert": label, "passed": bool(cond), "detail": detail})
    print(("PASS " if cond else "FAIL ") + label)
    return cond


def build(cur, recipe, tag):
    p = call(cur, f"CALL HACKATHON_D2K_PREWORK.L2P.PROPOSE_CANDIDATE('{recipe}')", f"{tag}: propose {recipe}")
    cid = p["candidate_id"]
    c = call(cur, f"CALL HACKATHON_D2K_PREWORK.L2P.CREATE_CANDIDATE('{cid}')", f"{tag}: create")
    v = call(cur, f"CALL HACKATHON_D2K_PREWORK.L2P.VALIDATE_CANDIDATE('{cid}')", f"{tag}: validate")
    r = call(cur, f"CALL HACKATHON_D2K_PREWORK.L2P.RELEASE_CANDIDATE('{cid}')", f"{tag}: release attempt")
    return cid, c, v, r


def consumer(cur, tag):
    d = call(cur, "CALL HACKATHON_D2K_PREWORK.L2P_CONSUMER.DISCOVER_RELEASED_PRODUCT()", f"{tag}: consumer discover")
    k = call(cur, "CALL HACKATHON_D2K_PREWORK.L2P_CONSUMER.RANK_CUSTOMERS_BY_SALES(5, NULL, NULL)", f"{tag}: consumer rank top 5")
    return d, k


def main():
    conn = connect()
    cur = conn.cursor()
    cur.execute("USE WAREHOUSE DEFAULT_WH")
    started = time.strftime("%Y-%m-%dT%H:%M:%S%z")

    # E (missing product): before any release, discovery must return nothing.
    d0, k0 = consumer(cur, "E0 pre-release")
    pre_existing = d0.get("available")
    if not pre_existing:
        expect("Discovery returns no product before first passing release", d0.get("available") is False, d0)
        expect("Ranking refuses before first release", k0.get("error") == "NO_RELEASED_PRODUCT", k0)
    else:
        results.append({"note": "A release already existed at harness start; pre-release check recorded as not applicable on this run", "discover": d0})

    # B: stock-group fanout must fail, stay unreleased and invisible to consumer.
    cid_b, c_b, v_b, r_b = build(cur, "STOCKGROUP_FANOUT_DEMO", "B fanout")
    expect("B fanout candidate FAILED validation", v_b.get("state") == "FAILED", v_b.get("failed_checks"))
    expect("B fanout flagged multiplied lines (LINE_COVERAGE, GROUPED_RECONCILIATION, TOTAL_RECONCILIATION)",
           all(x in (v_b.get("failed_checks") or []) for x in ["LINE_COVERAGE", "GROUPED_RECONCILIATION", "TOTAL_RECONCILIATION"]), v_b.get("failed_checks"))
    expect("B fanout release rejected", r_b.get("ok") is False and r_b.get("error") == "NOT_VALIDATED", r_b)
    if not pre_existing:
        d_b, _ = consumer(cur, "B after fanout")
        expect("B consumer still sees no product", d_b.get("available") is False, d_b)

    # E (omission): single-group recipe drops lines.
    cid_o, _, v_o, r_o = build(cur, "SINGLE_GROUP_OMISSION_DEMO", "E omission")
    expect("E omission candidate FAILED", v_o.get("state") == "FAILED", v_o.get("failed_checks"))
    expect("E omission flagged dropped lines in LINE_COVERAGE", "LINE_COVERAGE" in (v_o.get("failed_checks") or []), v_o.get("failed_checks"))
    expect("E omission release rejected", r_o.get("ok") is False, r_o)

    # E (totals-match trap): order-date basis keeps totals but breaks grouping.
    cid_t, _, v_t, r_t = build(cur, "ORDER_DATE_BASIS_DEMO", "E order-date basis")
    checks_t = {c["check"]: c["status"] for c in v_t.get("checks", [])}
    expect("E order-date: TOTAL_RECONCILIATION passes (totals alone look fine)", checks_t.get("TOTAL_RECONCILIATION") == "PASS", checks_t)
    expect("E order-date: GROUPED_RECONCILIATION fails", checks_t.get("GROUPED_RECONCILIATION") == "FAIL", checks_t)
    expect("E order-date candidate FAILED and not released", v_t.get("state") == "FAILED" and r_t.get("ok") is False, r_t)

    # C: correct candidate passes and releases.
    cid_c, c_c, v_c, r_c = build(cur, "DAILY_INVOICED_SALES_V1", "C correct")
    expect("C correct candidate VALIDATED with 11/11 checks", v_c.get("state") == "VALIDATED" and v_c.get("checks_passed") == 11, v_c.get("failed_checks"))
    expect("C correct candidate RELEASED", r_c.get("ok") is True and r_c.get("state") == "RELEASED", r_c)
    rel_ver, rel_obj = r_c.get("released_version"), r_c.get("release_object")
    d_c, k_c = consumer(cur, "C after release")
    expect("C consumer discovers released version", d_c.get("available") is True and d_c.get("version") == rel_ver, d_c.get("version"))
    expect("C consumer ranking read the released object", k_c.get("queried_object") == rel_obj and k_c.get("version") == rel_ver, k_c.get("queried_object"))

    # Independent verification of the ranking from the candidate's source snapshot (not the release table).
    snap = r_c.get("snapshot_id")
    p = f"HACKATHON_D2K_PREWORK.L2P_STAGE.SNAP_{snap}_"
    cur.execute(f"""SELECT h.CUSTOMERID, SUM(l.EXTENDEDPRICE) - SUM(l.TAXAMOUNT) AS S
                    FROM {p}INVOICELINES l JOIN {p}INVOICES h ON h.INVOICEID = l.INVOICEID
                    GROUP BY 1 ORDER BY S DESC, 1 LIMIT 5""")
    indep = [[int(a), float(b)] for a, b in cur.fetchall()]
    results.append({"step": "C independent ranking from snapshot sources", "query_id": cur.sfqid, "result": indep})
    agent_rank = [[x["customer_id"], float(x["sales_excluding_tax"])] for x in k_c.get("ranking", [])][:5]
    expect("C consumer ranking equals independent snapshot ranking", agent_rank == indep, {"consumer": agent_rank, "independent": indep})
    cur.execute("SELECT SUM(EXTENDEDPRICE - TAXAMOUNT) FROM HACKATHON_D2K_PREWORK.RAW.INVOICELINES")
    raw_total = float(cur.fetchone()[0])
    cur.execute(f"SELECT SUM(SALES_EXCLUDING_TAX), COUNT(*) FROM {rel_obj}")
    rel_total, rel_rows = cur.fetchone()
    expect("C release total equals live RAW baseline 53589.47", abs(float(rel_total) - raw_total) < 0.005 and abs(raw_total - 53589.47) < 0.005, [float(rel_total), raw_total])
    expect("C release row count equals expected grain 241", int(rel_rows) == 241, int(rel_rows))

    # E: repeated release of the same candidate does not create a new version.
    rr = call(cur, f"CALL HACKATHON_D2K_PREWORK.L2P.RELEASE_CANDIDATE('{cid_c}')", "E repeated release")
    expect("E repeated release rejected as ALREADY_RELEASED", rr.get("error") == "ALREADY_RELEASED" and rr.get("released_version") == rel_ver, rr)

    # D: another bad candidate after the good release leaves release and consumer output unchanged.
    cid_d, _, v_d, r_d = build(cur, "STOCKGROUP_FANOUT_DEMO", "D fanout after release")
    d_d, k_d = consumer(cur, "D after second bad candidate")
    expect("D bad candidate FAILED and not released", v_d.get("state") == "FAILED" and r_d.get("ok") is False, r_d)
    expect("D current release unchanged", d_d.get("version") == rel_ver and d_d.get("release_object") == rel_obj, d_d.get("version"))
    expect("D consumer ranking unchanged", k_d.get("ranking") == k_c.get("ranking"), None)

    # E: candidate mutated after validation must be refused at release.
    p_m = call(cur, "CALL HACKATHON_D2K_PREWORK.L2P.PROPOSE_CANDIDATE('DAILY_INVOICED_SALES_V1')", "E mutation: propose")
    cid_m = p_m["candidate_id"]
    call(cur, f"CALL HACKATHON_D2K_PREWORK.L2P.CREATE_CANDIDATE('{cid_m}')", "E mutation: create")
    v_m = call(cur, f"CALL HACKATHON_D2K_PREWORK.L2P.VALIDATE_CANDIDATE('{cid_m}')", "E mutation: validate")
    expect("E mutation candidate validated before tamper", v_m.get("state") == "VALIDATED", v_m.get("failed_checks"))
    cur.execute(f"UPDATE HACKATHON_D2K_PREWORK.L2P_STAGE.CAND_{cid_m} SET SALES_EXCLUDING_TAX = SALES_EXCLUDING_TAX + 1 WHERE CUSTOMER_ID = (SELECT MIN(CUSTOMER_ID) FROM HACKATHON_D2K_PREWORK.L2P_STAGE.CAND_{cid_m})")
    results.append({"step": "E mutation: owner tampers candidate table after validation (test harness only)", "query_id": cur.sfqid, "rows": cur.rowcount})
    r_m = call(cur, f"CALL HACKATHON_D2K_PREWORK.L2P.RELEASE_CANDIDATE('{cid_m}')", "E mutation: release attempt")
    expect("E mutated candidate release rejected CHANGED_AFTER_VALIDATION", r_m.get("error") == "CHANGED_AFTER_VALIDATION", r_m)
    d_m, k_m = consumer(cur, "E after mutation attempt")
    expect("E release still the original version after mutation attempt", d_m.get("version") == rel_ver and k_m.get("ranking") == k_c.get("ranking"), d_m.get("version"))

    # E: unknown candidate, malformed ID, unsupported recipe, out-of-order state.
    u = call(cur, "CALL HACKATHON_D2K_PREWORK.L2P.RELEASE_CANDIDATE('C99999_DEADBEEF')", "E unknown candidate release")
    expect("E unknown candidate rejected", u.get("error") == "UNKNOWN_CANDIDATE", u)
    inj = call(cur, "CALL HACKATHON_D2K_PREWORK.L2P.VALIDATE_CANDIDATE('X; DROP TABLE L2P.RELEASES')", "E malformed/injection-shaped candidate ID")
    expect("E malformed candidate ID rejected by format check", inj.get("error") == "INVALID_CANDIDATE_ID_FORMAT", inj)
    bad = call(cur, "CALL HACKATHON_D2K_PREWORK.L2P.PROPOSE_CANDIDATE('RAW.INVOICELINES')", "E unsupported recipe / object name")
    expect("E unsupported recipe rejected", bad.get("error") == "UNSUPPORTED_RECIPE", bad)
    p_s = call(cur, "CALL HACKATHON_D2K_PREWORK.L2P.PROPOSE_CANDIDATE('DAILY_INVOICED_SALES_V1')", "E skip-validation: propose")
    sk = call(cur, f"CALL HACKATHON_D2K_PREWORK.L2P.RELEASE_CANDIDATE('{p_s['candidate_id']}')", "E skip-validation: release a PROPOSED candidate")
    expect("E releasing an unvalidated candidate rejected", sk.get("error") == "NOT_VALIDATED", sk)
    re_c = call(cur, f"CALL HACKATHON_D2K_PREWORK.L2P.CREATE_CANDIDATE('{cid_c}')", "E re-create a released candidate")
    expect("E re-create of released candidate rejected", re_c.get("error") == "INVALID_STATE", re_c)

    cur.execute("SELECT COUNT(*) FROM HACKATHON_D2K_PREWORK.L2P.RELEASES WHERE IS_CURRENT")
    expect("Exactly one current release", cur.fetchone()[0] == 1)

    summary = {"harness": "direct procedure regression (not agent orchestration)", "started": started,
               "finished": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
               "asserts_passed": sum(1 for r in results if r.get("assert") and r["passed"]),
               "asserts_failed": sum(1 for r in results if r.get("assert") and not r["passed"]),
               "release": {"version": rel_ver, "object": rel_obj, "candidate_id": cid_c},
               "candidates": {"B_fanout": cid_b, "E_omission": cid_o, "E_order_date": cid_t, "C_correct": cid_c, "D_fanout": cid_d, "E_mutation": cid_m}}
    OUT.write_text(json.dumps({"summary": summary, "results": results}, indent=1, default=str), encoding="utf-8")
    print(json.dumps(summary, indent=1))
    conn.close()


if __name__ == "__main__":
    main()
