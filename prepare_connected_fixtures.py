"""Generate original synthetic cross-platform metadata and independent fixture checks.

No company assets, native platform deployment, lineage engine or agent workflow.
Run after prepare.py. Only fixtures/search_documents.json is eligible for indexing.
"""
import csv
import hashlib
import json
from collections import Counter, defaultdict
from decimal import Decimal
from pathlib import Path
import sqlite3
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'fixtures'
EVAL = ROOT / 'evaluation'
for directory in ['hana', 'qlik', 'spotfire', 'business']:
    (OUT / directory).mkdir(parents=True, exist_ok=True)
EVAL.mkdir(exist_ok=True)
DISCLAIMER = ('Original synthetic fixture. Fictional company: Northstar Supply. '
               'Not exported from or validated in HANA, Qlik or Spotfire. '
               'No company data or real BI dashboard is represented.')

def write(path, content):
    target = OUT / path
    target.write_text(content, encoding='utf-8')
    return target

def dump(path, obj):
    return write(path, json.dumps(obj, indent=2) + '\n')

invoice_sql = '''SELECT i.INVOICEID, l.INVOICELINEID, i.ORDERID, i.INVOICEDATE,
 c.CUSTOMERID, c.CUSTOMERNAME, p.STOCKITEMID, p.STOCKITEMNAME,
 l.QUANTITY, l.EXTENDEDPRICE - l.TAXAMOUNT AS INVOICED_SALES_EX_TAX,
 l.TAXAMOUNT AS INVOICE_TAX, l.EXTENDEDPRICE AS INVOICE_TOTAL_INCL_TAX
FROM INVOICELINES l
JOIN INVOICES i ON l.INVOICEID = i.INVOICEID
JOIN CUSTOMERS c ON i.CUSTOMERID = c.CUSTOMERID
JOIN STOCKITEMS p ON l.STOCKITEMID = p.STOCKITEMID'''
order_sql = '''SELECT o.ORDERID, l.ORDERLINEID, o.ORDERDATE,
 c.CUSTOMERID, c.CUSTOMERNAME, p.STOCKITEMID, p.STOCKITEMNAME,
 l.QUANTITY, ROUND(l.QUANTITY * l.UNITPRICE, 2) AS ORDERED_VALUE_EX_TAX
FROM ORDERLINES l
JOIN ORDERS o ON l.ORDERID = o.ORDERID
JOIN CUSTOMERS c ON o.CUSTOMERID = c.CUSTOMERID
JOIN STOCKITEMS p ON l.STOCKITEMID = p.STOCKITEMID'''

models = [
    ('CV_INVOICE_SALES', 'INVOICELINEID', invoice_sql,
     [('INVOICELINES','l'),('INVOICES','i'),('CUSTOMERS','c'),('STOCKITEMS','p')],
     [('l.INVOICEID','i.INVOICEID'),('i.CUSTOMERID','c.CUSTOMERID'),('l.STOCKITEMID','p.STOCKITEMID')]),
    ('CV_ORDER_SALES', 'ORDERLINEID', order_sql,
     [('ORDERLINES','l'),('ORDERS','o'),('CUSTOMERS','c'),('STOCKITEMS','p')],
     [('l.ORDERID','o.ORDERID'),('o.CUSTOMERID','c.CUSTOMERID'),('l.STOCKITEMID','p.STOCKITEMID')]),
]
# Normalized XML intentionally does NOT impersonate SAP's native .hdbcalculationview format.
for name, key, sql, tables, joins in models:
    root = ET.Element('SyntheticHanaModel', {
        'name':name, 'schema':'SYNTHETIC_SALES', 'sourceSystem':'SYNTHETIC_HANA',
        'format':'normalized-fixture-v1', 'nativeDeploymentValidated':'false',
        'grain':key, 'description':DISCLAIMER})
    sources = ET.SubElement(root,'DataSources')
    for table, alias in tables:
        ET.SubElement(sources,'Table',name=table,alias=alias)
    nodes = ET.SubElement(root,'Joins')
    for left, right in joins:
        ET.SubElement(nodes,'Join',left=left,right=right,type='inner',cardinality='many-to-one')
    ET.SubElement(root,'RelationalDefinition',dialect='portable SQL fixture').text=sql
    ET.indent(root)
    write('hana/'+name+'.model.xml', ET.tostring(root,encoding='unicode')+'\n')
    write('hana/'+name+'.sql', '-- '+DISCLAIMER+'\n-- SQL equivalent of the normalized model, not an SAP deployment artifact.\n'+sql+';\n')

