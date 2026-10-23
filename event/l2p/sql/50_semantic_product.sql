-- EVENT-BUILT: explicit contract verification and a fail-closed semantic source.
USE DATABASE HACKATHON_D2K_PREWORK;
USE WAREHOUSE DEFAULT_WH;
CREATE OR REPLACE PROCEDURE L2P_CONSUMER.VERIFY_RELEASED_CONTRACT()
RETURNS VARCHAR LANGUAGE PYTHON RUNTIME_VERSION='3.11'
PACKAGES=('snowflake-snowpark-python') HANDLER='verify' EXECUTE AS OWNER AS
$$
import json,re
def verify(s):
    rows=s.sql("SELECT * FROM HACKATHON_D2K_PREWORK.L2P.RELEASES WHERE PRODUCT='DAILY_INVOICED_SALES' AND IS_CURRENT").collect()
    if len(rows)!=1:return json.dumps({'ok':False,'error':'NO_UNIQUE_CURRENT_RELEASE'})
    r=rows[0].as_dict(); obj=r['RELEASE_OBJECT']
    if not re.fullmatch(r'HACKATHON_D2K_PREWORK\.L2P_RELEASE\.DAILY_INVOICED_SALES_V[0-9]+',obj):return json.dumps({'ok':False,'error':'INVALID_POINTER'})
    checks=[x.as_dict() for x in s.sql('SELECT CHECK_NAME,STATUS FROM HACKATHON_D2K_PREWORK.L2P.CHECK_RESULTS WHERE RUN_ID=?',params=[r['VALIDATION_RUN_ID']]).collect()]
    required={'SNAPSHOT_UNCHANGED','SCHEMA_EXACT','KEYS_NOT_NULL','GRAIN_UNIQUE','REFERENTIAL_INTEGRITY','LINE_COVERAGE','ROW_COUNT_MATCH','GROUPED_RECONCILIATION','TOTAL_RECONCILIATION','DIMENSION_CONSISTENCY','SCOPE_CONSISTENCY'}
    passed={x['CHECK_NAME'] for x in checks if x['STATUS']=='PASS'}
    good=len(checks)==11 and passed==required
    h=s.sql('SELECT HASH_AGG(*)::VARCHAR H, COUNT(*) N FROM '+obj).collect()[0]
    intact=h['H']==r['CONTENT_HASH'] and h['N']==r['ROW_COUNT']
    return json.dumps({'ok':good and intact,'product':r['PRODUCT'],'version':r['VERSION'],'release_object':obj,'validation_run_id':r['VALIDATION_RUN_ID'],'contract_version':1,'contract_checks':checks,'recorded_contract_passed':good,'release_hash_matches':intact,'row_count':h['N'],'semantic_view':'HACKATHON_D2K_PREWORK.L2P_CONSUMER.DAILY_SALES_SEMANTIC','scope':'Recorded contract results plus current release integrity; not a rerun of source reconciliation.'},default=str)
$$;

CREATE OR REPLACE PROCEDURE L2P.PUBLISH_RELEASED_SEMANTIC_PRODUCT()
RETURNS VARCHAR LANGUAGE PYTHON RUNTIME_VERSION='3.11'
PACKAGES=('snowflake-snowpark-python') HANDLER='publish' EXECUTE AS OWNER AS
$$
import json
def publish(s):
    check=json.loads(s.call('HACKATHON_D2K_PREWORK.L2P_CONSUMER.VERIFY_RELEASED_CONTRACT'))
    if not check.get('ok'):return json.dumps({'ok':False,'error':'RELEASE_CONTRACT_OR_INTEGRITY_FAILED','check':check})
    obj=check['release_object']; ver=int(check['version'])
    # The source goes empty if this release is superseded, modified, or loses its passing checks.
    sql=f'''CREATE OR REPLACE SECURE VIEW HACKATHON_D2K_PREWORK.L2P_CONSUMER.CURRENT_SALES_GUARDED AS
      SELECT d.*, {ver}::NUMBER AS RELEASE_VERSION FROM {obj} d
      WHERE EXISTS (SELECT 1 FROM HACKATHON_D2K_PREWORK.L2P.RELEASES r
       JOIN HACKATHON_D2K_PREWORK.L2P.VALIDATION_RUNS v ON v.RUN_ID=r.VALIDATION_RUN_ID
       WHERE r.PRODUCT='DAILY_INVOICED_SALES' AND r.IS_CURRENT AND r.VERSION={ver}
         AND v.OVERALL_STATUS='PASS' AND v.CHECKS_PASSED=11 AND v.CHECKS_FAILED=0
         AND r.CONTENT_HASH=(SELECT HASH_AGG(*)::VARCHAR FROM {obj})
         AND (SELECT COUNT(*) FROM HACKATHON_D2K_PREWORK.L2P.CHECK_RESULTS c
              WHERE c.RUN_ID=r.VALIDATION_RUN_ID AND c.STATUS='PASS')=11)'''
    s.sql(sql).collect()
    s.sql('''CREATE OR REPLACE SEMANTIC VIEW HACKATHON_D2K_PREWORK.L2P_CONSUMER.DAILY_SALES_SEMANTIC
      TABLES (sales AS HACKATHON_D2K_PREWORK.L2P_CONSUMER.CURRENT_SALES_GUARDED
       PRIMARY KEY (INVOICE_DATE,CUSTOMER_ID,STOCK_ITEM_ID)
       COMMENT='Synthetic Northstar Supply; released daily invoice sales, guarded by current release and content hash.')
      DIMENSIONS (
       sales.invoice_date AS INVOICE_DATE,
       sales.customer_id AS CUSTOMER_ID,
       sales.customer_name AS CUSTOMER_NAME,
       sales.stock_item_id AS STOCK_ITEM_ID,
       sales.stock_item_name AS STOCK_ITEM_NAME,
       sales.release_version AS RELEASE_VERSION)
      METRICS (
       sales.invoiced_sales_excluding_tax AS SUM(SALES_EXCLUDING_TAX)
        COMMENT='Sum of invoice-line ExtendedPrice minus TaxAmount. No currency is modeled.',
       sales.invoice_lines AS SUM(INVOICE_LINE_COUNT),
       sales.units_invoiced AS SUM(QUANTITY),
       sales.tax AS SUM(TAX_AMOUNT),
       sales.invoiced_sales_including_tax AS SUM(TOTAL_INCLUDING_TAX))
      COMMENT='Contract v1: invoice date/customer/item. No consent, margin, campaign response, causal uplift, returns, discounts or calendar zero-fill. Empty means unavailable or superseded, never zero sales.' ''').collect()
    check['semantic_published']=True
    check['guarded_source']='HACKATHON_D2K_PREWORK.L2P_CONSUMER.CURRENT_SALES_GUARDED'
    return json.dumps(check)
$$;
