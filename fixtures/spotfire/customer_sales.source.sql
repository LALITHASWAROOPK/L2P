-- Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
SELECT INVOICEID, INVOICELINEID, ORDERID, INVOICEDATE,
 CUSTOMERID, CUSTOMERNAME, STOCKITEMID, STOCKITEMNAME, QUANTITY,
 INVOICED_SALES_EX_TAX, INVOICE_TAX, INVOICE_TOTAL_INCL_TAX
FROM "SYNTHETIC_SALES"."CV_INVOICE_SALES";