qlik_script = '''// SYNTHETIC fixture; not executed in Qlik. Connection is a placeholder.
LIB CONNECT TO 'SYNTHETIC_HANA_CONNECTION';
SalesOrders:
LOAD ORDERID, ORDERLINEID, ORDERDATE AS SalesDate,
 CUSTOMERID, CUSTOMERNAME, STOCKITEMID, STOCKITEMNAME,
 QUANTITY, ORDERED_VALUE_EX_TAX AS SalesAmount;
SQL SELECT ORDERID, ORDERLINEID, ORDERDATE, CUSTOMERID, CUSTOMERNAME,
 STOCKITEMID, STOCKITEMNAME, QUANTITY, ORDERED_VALUE_EX_TAX
FROM "SYNTHETIC_SALES"."CV_ORDER_SALES";
'''
write('qlik/sales_performance.qvs', qlik_script)
dump('qlik/sales_performance.metadata.json', {
    'notice':DISCLAIMER, 'format':'normalized-fixture-v1', 'platform':'Qlik',
    'app_id':'SYN_QLIK_SALES', 'app_name':'Sales Performance',
    'description':'Customer sales bookings and monthly ordered value, excluding tax.',
    'load_script':'fixtures/qlik/sales_performance.qvs',
    'sheets':[{'id':'SYN_SHEET_ORDERS','name':'Monthly Sales',
               'charts':[{'id':'SYN_CHART_ORDERED','title':'Sales by month',
                          'dimension':'MonthStart(SalesDate)', 'measure':'Sum(SalesAmount)',
                          'measure_label':'Sales (ordered, excluding tax)'},
                         {'id':'SYN_CHART_CUSTOMER','title':'Customer sales',
                          'dimension':'CUSTOMERNAME','measure':'Sum(SalesAmount)'}]}],
    'filters':[], 'default_date_range':'all loaded dates', 'currency':None})

spot_sql = '''SELECT INVOICEID, INVOICELINEID, ORDERID, INVOICEDATE,
 CUSTOMERID, CUSTOMERNAME, STOCKITEMID, STOCKITEMNAME, QUANTITY,
 INVOICED_SALES_EX_TAX, INVOICE_TAX, INVOICE_TOTAL_INCL_TAX
FROM "SYNTHETIC_SALES"."CV_INVOICE_SALES";'''
write('spotfire/customer_sales.source.sql','-- '+DISCLAIMER+'\n'+spot_sql+'\n')
dump('spotfire/customer_sales.metadata.json', {
    'notice':DISCLAIMER,'format':'normalized-fixture-v1','platform':'Spotfire',
    'analysis_id':'SYN_SPOTFIRE_CUSTOMER','name':'Customer Sales',
    'description':'Invoiced sales by customer and invoice month, excluding tax.',
    'library_path':'/Synthetic/Finance/Customer Sales',
    'data_tables':[{'name':'InvoiceSales','source_sql':'fixtures/spotfire/customer_sales.source.sql',
                    'calculated_columns':[{'name':'SalesAmount','expression':'[INVOICED_SALES_EX_TAX]'}]}],
    'pages':[{'name':'Invoice Sales','visuals':[
        {'id':'SYN_VIZ_CUSTOMER','title':'Customer invoiced sales','data_table':'InvoiceSales',
         'category':'[CUSTOMERNAME]','value':'Sum([SalesAmount])'},
        {'id':'SYN_VIZ_MONTH','title':'Monthly invoiced sales','data_table':'InvoiceSales',
         'category':'<Year([INVOICEDATE]) NEST Month([INVOICEDATE])>','value':'Sum([SalesAmount])'}]}],
    'filters':[], 'default_date_range':'all loaded dates','currency':None})

