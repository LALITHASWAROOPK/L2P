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
