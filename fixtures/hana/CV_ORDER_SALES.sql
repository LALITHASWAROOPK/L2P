-- Original synthetic fixture. Fictional company: Northstar Supply. Not exported from or validated in HANA, Qlik or Spotfire. No company data or real BI dashboard is represented.
-- SQL equivalent of the normalized model, not an SAP deployment artifact.
SELECT o.ORDERID, l.ORDERLINEID, o.ORDERDATE,
 c.CUSTOMERID, c.CUSTOMERNAME, p.STOCKITEMID, p.STOCKITEMNAME,
 l.QUANTITY, ROUND(l.QUANTITY * l.UNITPRICE, 2) AS ORDERED_VALUE_EX_TAX
FROM ORDERLINES l
JOIN ORDERS o ON l.ORDERID = o.ORDERID
JOIN CUSTOMERS c ON o.CUSTOMERID = c.CUSTOMERID
JOIN STOCKITEMS p ON l.STOCKITEMID = p.STOCKITEMID;