write('business/definitions.md', '''# Northstar Supply: synthetic sales definitions

All data and report metadata are fictional. No real customer data is included.
The platform metadata is normalized fixture content, not native validated app exports.

- Ordered value: order-line quantity multiplied by unit price; order-date basis.
  Includes orders without invoices. This is a bookings measure, not recognized revenue.
- Invoiced sales: invoice-line ExtendedPrice minus TaxAmount; invoice-date basis.
  This simplified demo calls that revenue, without claiming accounting revenue recognition.
- ExtendedPrice includes tax in the synthetic invoice dataset.
- No currencies, discounts, returns or cancellations are modeled.
- Customers and products are shared between the two reporting paths.
- A product may belong to multiple stock groups. There is no designated primary group
  or approved allocation weighting. Group totals are therefore not necessarily additive.
- A proposed daily customer/product product must specify its date basis, tax treatment
  and grain. Do not silently substitute orders for invoices or invent missing dates.
- Qlik Sales Performance uses orders. Spotfire Customer Sales uses invoices.
  Both use all loaded dates and amounts excluding tax; differing tax treatment is not
  an explanation for a difference between these particular two synthetic reports.
''')

# Independent expected values from raw CSVs, never included in the searchable documents.
data = {f.stem.upper():list(csv.DictReader(f.open(encoding='utf-8')))
        for f in (ROOT/'data').glob('*.csv')}
orders = {r['ORDERID']:r for r in data['ORDERS']}
invoices = {r['INVOICEID']:r for r in data['INVOICES']}
invoiced_orders = {r['ORDERID'] for r in data['INVOICES']}
order_total = sum(Decimal(r['QUANTITY'])*Decimal(r['UNITPRICE']) for r in data['ORDERLINES'])
net = lambda r: Decimal(r['EXTENDEDPRICE'])-Decimal(r['TAXAMOUNT'])
invoice_total = sum(net(r) for r in data['INVOICELINES'])
unbilled = sum(Decimal(r['QUANTITY'])*Decimal(r['UNITPRICE'])
               for r in data['ORDERLINES'] if r['ORDERID'] not in invoiced_orders)
assert order_total-invoice_total == unbilled
group_counts = Counter(r['STOCKITEMID'] for r in data['STOCKITEMSTOCKGROUPS'])
joined_total = sum(net(r)*group_counts[r['STOCKITEMID']] for r in data['INVOICELINES'])
assert joined_total > invoice_total
monthly = defaultdict(lambda: {'ordered':Decimal(0),'invoiced':Decimal(0)})
expected_daily = defaultdict(lambda:Decimal(0))
for r in data['ORDERLINES']:
    monthly[orders[r['ORDERID']]['ORDERDATE'][:7]]['ordered'] += Decimal(r['QUANTITY'])*Decimal(r['UNITPRICE'])
for r in data['INVOICELINES']:
    invoice = invoices[r['INVOICEID']]
    monthly[invoice['INVOICEDATE'][:7]]['invoiced'] += net(r)
    expected_daily[(invoice['INVOICEDATE'],invoice['CUSTOMERID'],r['STOCKITEMID'])] += net(r)

# Execute both relational fixtures independently to catch missing/wrong joins and fanout.
conn = sqlite3.connect(':memory:')
for table, rows in data.items():
    cols = list(rows[0])
    conn.execute('CREATE TABLE '+table+' ('+','.join(c+(' TEXT' if 'DATE' in c or 'NAME' in c else ' NUMERIC') for c in cols)+')')
    conn.executemany('INSERT INTO '+table+' VALUES ('+','.join('?' for _ in cols)+')',[list(r.values()) for r in rows])
checks=[]
for name,key,sql,tables,joins in models:
    ET.parse(OUT/'hana'/(name+'.model.xml'))
    conn.execute('CREATE VIEW '+name+' AS '+sql)
    n,unique=conn.execute('SELECT COUNT(*),COUNT(DISTINCT '+key+') FROM '+name).fetchone()
    expected=len(data['INVOICELINES' if name=='CV_INVOICE_SALES' else 'ORDERLINES'])
    assert n==unique==expected, (name,n,unique,expected)
    checks.append({'check':name+' preserves unique source-line grain','rows':n,'passed':True})
for name,metric,expected in [('CV_ORDER_SALES','ORDERED_VALUE_EX_TAX',order_total),
                             ('CV_INVOICE_SALES','INVOICED_SALES_EX_TAX',invoice_total)]:
    observed=Decimal(str(conn.execute('SELECT SUM('+metric+') FROM '+name).fetchone()[0])).quantize(Decimal('.01'))
    assert observed==expected,(name,observed,expected)
    checks.append({'check':name+' matches independent CSV arithmetic','passed':True})
