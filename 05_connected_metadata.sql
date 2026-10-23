-- Synthetic metadata only: evaluation answers explicitly excluded.

USE WAREHOUSE DEFAULT_WH;

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('CONNECTED_c321fb5572f5ed86','Synthetic hana: CV_INVOICE_SALES.model.xml','SYNTHETIC_CONNECTED_METADATA','fixtures/hana/CV_INVOICE_SALES.model.xml','d33d0ec9211725e359b399623b46396df45aca42fac9800473bebb08cc061ce3','Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
<SyntheticHanaModel name="CV_INVOICE_SALES" schema="SYNTHETIC_SALES" sourceSystem="SYNTHETIC_HANA" format="normalized-fixture-v1" nativeDeploymentValidated="false" grain="INVOICELINEID" description="Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.">
  <DataSources>
    <Table name="INVOICELINES" alias="l" />
    <Table name="INVOICES" alias="i" />
    <Table name="CUSTOMERS" alias="c" />
    <Table name="STOCKITEMS" alias="p" />
  </DataSources>
  <Joins>
    <Join left="l.INVOICEID" right="i.INVOICEID" type="inner" cardinality="many-to-one" />
    <Join left="i.CUSTOMERID" right="c.CUSTOMERID" type="inner" cardinality="many-to-one" />
    <Join left="l.STOCKITEMID" right="p.STOCKITEMID" type="inner" cardinality="many-to-one" />
  </Joins>
  <RelationalDefinition dialect="portable SQL fixture">SELECT i.INVOICEID, l.INVOICELINEID, i.ORDERID, i.INVOICEDATE,
 c.CUSTOMERID, c.CUSTOMERNAME, p.STOCKITEMID, p.STOCKITEMNAME,
 l.QUANTITY, l.EXTENDEDPRICE - l.TAXAMOUNT AS INVOICED_SALES_EX_TAX,
 l.TAXAMOUNT AS INVOICE_TAX, l.EXTENDEDPRICE AS INVOICE_TOTAL_INCL_TAX
FROM INVOICELINES l
JOIN INVOICES i ON l.INVOICEID = i.INVOICEID
JOIN CUSTOMERS c ON i.CUSTOMERID = c.CUSTOMERID
JOIN STOCKITEMS p ON l.STOCKITEMID = p.STOCKITEMID</RelationalDefinition>
</SyntheticHanaModel>
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES(s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('CONNECTED_6f53633c096a6b56','Synthetic hana: CV_INVOICE_SALES.sql','SYNTHETIC_CONNECTED_METADATA','fixtures/hana/CV_INVOICE_SALES.sql','a6c9df764b8ddc66665021280bf87770130becbbb10d52e1796768f78a84fd3d','Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
-- Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
-- SQL equivalent of the normalized model, not an SAP deployment artifact.
SELECT i.INVOICEID, l.INVOICELINEID, i.ORDERID, i.INVOICEDATE,
 c.CUSTOMERID, c.CUSTOMERNAME, p.STOCKITEMID, p.STOCKITEMNAME,
 l.QUANTITY, l.EXTENDEDPRICE - l.TAXAMOUNT AS INVOICED_SALES_EX_TAX,
 l.TAXAMOUNT AS INVOICE_TAX, l.EXTENDEDPRICE AS INVOICE_TOTAL_INCL_TAX
FROM INVOICELINES l
JOIN INVOICES i ON l.INVOICEID = i.INVOICEID
JOIN CUSTOMERS c ON i.CUSTOMERID = c.CUSTOMERID
JOIN STOCKITEMS p ON l.STOCKITEMID = p.STOCKITEMID;
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES(s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('CONNECTED_c1d6c7f4b37882cd','Synthetic hana: CV_ORDER_SALES.model.xml','SYNTHETIC_CONNECTED_METADATA','fixtures/hana/CV_ORDER_SALES.model.xml','b2d9a0cf0e09571bbb90293129dd0804a1ccd80ea168378ab3f7d52e78e8684a','Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
<SyntheticHanaModel name="CV_ORDER_SALES" schema="SYNTHETIC_SALES" sourceSystem="SYNTHETIC_HANA" format="normalized-fixture-v1" nativeDeploymentValidated="false" grain="ORDERLINEID" description="Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.">
  <DataSources>
    <Table name="ORDERLINES" alias="l" />
    <Table name="ORDERS" alias="o" />
    <Table name="CUSTOMERS" alias="c" />
    <Table name="STOCKITEMS" alias="p" />
  </DataSources>
  <Joins>
    <Join left="l.ORDERID" right="o.ORDERID" type="inner" cardinality="many-to-one" />
    <Join left="o.CUSTOMERID" right="c.CUSTOMERID" type="inner" cardinality="many-to-one" />
    <Join left="l.STOCKITEMID" right="p.STOCKITEMID" type="inner" cardinality="many-to-one" />
  </Joins>
  <RelationalDefinition dialect="portable SQL fixture">SELECT o.ORDERID, l.ORDERLINEID, o.ORDERDATE,
 c.CUSTOMERID, c.CUSTOMERNAME, p.STOCKITEMID, p.STOCKITEMNAME,
 l.QUANTITY, ROUND(l.QUANTITY * l.UNITPRICE, 2) AS ORDERED_VALUE_EX_TAX
FROM ORDERLINES l
JOIN ORDERS o ON l.ORDERID = o.ORDERID
JOIN CUSTOMERS c ON o.CUSTOMERID = c.CUSTOMERID
JOIN STOCKITEMS p ON l.STOCKITEMID = p.STOCKITEMID</RelationalDefinition>
</SyntheticHanaModel>
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES(s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('CONNECTED_d8398680328033bb','Synthetic hana: CV_ORDER_SALES.sql','SYNTHETIC_CONNECTED_METADATA','fixtures/hana/CV_ORDER_SALES.sql','1f197fd3d2da50b70767619a1088fd0b7835501688a40efc73ca7e98fd0a3002','Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
-- Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
-- SQL equivalent of the normalized model, not an SAP deployment artifact.
SELECT o.ORDERID, l.ORDERLINEID, o.ORDERDATE,
 c.CUSTOMERID, c.CUSTOMERNAME, p.STOCKITEMID, p.STOCKITEMNAME,
 l.QUANTITY, ROUND(l.QUANTITY * l.UNITPRICE, 2) AS ORDERED_VALUE_EX_TAX
FROM ORDERLINES l
JOIN ORDERS o ON l.ORDERID = o.ORDERID
JOIN CUSTOMERS c ON o.CUSTOMERID = c.CUSTOMERID
JOIN STOCKITEMS p ON l.STOCKITEMID = p.STOCKITEMID;
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES(s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('CONNECTED_c09c9d6a14cfbebb','Synthetic qlik: sales_performance.metadata.json','SYNTHETIC_CONNECTED_METADATA','fixtures/qlik/sales_performance.metadata.json','8d8c9c69824dad7d75135ca808e54a3f46a269d870eb3b385d0777ffc1bd55ad','Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
{
  "notice": "Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.",
  "format": "normalized-fixture-v1",
  "platform": "Qlik",
  "app_id": "SYN_QLIK_SALES",
  "app_name": "Sales Performance",
  "description": "Customer sales bookings and monthly ordered value, excluding tax.",
  "load_script": "fixtures/qlik/sales_performance.qvs",
  "sheets": [
    {
      "id": "SYN_SHEET_ORDERS",
      "name": "Monthly Sales",
      "charts": [
        {
          "id": "SYN_CHART_ORDERED",
          "title": "Sales by month",
          "dimension": "MonthStart(SalesDate)",
          "measure": "Sum(SalesAmount)",
          "measure_label": "Sales (ordered, excluding tax)"
        },
        {
          "id": "SYN_CHART_CUSTOMER",
          "title": "Customer sales",
          "dimension": "CUSTOMERNAME",
          "measure": "Sum(SalesAmount)"
        }
      ]
    }
  ],
  "filters": [],
  "default_date_range": "all loaded dates",
  "currency": null
}
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES(s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('CONNECTED_5a56548a8e0e4e42','Synthetic qlik: sales_performance.qvs','SYNTHETIC_CONNECTED_METADATA','fixtures/qlik/sales_performance.qvs','6101a40d6c86b0be37d91febd8599c70e083f7fb7c2b364b3d5eeed3f432983e','Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
// SYNTHETIC fixture; not executed in Qlik. Connection is a placeholder.
LIB CONNECT TO ''SYNTHETIC_HANA_CONNECTION'';
SalesOrders:
LOAD ORDERID, ORDERLINEID, ORDERDATE AS SalesDate,
 CUSTOMERID, CUSTOMERNAME, STOCKITEMID, STOCKITEMNAME,
 QUANTITY, ORDERED_VALUE_EX_TAX AS SalesAmount;
SQL SELECT ORDERID, ORDERLINEID, ORDERDATE, CUSTOMERID, CUSTOMERNAME,
 STOCKITEMID, STOCKITEMNAME, QUANTITY, ORDERED_VALUE_EX_TAX
FROM "SYNTHETIC_SALES"."CV_ORDER_SALES";
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES(s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('CONNECTED_a5086dc0ef985e23','Synthetic spotfire: customer_sales.metadata.json','SYNTHETIC_CONNECTED_METADATA','fixtures/spotfire/customer_sales.metadata.json','46742043d0c70b3e9492aca16f0c3fc04404c1db0bc14e334978b2674f172357','Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
{
  "notice": "Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.",
  "format": "normalized-fixture-v1",
  "platform": "Spotfire",
  "analysis_id": "SYN_SPOTFIRE_CUSTOMER",
  "name": "Customer Sales",
  "description": "Invoiced sales by customer and invoice month, excluding tax.",
  "library_path": "/Synthetic/Finance/Customer Sales",
  "data_tables": [
    {
      "name": "InvoiceSales",
      "source_sql": "fixtures/spotfire/customer_sales.source.sql",
      "calculated_columns": [
        {
          "name": "SalesAmount",
          "expression": "[INVOICED_SALES_EX_TAX]"
        }
      ]
    }
  ],
  "pages": [
    {
      "name": "Invoice Sales",
      "visuals": [
        {
          "id": "SYN_VIZ_CUSTOMER",
          "title": "Customer invoiced sales",
          "data_table": "InvoiceSales",
          "category": "[CUSTOMERNAME]",
          "value": "Sum([SalesAmount])"
        },
        {
          "id": "SYN_VIZ_MONTH",
          "title": "Monthly invoiced sales",
          "data_table": "InvoiceSales",
          "category": "<Year([INVOICEDATE]) NEST Month([INVOICEDATE])>",
          "value": "Sum([SalesAmount])"
        }
      ]
    }
  ],
  "filters": [],
  "default_date_range": "all loaded dates",
  "currency": null
}
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES(s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('CONNECTED_1055b17d75582621','Synthetic spotfire: customer_sales.source.sql','SYNTHETIC_CONNECTED_METADATA','fixtures/spotfire/customer_sales.source.sql','f67352b5a51bba4566da228ea9c31326007138b0e8e05aabca4de2686370f561','Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
-- Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
SELECT INVOICEID, INVOICELINEID, ORDERID, INVOICEDATE,
 CUSTOMERID, CUSTOMERNAME, STOCKITEMID, STOCKITEMNAME, QUANTITY,
 INVOICED_SALES_EX_TAX, INVOICE_TAX, INVOICE_TOTAL_INCL_TAX
FROM "SYNTHETIC_SALES"."CV_INVOICE_SALES";
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES(s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('CONNECTED_d6d252dc2b0538ee','Synthetic business: definitions.md','SYNTHETIC_CONNECTED_METADATA','fixtures/business/definitions.md','250c6d6c4690f5c15a505188504b1cca28eed8b42c627908d52769070558da93','Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
# Northstar Supply: synthetic sales definitions

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
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES(s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

ALTER CORTEX SEARCH SERVICE HACKATHON_D2K_PREWORK.ANALYTICS.CSS_PREWORK_CATALOG REFRESH;

SELECT ARTIFACT_TYPE,COUNT(*) AS DOCUMENTS FROM HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG GROUP BY ARTIFACT_TYPE;