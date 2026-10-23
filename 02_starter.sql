-- PRE-EVENT FOUNDATION ONLY: simple query agent, not the competition workflow.
USE WAREHOUSE DEFAULT_WH;
CREATE SCHEMA HACKATHON_D2K_PREWORK.ANALYTICS;
CREATE SEMANTIC VIEW HACKATHON_D2K_PREWORK.ANALYTICS.SV_INVOICE_STARTER
 TABLES (
  lines AS HACKATHON_D2K_PREWORK.RAW.INVOICELINES PRIMARY KEY (INVOICELINEID),
  invoices AS HACKATHON_D2K_PREWORK.RAW.INVOICES PRIMARY KEY (INVOICEID),
  customers AS HACKATHON_D2K_PREWORK.RAW.CUSTOMERS PRIMARY KEY (CUSTOMERID),
  products AS HACKATHON_D2K_PREWORK.RAW.STOCKITEMS PRIMARY KEY (STOCKITEMID)
 )
 RELATIONSHIPS (
  line_invoice AS lines (INVOICEID) REFERENCES invoices (INVOICEID),
  invoice_customer AS invoices (CUSTOMERID) REFERENCES customers (CUSTOMERID),
  line_product AS lines (STOCKITEMID) REFERENCES products (STOCKITEMID)
 )
 DIMENSIONS (
  invoices.invoice_date AS INVOICEDATE,
  customers.customer_name AS CUSTOMERNAME,
  products.product_name AS STOCKITEMNAME
 )
 METRICS (
  lines.invoiced_sales_excluding_tax AS SUM(EXTENDEDPRICE - TAXAMOUNT)
   COMMENT='Synthetic invoice sales excluding tax. Public WWI InvoiceCustomerOrders logic defines ExtendedPrice as including tax.',
  lines.invoice_tax AS SUM(TAXAMOUNT),
  lines.invoice_total_including_tax AS SUM(EXTENDEDPRICE),
  lines.invoiced_quantity AS SUM(QUANTITY)
 )
 COMMENT='Pre-event starter model over a simplified public WWI schema adaptation and synthetic rows; not a finished data product.';

CREATE AGENT HACKATHON_D2K_PREWORK.ANALYTICS.PREWORK_QUERY_AGENT
 COMMENT='Pre-event baseline query agent. No discovery, lineage, product creation or publishing workflow yet.'
 PROFILE='{"display_name":"Prework Synthetic Sales"}'
 FROM SPECIFICATION $$
models:
  orchestration: claude-opus-5-5
instructions:
  response: 'Answer briefly. Clearly identify the data as synthetic. Do not claim to inspect source code, lineage, or create data products: those capabilities are not configured.'
  orchestration: 'Use InvoiceData for invoice metrics. Sales means excluding tax unless otherwise requested. If the question needs unavailable data, explain the limitation.'
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: InvoiceData
      description: 'Synthetic invoices by customer, product and date. Metrics exclude tax unless named including tax.'
tool_resources:
  InvoiceData:
    semantic_view: HACKATHON_D2K_PREWORK.ANALYTICS.SV_INVOICE_STARTER
    execution_environment:
      type: warehouse
      warehouse: DEFAULT_WH
$$;

SELECT SUM(EXTENDEDPRICE-TAXAMOUNT) AS SALES_EXCLUDING_TAX,
 SUM(TAXAMOUNT) AS TAX, SUM(EXTENDEDPRICE) AS TOTAL_INCLUDING_TAX,
 COUNT(*) AS INVOICE_LINES
FROM HACKATHON_D2K_PREWORK.RAW.INVOICELINES;