# Validate that report SQL/script fields resolve to their referenced model outputs.
outputs={name:{r[1] for r in conn.execute('PRAGMA table_info('+name+')')} for name,*_ in models}
import re
selected=re.search(r'SQL SELECT (.*?)\nFROM',qlik_script,re.S).group(1)
assert {x.strip() for x in selected.split(',')} <= outputs['CV_ORDER_SALES']
selected=spot_sql.split('SELECT ',1)[1].split('\nFROM',1)[0]
assert {x.strip() for x in selected.split(',')} <= outputs['CV_INVOICE_SALES']
checks.append({'check':'Both BI source projections reference existing fixture output columns','passed':True})

expected = {'notice':'Evaluation only. Never load this folder into agent search.',
            'ordered_sales_ex_tax':str(order_total),'invoiced_sales_ex_tax':str(invoice_total),
            'difference_uninvoiced_order_value':str(unbilled),
            'uninvoiced_order_count':len(set(orders)-invoiced_orders),
            'naive_stockgroup_join_total':str(joined_total),
            'double_counted_amount':str(joined_total-invoice_total),
            'daily_customer_product_groups':len(expected_daily),
            'monthly':{k:{m:str(v) for m,v in values.items()} for k,values in sorted(monthly.items())},
            'checks':checks}
(EVAL/'fixture-checks.json').write_text(json.dumps(expected,indent=2)+'\n',encoding='utf-8')
with (EVAL/'expected_daily_customer_product.csv').open('w',newline='',encoding='utf-8') as f:
    writer=csv.writer(f); writer.writerow(['INVOICE_DATE','CUSTOMERID','STOCKITEMID','SALES_EX_TAX'])
    for key,value in sorted(expected_daily.items()): writer.writerow([*key,str(value)])

assets=[]
documents=[]
for subdir in ['hana','qlik','spotfire','business']:
    for file in sorted((OUT/subdir).iterdir()):
        raw=file.read_bytes(); path=file.relative_to(ROOT).as_posix()
        asset={'path':path,'platform':subdir,'sha256':hashlib.sha256(raw).hexdigest(),
               'origin':'original synthetic authoring','native_platform_validation':False}
        assets.append(asset)
        documents.append({'id':'CONNECTED_'+hashlib.sha256(path.encode()).hexdigest()[:16],
                          'title':'Synthetic '+subdir+': '+file.name,
                          'kind':'SYNTHETIC_CONNECTED_METADATA','source':path,
                          'version':asset['sha256'],'text':DISCLAIMER+'\n'+raw.decode('utf-8')})
dump('source-register.json',{'notice':DISCLAIMER,'assets':assets,
                            'index_allowlist':[a['path'] for a in assets],
                            'excluded_from_index':['evaluation/','DEMO-SCENARIOS.md']})
dump('search_documents.json',documents)
assert all('evaluation/' not in d['source'] for d in documents)
def sql_quote(value):
    return "'"+value.replace('\\','\\\\').replace("'", "''")+"'"
load = ['-- Synthetic metadata only: evaluation answers explicitly excluded.', 'USE WAREHOUSE DEFAULT_WH;']
for d in documents:
    values=','.join(sql_quote(d[k]) for k in ['id','title','kind','source','version','text'])
    load.append('''MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('''+values+''')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES(s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);''')
load.append('ALTER CORTEX SEARCH SERVICE HACKATHON_D2K_PREWORK.ANALYTICS.CSS_PREWORK_CATALOG REFRESH;')
load.append('SELECT ARTIFACT_TYPE,COUNT(*) AS DOCUMENTS FROM HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG GROUP BY ARTIFACT_TYPE;')
(ROOT/'05_connected_metadata.sql').write_text('\n\n'.join(load),encoding='utf-8')
print(json.dumps({'assets':len(assets),'checks':len(checks),'ordered':str(order_total),
                  'invoiced':str(invoice_total),'gap':str(unbilled),
                  'naive_group_total':str(joined_total),'daily_groups':len(expected_daily)},indent=2))
