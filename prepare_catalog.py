"""Build a small, explicitly synthetic report/code search corpus. No lineage engine."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DB = 'HACKATHON_D2K_PREWORK'
reports = [
    ('DAILY_INVOICE_SALES', 'Daily invoiced sales',
     'Synthetic sales report by invoice date. Revenue means invoiced sales excluding tax; invoice total includes tax. No currency is modeled. Days without invoices are omitted.',
     f'''SELECT i.INVOICEDATE AS SALES_DATE, COUNT(DISTINCT i.INVOICEID) AS INVOICE_COUNT,
 SUM(l.EXTENDEDPRICE-l.TAXAMOUNT) AS SALES_EXCLUDING_TAX,
 SUM(l.TAXAMOUNT) AS TAX, SUM(l.EXTENDEDPRICE) AS TOTAL_INCLUDING_TAX
FROM {DB}.RAW.INVOICES i
JOIN {DB}.RAW.INVOICELINES l ON l.INVOICEID=i.INVOICEID
GROUP BY i.INVOICEDATE'''),
    ('DAILY_ORDERED_SALES', 'Daily ordered sales',
     'Synthetic bookings report by order date. Ordered value excluding tax is quantity times unit price. It includes orders not yet invoiced; it is not recognized revenue. No cancellation, discount or currency logic is modeled.',
     f'''SELECT o.ORDERDATE AS ORDER_DATE, COUNT(DISTINCT o.ORDERID) AS ORDER_COUNT,
 SUM(ROUND(l.QUANTITY*l.UNITPRICE,2)) AS ORDERED_VALUE_EXCLUDING_TAX
FROM {DB}.RAW.ORDERS o
JOIN {DB}.RAW.ORDERLINES l ON l.ORDERID=o.ORDERID
GROUP BY o.ORDERDATE'''),
    ('CUSTOMER_INVOICE_SALES', 'Customer invoiced sales',
     'Synthetic customer sales report across all invoice dates. Customer identity is CUSTOMERID; customer name is a label. Sales excludes tax, invoice total includes tax. No currency is modeled.',
     f'''SELECT c.CUSTOMERID, c.CUSTOMERNAME, COUNT(DISTINCT i.INVOICEID) AS INVOICE_COUNT,
 SUM(l.EXTENDEDPRICE-l.TAXAMOUNT) AS SALES_EXCLUDING_TAX,
 SUM(l.TAXAMOUNT) AS TAX, SUM(l.EXTENDEDPRICE) AS TOTAL_INCLUDING_TAX
FROM {DB}.RAW.CUSTOMERS c
JOIN {DB}.RAW.INVOICES i ON i.CUSTOMERID=c.CUSTOMERID
JOIN {DB}.RAW.INVOICELINES l ON l.INVOICEID=i.INVOICEID
GROUP BY c.CUSTOMERID,c.CUSTOMERNAME'''),
]
out = ROOT / 'catalog'
out.mkdir(exist_ok=True)
docs = []
ddl = ['-- PREWORK: synthetic report fixtures and basic search only.', 'USE WAREHOUSE DEFAULT_WH;']
for key, title, description, sql in reports:
    file = out / (key.lower() + '.sql')
    definition = f'CREATE OR REPLACE VIEW {DB}.ANALYTICS.RPT_{key}\nCOMMENT=\'Synthetic prework report fixture; not a published business dashboard.\'\nAS\n{sql};\n'
    file.write_text(definition, encoding='utf-8')
    ddl.append(definition)
    docs.append(dict(id=key, title=title, kind='SYNTHETIC_REPORT', source='catalog/'+file.name,
                     version=hashlib.sha256(definition.encode()).hexdigest(),
                     text=f'{title}\n{description}\nArtifact: synthetic executable report fixture, not an actual BI dashboard.\n{definition}'))
manifest = json.loads((ROOT/'source/manifest.json').read_text(encoding='utf-8-sig'))
for item in manifest['files']:
    if not item['path'].endswith('.sql'):
        continue
    raw = (ROOT/'source'/item['path']).read_bytes()
    assert hashlib.sha256(raw).hexdigest().upper() == item['sha256']
    text = raw.decode('utf-8-sig')
    # Keep these short source files whole; no hidden truncation or omitted sections.
    docs.append(dict(id='WWI_'+hashlib.sha256(item['path'].encode()).hexdigest()[:16],
                     title='Public WWI reference: '+item['path'].split('wwi-ssdt/')[-1],
                     kind='PUBLIC_SQL_REFERENCE', source=item['url'], version=item['sha256'],
                     text='Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.\n'+text))
assert len(docs) == 15 and len({d['id'] for d in docs}) == 15
(out/'documents.json').write_text(json.dumps(docs, indent=2), encoding='utf-8')
def quote(s):
    return "'"+s.replace("'", "''")+"'"
ddl.append(f'''CREATE TABLE IF NOT EXISTS {DB}.ANALYTICS.T_PREWORK_CATALOG
 (DOC_ID VARCHAR, TITLE VARCHAR, ARTIFACT_TYPE VARCHAR, SOURCE_PATH VARCHAR, SOURCE_VERSION VARCHAR, CONTENT VARCHAR);''')
for d in docs:
    values = ','.join(quote(d[k]) for k in ['id','title','kind','source','version','text'])
    ddl.append(f'''MERGE INTO {DB}.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ({values})) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);''')
ddl.append(f'''CREATE CORTEX SEARCH SERVICE IF NOT EXISTS {DB}.ANALYTICS.CSS_PREWORK_CATALOG
 ON CONTENT ATTRIBUTES ARTIFACT_TYPE, DOC_ID
 WAREHOUSE=DEFAULT_WH TARGET_LAG='1 day'
 AS SELECT DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT
 FROM {DB}.ANALYTICS.T_PREWORK_CATALOG;''')
ddl.append(f'''SELECT 'REPORTS' AS CHECK_NAME, COUNT(*) AS ACTUAL FROM {DB}.ANALYTICS.T_PREWORK_CATALOG WHERE ARTIFACT_TYPE='SYNTHETIC_REPORT'
UNION ALL SELECT 'PUBLIC_SQL_FILES',COUNT(*) FROM {DB}.ANALYTICS.T_PREWORK_CATALOG WHERE ARTIFACT_TYPE='PUBLIC_SQL_REFERENCE';
SELECT SUM(INVOICE_COUNT) AS INVOICES,SUM(SALES_EXCLUDING_TAX) AS SALES_EXCLUDING_TAX,
 SUM(TAX) AS TAX,SUM(TOTAL_INCLUDING_TAX) AS TOTAL_INCLUDING_TAX
FROM {DB}.ANALYTICS.RPT_DAILY_INVOICE_SALES;''')
(ROOT/'03_catalog.sql').write_text('\n\n'.join(ddl), encoding='utf-8')
print(f'Prepared {len(reports)} report fixtures, {len(docs)} complete search documents; source hashes verified.')
