"""Pre-event dataset preparation only. No proprietary inputs or agent workflow."""
from pathlib import Path
import csv, json, random, hashlib
from decimal import Decimal, ROUND_HALF_UP
from datetime import date, timedelta

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'data'
OUT.mkdir(exist_ok=True)
rng = random.Random(231026)
def money(v):
    return Decimal(str(v)).quantize(Decimal('.01'), rounding=ROUND_HALF_UP)

# Simplified subset of the public WWI schemas; rows are independently synthetic.
spec = {
'CUSTOMERS': [('CUSTOMERID','NUMBER'),('CUSTOMERNAME','VARCHAR'),('BILLTOCUSTOMERID','NUMBER')],
'STOCKITEMS': [('STOCKITEMID','NUMBER'),('STOCKITEMNAME','VARCHAR'),('UNITPRICE','NUMBER(18,2)'),('TAXRATE','NUMBER(18,3)')],
'STOCKGROUPS': [('STOCKGROUPID','NUMBER'),('STOCKGROUPNAME','VARCHAR')],
'STOCKITEMSTOCKGROUPS': [('STOCKITEMSTOCKGROUPID','NUMBER'),('STOCKITEMID','NUMBER'),('STOCKGROUPID','NUMBER')],
'ORDERS': [('ORDERID','NUMBER'),('CUSTOMERID','NUMBER'),('ORDERDATE','DATE'),('EXPECTEDDELIVERYDATE','DATE')],
'ORDERLINES': [('ORDERLINEID','NUMBER'),('ORDERID','NUMBER'),('STOCKITEMID','NUMBER'),('QUANTITY','NUMBER'),('UNITPRICE','NUMBER(18,2)'),('TAXRATE','NUMBER(18,3)'),('PICKEDQUANTITY','NUMBER')],
'INVOICES': [('INVOICEID','NUMBER'),('CUSTOMERID','NUMBER'),('BILLTOCUSTOMERID','NUMBER'),('ORDERID','NUMBER'),('INVOICEDATE','DATE')],
'INVOICELINES': [('INVOICELINEID','NUMBER'),('INVOICEID','NUMBER'),('STOCKITEMID','NUMBER'),('QUANTITY','NUMBER'),('UNITPRICE','NUMBER(18,2)'),('TAXRATE','NUMBER(18,3)'),('TAXAMOUNT','NUMBER(18,2)'),('EXTENDEDPRICE','NUMBER(18,2)')],
}
rows = {k: [] for k in spec}
rows['CUSTOMERS'] = [(i,f'Fictional Customer {i:03d}',i) for i in range(1,21)]
rows['STOCKGROUPS'] = [(1,'Office'),(2,'Packaging'),(3,'Seasonal')]
for i in range(1,16):
    rows['STOCKITEMS'].append((i,f'Sample Product {i:03d}',money(rng.randint(300,8000)/100),Decimal('10.000')))
    rows['STOCKITEMSTOCKGROUPS'].append((len(rows['STOCKITEMSTOCKGROUPS'])+1,i,1+(i%2)))
    if i%4==0:
        rows['STOCKITEMSTOCKGROUPS'].append((len(rows['STOCKITEMSTOCKGROUPS'])+1,i,3))
for oid in range(1,121):
    cid=rng.randint(1,20)
    day=date(2026,1,1)+timedelta(days=rng.randrange(60))
    rows['ORDERS'].append((oid,cid,day,day+timedelta(days=3)))
    invoiced=oid%5!=0
    iid=len(rows['INVOICES'])+1
    if invoiced:
        rows['INVOICES'].append((iid,cid,cid,oid,day+timedelta(days=2)))
    for sid in rng.sample(range(1,16),rng.randint(1,4)):
        price=rows['STOCKITEMS'][sid-1][2]
        qty=rng.randint(1,8)
        picked=qty if invoiced else 0
        rows['ORDERLINES'].append((len(rows['ORDERLINES'])+1,oid,sid,qty,price,Decimal('10.000'),picked))
        if invoiced:
            tax=money(qty*price/10)
            rows['INVOICELINES'].append((len(rows['INVOICELINES'])+1,iid,sid,qty,price,Decimal('10.000'),tax,money(qty*price+tax)))

checks=[]
for table, values in rows.items():
    assert len({v[0] for v in values})==len(values),table
    assert all(len(v)==len(spec[table]) for v in values),table
    checks.append(f'{table}: unique non-null primary key and row shape')
for child,idx,parent in [('CUSTOMERS',2,'CUSTOMERS'),('STOCKITEMSTOCKGROUPS',1,'STOCKITEMS'),('STOCKITEMSTOCKGROUPS',2,'STOCKGROUPS'),('ORDERS',1,'CUSTOMERS'),('ORDERLINES',1,'ORDERS'),('ORDERLINES',2,'STOCKITEMS'),('INVOICES',1,'CUSTOMERS'),('INVOICES',2,'CUSTOMERS'),('INVOICES',3,'ORDERS'),('INVOICELINES',1,'INVOICES'),('INVOICELINES',2,'STOCKITEMS')]:
    keys={v[0] for v in rows[parent]}
    assert all(v[idx] in keys for v in rows[child]),(child,parent)
    checks.append(f'{child}[{idx}] -> {parent}: no orphan keys')
assert all(v[7]==money(v[3]*v[4]+v[6]) for v in rows['INVOICELINES'])
checks.append('Invoice extended price = quantity * unit price + tax (WWI source formula)')
def literal(v):
    if isinstance(v,(str,date)): return "'"+str(v).replace("'","''")+"'"
    return str(v)
sql=["-- PREWORK: public-schema adaptation + independently synthetic rows.",
"-- One-time creation intentionally fails if this isolated database already exists.",
"CREATE DATABASE HACKATHON_D2K_PREWORK COMMENT='Pre-event baseline. Public WWI schema subset; synthetic rows. No proprietary assets.';",
"CREATE SCHEMA HACKATHON_D2K_PREWORK.RAW;", "USE SCHEMA HACKATHON_D2K_PREWORK.RAW;", "USE WAREHOUSE DEFAULT_WH;"]
manifest={}
for table,values in rows.items():
    file=OUT/(table.lower()+'.csv')
    with file.open('w',newline='',encoding='utf-8') as f:
        w=csv.writer(f);w.writerow([x[0] for x in spec[table]]);w.writerows(values)
    manifest[table]={'rows':len(values),'sha256':hashlib.sha256(file.read_bytes()).hexdigest()}
    sql.append('CREATE TABLE '+table+' ('+', '.join(n+' '+t+' NOT NULL' for n,t in spec[table])+") COMMENT='Simplified WWI-compatible sample schema; independently generated synthetic rows, seed 231026';")
    sql.append('INSERT INTO '+table+' VALUES\n'+',\n'.join('('+','.join(literal(v) for v in row)+')' for row in values)+';')
sql.append("SELECT 'CUSTOMERS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM CUSTOMERS"+''.join(" UNION ALL SELECT '"+t+"',COUNT(*) FROM "+t for t in list(rows)[1:])+";")
(ROOT/'01_load.sql').write_text('\n\n'.join(sql),encoding='utf-8')
result={'seed':231026,'source_rows':'independently synthetic, not Microsoft exported records','tables':manifest,'checks_passed':checks,'invoice_sales_excluding_tax':str(sum(v[7]-v[6] for v in rows['INVOICELINES'])),'invoice_tax':str(sum(v[6] for v in rows['INVOICELINES'])),'invoice_total_including_tax':str(sum(v[7] for v in rows['INVOICELINES']))}
(ROOT/'validation.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps(result,indent=2))
