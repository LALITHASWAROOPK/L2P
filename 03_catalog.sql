-- PREWORK: synthetic report fixtures and basic search only.

USE WAREHOUSE DEFAULT_WH;

CREATE OR REPLACE VIEW HACKATHON_D2K_PREWORK.ANALYTICS.RPT_DAILY_INVOICE_SALES
COMMENT='Synthetic prework report fixture; not a published business dashboard.'
AS
SELECT i.INVOICEDATE AS SALES_DATE, COUNT(DISTINCT i.INVOICEID) AS INVOICE_COUNT,
 SUM(l.EXTENDEDPRICE-l.TAXAMOUNT) AS SALES_EXCLUDING_TAX,
 SUM(l.TAXAMOUNT) AS TAX, SUM(l.EXTENDEDPRICE) AS TOTAL_INCLUDING_TAX
FROM HACKATHON_D2K_PREWORK.RAW.INVOICES i
JOIN HACKATHON_D2K_PREWORK.RAW.INVOICELINES l ON l.INVOICEID=i.INVOICEID
GROUP BY i.INVOICEDATE;


CREATE OR REPLACE VIEW HACKATHON_D2K_PREWORK.ANALYTICS.RPT_DAILY_ORDERED_SALES
COMMENT='Synthetic prework report fixture; not a published business dashboard.'
AS
SELECT o.ORDERDATE AS ORDER_DATE, COUNT(DISTINCT o.ORDERID) AS ORDER_COUNT,
 SUM(ROUND(l.QUANTITY*l.UNITPRICE,2)) AS ORDERED_VALUE_EXCLUDING_TAX
FROM HACKATHON_D2K_PREWORK.RAW.ORDERS o
JOIN HACKATHON_D2K_PREWORK.RAW.ORDERLINES l ON l.ORDERID=o.ORDERID
GROUP BY o.ORDERDATE;


CREATE OR REPLACE VIEW HACKATHON_D2K_PREWORK.ANALYTICS.RPT_CUSTOMER_INVOICE_SALES
COMMENT='Synthetic prework report fixture; not a published business dashboard.'
AS
SELECT c.CUSTOMERID, c.CUSTOMERNAME, COUNT(DISTINCT i.INVOICEID) AS INVOICE_COUNT,
 SUM(l.EXTENDEDPRICE-l.TAXAMOUNT) AS SALES_EXCLUDING_TAX,
 SUM(l.TAXAMOUNT) AS TAX, SUM(l.EXTENDEDPRICE) AS TOTAL_INCLUDING_TAX
FROM HACKATHON_D2K_PREWORK.RAW.CUSTOMERS c
JOIN HACKATHON_D2K_PREWORK.RAW.INVOICES i ON i.CUSTOMERID=c.CUSTOMERID
JOIN HACKATHON_D2K_PREWORK.RAW.INVOICELINES l ON l.INVOICEID=i.INVOICEID
GROUP BY c.CUSTOMERID,c.CUSTOMERNAME;


CREATE TABLE IF NOT EXISTS HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG
 (DOC_ID VARCHAR, TITLE VARCHAR, ARTIFACT_TYPE VARCHAR, SOURCE_PATH VARCHAR, SOURCE_VERSION VARCHAR, CONTENT VARCHAR);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('DAILY_INVOICE_SALES','Daily invoiced sales','SYNTHETIC_REPORT','catalog/daily_invoice_sales.sql','c6540c7d67643c63435984c69f603d8d01682d2a414b57f6f4862cf8022432eb','Daily invoiced sales
Synthetic sales report by invoice date. Revenue means invoiced sales excluding tax; invoice total includes tax. No currency is modeled. Days without invoices are omitted.
Artifact: synthetic executable report fixture, not an actual BI dashboard.
CREATE OR REPLACE VIEW HACKATHON_D2K_PREWORK.ANALYTICS.RPT_DAILY_INVOICE_SALES
COMMENT=''Synthetic prework report fixture; not a published business dashboard.''
AS
SELECT i.INVOICEDATE AS SALES_DATE, COUNT(DISTINCT i.INVOICEID) AS INVOICE_COUNT,
 SUM(l.EXTENDEDPRICE-l.TAXAMOUNT) AS SALES_EXCLUDING_TAX,
 SUM(l.TAXAMOUNT) AS TAX, SUM(l.EXTENDEDPRICE) AS TOTAL_INCLUDING_TAX
FROM HACKATHON_D2K_PREWORK.RAW.INVOICES i
JOIN HACKATHON_D2K_PREWORK.RAW.INVOICELINES l ON l.INVOICEID=i.INVOICEID
GROUP BY i.INVOICEDATE;
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('DAILY_ORDERED_SALES','Daily ordered sales','SYNTHETIC_REPORT','catalog/daily_ordered_sales.sql','6e03af6e9e84c55f25d6693a146f6f5d525c3ad1ffb5b57bf8d92ddca6f836c7','Daily ordered sales
Synthetic bookings report by order date. Ordered value excluding tax is quantity times unit price. It includes orders not yet invoiced; it is not recognized revenue. No cancellation, discount or currency logic is modeled.
Artifact: synthetic executable report fixture, not an actual BI dashboard.
CREATE OR REPLACE VIEW HACKATHON_D2K_PREWORK.ANALYTICS.RPT_DAILY_ORDERED_SALES
COMMENT=''Synthetic prework report fixture; not a published business dashboard.''
AS
SELECT o.ORDERDATE AS ORDER_DATE, COUNT(DISTINCT o.ORDERID) AS ORDER_COUNT,
 SUM(ROUND(l.QUANTITY*l.UNITPRICE,2)) AS ORDERED_VALUE_EXCLUDING_TAX
FROM HACKATHON_D2K_PREWORK.RAW.ORDERS o
JOIN HACKATHON_D2K_PREWORK.RAW.ORDERLINES l ON l.ORDERID=o.ORDERID
GROUP BY o.ORDERDATE;
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('CUSTOMER_INVOICE_SALES','Customer invoiced sales','SYNTHETIC_REPORT','catalog/customer_invoice_sales.sql','00ff3721b9a717a97dfe6d8b343d6c1be29fb3cdd5298d425a103a050bfb63b0','Customer invoiced sales
Synthetic customer sales report across all invoice dates. Customer identity is CUSTOMERID; customer name is a label. Sales excludes tax, invoice total includes tax. No currency is modeled.
Artifact: synthetic executable report fixture, not an actual BI dashboard.
CREATE OR REPLACE VIEW HACKATHON_D2K_PREWORK.ANALYTICS.RPT_CUSTOMER_INVOICE_SALES
COMMENT=''Synthetic prework report fixture; not a published business dashboard.''
AS
SELECT c.CUSTOMERID, c.CUSTOMERNAME, COUNT(DISTINCT i.INVOICEID) AS INVOICE_COUNT,
 SUM(l.EXTENDEDPRICE-l.TAXAMOUNT) AS SALES_EXCLUDING_TAX,
 SUM(l.TAXAMOUNT) AS TAX, SUM(l.EXTENDEDPRICE) AS TOTAL_INCLUDING_TAX
FROM HACKATHON_D2K_PREWORK.RAW.CUSTOMERS c
JOIN HACKATHON_D2K_PREWORK.RAW.INVOICES i ON i.CUSTOMERID=c.CUSTOMERID
JOIN HACKATHON_D2K_PREWORK.RAW.INVOICELINES l ON l.INVOICEID=i.INVOICEID
GROUP BY c.CUSTOMERID,c.CUSTOMERNAME;
')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_2dfd93a5e3e84b38','Public WWI reference: Sales/Tables/Customers.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/Sales/Tables/Customers.sql','FEA8A3680D3D79A5A4F1EA19F5482918D3618C629A038F66A1EE458C5C939A05','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.
CREATE TABLE [Sales].[Customers] (
    [CustomerID]                 INT                                         CONSTRAINT [DF_Sales_Customers_CustomerID] DEFAULT (NEXT VALUE FOR [Sequences].[CustomerID]) NOT NULL,
    [CustomerName]               NVARCHAR (100)                              NOT NULL,
    [BillToCustomerID]           INT                                         NOT NULL,
    [CustomerCategoryID]         INT                                         NOT NULL,
    [BuyingGroupID]              INT                                         NULL,
    [PrimaryContactPersonID]     INT                                         NOT NULL,
    [AlternateContactPersonID]   INT                                         NULL,
    [DeliveryMethodID]           INT                                         NOT NULL,
    [DeliveryCityID]             INT                                         NOT NULL,
    [PostalCityID]               INT                                         NOT NULL,
    [CreditLimit]                DECIMAL (18, 2)                             NULL,
    [AccountOpenedDate]          DATE                                        NOT NULL,
    [StandardDiscountPercentage] DECIMAL (18, 3)                             NOT NULL,
    [IsStatementSent]            BIT                                         NOT NULL,
    [IsOnCreditHold]             BIT                                         NOT NULL,
    [PaymentDays]                INT                                         NOT NULL,
    [PhoneNumber]                NVARCHAR (20)                               NOT NULL,
    [FaxNumber]                  NVARCHAR (20)                               NOT NULL,
    [DeliveryRun]                NVARCHAR (5)                                NULL,
    [RunPosition]                NVARCHAR (5)                                NULL,
    [WebsiteURL]                 NVARCHAR (256)                              NOT NULL,
    [DeliveryAddressLine1]       NVARCHAR (60)                               NOT NULL,
    [DeliveryAddressLine2]       NVARCHAR (60)                               NULL,
    [DeliveryPostalCode]         NVARCHAR (10)                               NOT NULL,
    [DeliveryLocation]           [sys].[geography]                           NULL,
    [PostalAddressLine1]         NVARCHAR (60)                               NOT NULL,
    [PostalAddressLine2]         NVARCHAR (60)                               NULL,
    [PostalPostalCode]           NVARCHAR (10)                               NOT NULL,
    [LastEditedBy]               INT                                         NOT NULL,
    [ValidFrom]                  DATETIME2 (7) GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]                    DATETIME2 (7) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_Sales_Customers] PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    CONSTRAINT [FK_Sales_Customers_AlternateContactPersonID_Application_People] FOREIGN KEY ([AlternateContactPersonID]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Sales_Customers_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Sales_Customers_BillToCustomerID_Sales_Customers] FOREIGN KEY ([BillToCustomerID]) REFERENCES [Sales].[Customers] ([CustomerID]),
    CONSTRAINT [FK_Sales_Customers_BuyingGroupID_Sales_BuyingGroups] FOREIGN KEY ([BuyingGroupID]) REFERENCES [Sales].[BuyingGroups] ([BuyingGroupID]),
    CONSTRAINT [FK_Sales_Customers_CustomerCategoryID_Sales_CustomerCategories] FOREIGN KEY ([CustomerCategoryID]) REFERENCES [Sales].[CustomerCategories] ([CustomerCategoryID]),
    CONSTRAINT [FK_Sales_Customers_DeliveryCityID_Application_Cities] FOREIGN KEY ([DeliveryCityID]) REFERENCES [Application].[Cities] ([CityID]),
    CONSTRAINT [FK_Sales_Customers_DeliveryMethodID_Application_DeliveryMethods] FOREIGN KEY ([DeliveryMethodID]) REFERENCES [Application].[DeliveryMethods] ([DeliveryMethodID]),
    CONSTRAINT [FK_Sales_Customers_PostalCityID_Application_Cities] FOREIGN KEY ([PostalCityID]) REFERENCES [Application].[Cities] ([CityID]),
    CONSTRAINT [FK_Sales_Customers_PrimaryContactPersonID_Application_People] FOREIGN KEY ([PrimaryContactPersonID]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [UQ_Sales_Customers_CustomerName] UNIQUE NONCLUSTERED ([CustomerName] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[Sales].[Customers_Archive], DATA_CONSISTENCY_CHECK=ON));




GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_CustomerCategoryID]
    ON [Sales].[Customers]([CustomerCategoryID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_BuyingGroupID]
    ON [Sales].[Customers]([BuyingGroupID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_PrimaryContactPersonID]
    ON [Sales].[Customers]([PrimaryContactPersonID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_AlternateContactPersonID]
    ON [Sales].[Customers]([AlternateContactPersonID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_DeliveryMethodID]
    ON [Sales].[Customers]([DeliveryMethodID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_DeliveryCityID]
    ON [Sales].[Customers]([DeliveryCityID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_PostalCityID]
    ON [Sales].[Customers]([PostalCityID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Sales_Customers_Perf_20160301_06]
    ON [Sales].[Customers]([IsOnCreditHold] ASC, [CustomerID] ASC, [BillToCustomerID] ASC)
    INCLUDE([PrimaryContactPersonID]);


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Customers_CustomerCategoryID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Customers_BuyingGroupID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Customers_PrimaryContactPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Customers_AlternateContactPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Customers_DeliveryMethodID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Customers_DeliveryCityID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Customers_PostalCityID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Improves performance of order picking and invoicing'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''INDEX'', @level2name = N''IX_Sales_Customers_Perf_20160301_06'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = N''Main entity tables for customers (organizations or individuals)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Numeric ID used for reference to a customer within the database'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''CustomerID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Customer''''s full name (usually a trading name)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''CustomerName'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Customer that this is billed to (usually the same customer but can be another parent company)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''BillToCustomerID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Customer''''s category'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''CustomerCategoryID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Customer''''s buying group (optional)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''BuyingGroupID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Primary contact'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''PrimaryContactPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Alternate contact'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''AlternateContactPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Standard delivery method for stock items sent to this customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''DeliveryMethodID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''ID of the delivery city for this address'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''DeliveryCityID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''ID of the postal city for this address'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''PostalCityID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Credit limit for this customer (NULL if unlimited)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''CreditLimit'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Date this customer account was opened'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''AccountOpenedDate'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Standard discount offered to this customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''StandardDiscountPercentage'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Is a statement sent to this customer? (Or do they just pay on each invoice?)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''IsStatementSent'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Is this customer on credit hold? (Prevents further deliveries to this customer)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''IsOnCreditHold'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Number of days for payment of an invoice (ie payment terms)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''PaymentDays'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Phone number'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''PhoneNumber'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Fax number  '', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''FaxNumber'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Normal delivery run for this customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''DeliveryRun'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Normal position in the delivery run for this customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''RunPosition'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''URL for the website for this customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''WebsiteURL'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''First delivery address line for the customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''DeliveryAddressLine1'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Second delivery address line for the customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''DeliveryAddressLine2'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Delivery postal code for the customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''DeliveryPostalCode'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Geographic location for the customer''''s office/warehouse'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''DeliveryLocation'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''First postal address line for the customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''PostalAddressLine1'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Second postal address line for the customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''PostalAddressLine2'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Postal code for the customer when sending by mail'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Customers'', @level2type = N''COLUMN'', @level2name = N''PostalPostalCode'';

')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_752e0d9ce87e1244','Public WWI reference: Sales/Tables/Orders.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/Sales/Tables/Orders.sql','5D76A3C1271C2BA7C1022958E450D4C24D09DFA45CDBF2BE930748213531C35C','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.
CREATE TABLE [Sales].[Orders] (
    [OrderID]                     INT            CONSTRAINT [DF_Sales_Orders_OrderID] DEFAULT (NEXT VALUE FOR [Sequences].[OrderID]) NOT NULL,
    [CustomerID]                  INT            NOT NULL,
    [SalespersonPersonID]         INT            NOT NULL,
    [PickedByPersonID]            INT            NULL,
    [ContactPersonID]             INT            NOT NULL,
    [BackorderOrderID]            INT            NULL,
    [OrderDate]                   DATE           NOT NULL,
    [ExpectedDeliveryDate]        DATE           NOT NULL,
    [CustomerPurchaseOrderNumber] NVARCHAR (20)  NULL,
    [IsUndersupplyBackordered]    BIT            NOT NULL,
    [Comments]                    NVARCHAR (MAX) NULL,
    [DeliveryInstructions]        NVARCHAR (MAX) NULL,
    [InternalComments]            NVARCHAR (MAX) NULL,
    [PickingCompletedWhen]        DATETIME2 (7)  NULL,
    [LastEditedBy]                INT            NOT NULL,
    [LastEditedWhen]              DATETIME2 (7)  CONSTRAINT [DF_Sales_Orders_LastEditedWhen] DEFAULT (sysdatetime()) NOT NULL,
    CONSTRAINT [PK_Sales_Orders] PRIMARY KEY CLUSTERED ([OrderID] ASC),
    CONSTRAINT [FK_Sales_Orders_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Sales_Orders_BackorderOrderID_Sales_Orders] FOREIGN KEY ([BackorderOrderID]) REFERENCES [Sales].[Orders] ([OrderID]),
    CONSTRAINT [FK_Sales_Orders_ContactPersonID_Application_People] FOREIGN KEY ([ContactPersonID]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Sales_Orders_CustomerID_Sales_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers] ([CustomerID]),
    CONSTRAINT [FK_Sales_Orders_PickedByPersonID_Application_People] FOREIGN KEY ([PickedByPersonID]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Sales_Orders_SalespersonPersonID_Application_People] FOREIGN KEY ([SalespersonPersonID]) REFERENCES [Application].[People] ([PersonID])
);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Orders_CustomerID]
    ON [Sales].[Orders]([CustomerID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Orders_SalespersonPersonID]
    ON [Sales].[Orders]([SalespersonPersonID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Orders_PickedByPersonID]
    ON [Sales].[Orders]([PickedByPersonID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Orders_ContactPersonID]
    ON [Sales].[Orders]([ContactPersonID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Orders_CustomerID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Orders_SalespersonPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Orders_PickedByPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Orders_ContactPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = N''Detail of customer orders'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Numeric ID used for reference to an order within the database'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''OrderID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Customer for this order'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''CustomerID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Salesperson for this order'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''SalespersonPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Person who picked this shipment'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''PickedByPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Customer contact for this order'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''ContactPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''If this order is a backorder, this column holds the original order number'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''BackorderOrderID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Date that this order was raised'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''OrderDate'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Expected delivery date'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''ExpectedDeliveryDate'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Purchase Order Number received from customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''CustomerPurchaseOrderNumber'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''If items cannot be supplied are they backordered?'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''IsUndersupplyBackordered'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Any comments related to this order (sent to customer)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''Comments'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Any comments related to order delivery (sent to customer)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''DeliveryInstructions'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Any internal comments related to this order (not sent to the customer)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''InternalComments'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''When was picking of the entire order completed?'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Orders'', @level2type = N''COLUMN'', @level2name = N''PickingCompletedWhen'';

')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_1099381f1dbd7d22','Public WWI reference: Sales/Tables/OrderLines.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/Sales/Tables/OrderLines.sql','0A47B2F0711306CF7E773E081D20EA8E724ED4A40B7C5BD51E631200AFBA0AB0','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.
CREATE TABLE [Sales].[OrderLines] (
    [OrderLineID]          INT             CONSTRAINT [DF_Sales_OrderLines_OrderLineID] DEFAULT (NEXT VALUE FOR [Sequences].[OrderLineID]) NOT NULL,
    [OrderID]              INT             NOT NULL,
    [StockItemID]          INT             NOT NULL,
    [Description]          NVARCHAR (100)  NOT NULL,
    [PackageTypeID]        INT             NOT NULL,
    [Quantity]             INT             NOT NULL,
    [UnitPrice]            DECIMAL (18, 2) NULL,
    [TaxRate]              DECIMAL (18, 3) NOT NULL,
    [PickedQuantity]       INT             NOT NULL,
    [PickingCompletedWhen] DATETIME2 (7)   NULL,
    [LastEditedBy]         INT             NOT NULL,
    [LastEditedWhen]       DATETIME2 (7)   CONSTRAINT [DF_Sales_OrderLines_LastEditedWhen] DEFAULT (sysdatetime()) NOT NULL,
    CONSTRAINT [PK_Sales_OrderLines] PRIMARY KEY CLUSTERED ([OrderLineID] ASC),
    CONSTRAINT [FK_Sales_OrderLines_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders] FOREIGN KEY ([OrderID]) REFERENCES [Sales].[Orders] ([OrderID]),
    CONSTRAINT [FK_Sales_OrderLines_PackageTypeID_Warehouse_PackageTypes] FOREIGN KEY ([PackageTypeID]) REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID]),
    CONSTRAINT [FK_Sales_OrderLines_StockItemID_Warehouse_StockItems] FOREIGN KEY ([StockItemID]) REFERENCES [Warehouse].[StockItems] ([StockItemID])
);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_OrderLines_OrderID]
    ON [Sales].[OrderLines]([OrderID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_OrderLines_PackageTypeID]
    ON [Sales].[OrderLines]([PackageTypeID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Sales_OrderLines_AllocatedStockItems]
    ON [Sales].[OrderLines]([StockItemID] ASC)
    INCLUDE([PickedQuantity]);


GO
CREATE NONCLUSTERED INDEX [IX_Sales_OrderLines_Perf_20160301_01]
    ON [Sales].[OrderLines]([PickingCompletedWhen] ASC, [OrderID] ASC, [OrderLineID] ASC)
    INCLUDE([Quantity], [StockItemID]);


GO
CREATE NONCLUSTERED INDEX [IX_Sales_OrderLines_Perf_20160301_02]
    ON [Sales].[OrderLines]([StockItemID] ASC, [PickingCompletedWhen] ASC)
    INCLUDE([OrderID], [PickedQuantity]);


GO
CREATE COLUMNSTORE INDEX [NCCX_Sales_OrderLines]
    ON [Sales].[OrderLines]([OrderID], [StockItemID], [Description], [Quantity], [UnitPrice], [PickedQuantity], [PackageTypeID]);


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''INDEX'', @level2name = N''FK_Sales_OrderLines_OrderID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''INDEX'', @level2name = N''FK_Sales_OrderLines_PackageTypeID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Allows quick summation of stock item quantites already allocated to uninvoiced orders'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''INDEX'', @level2name = N''IX_Sales_OrderLines_AllocatedStockItems'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Improves performance of order picking and invoicing'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''INDEX'', @level2name = N''IX_Sales_OrderLines_Perf_20160301_01'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Improves performance of order picking and invoicing'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''INDEX'', @level2name = N''IX_Sales_OrderLines_Perf_20160301_02'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = N''Detail lines from customer orders'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Numeric ID used for reference to a line on an Order within the database'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''COLUMN'', @level2name = N''OrderLineID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Order that this line is associated with'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''COLUMN'', @level2name = N''OrderID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Stock item for this order line (FK not indexed as separate index exists)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''COLUMN'', @level2name = N''StockItemID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Description of the item supplied (Usually the stock item name but can be overridden)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''COLUMN'', @level2name = N''Description'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Type of package to be supplied'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''COLUMN'', @level2name = N''PackageTypeID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Quantity to be supplied'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''COLUMN'', @level2name = N''Quantity'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Unit price to be charged'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''COLUMN'', @level2name = N''UnitPrice'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Tax rate to be applied'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''COLUMN'', @level2name = N''TaxRate'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Quantity picked from stock'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''COLUMN'', @level2name = N''PickedQuantity'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''When was picking of this line completed?'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''OrderLines'', @level2type = N''COLUMN'', @level2name = N''PickingCompletedWhen'';

')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_b00d8276fe9175f6','Public WWI reference: Sales/Tables/Invoices.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/Sales/Tables/Invoices.sql','E274206641A02FEB38F615F67814A87928E04B00C5ED5EF35314E2AC6D100D69','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.
CREATE TABLE [Sales].[Invoices] (
    [InvoiceID]                   INT            CONSTRAINT [DF_Sales_Invoices_InvoiceID] DEFAULT (NEXT VALUE FOR [Sequences].[InvoiceID]) NOT NULL,
    [CustomerID]                  INT            NOT NULL,
    [BillToCustomerID]            INT            NOT NULL,
    [OrderID]                     INT            NULL,
    [DeliveryMethodID]            INT            NOT NULL,
    [ContactPersonID]             INT            NOT NULL,
    [AccountsPersonID]            INT            NOT NULL,
    [SalespersonPersonID]         INT            NOT NULL,
    [PackedByPersonID]            INT            NOT NULL,
    [InvoiceDate]                 DATE           NOT NULL,
    [CustomerPurchaseOrderNumber] NVARCHAR (20)  NULL,
    [IsCreditNote]                BIT            NOT NULL,
    [CreditNoteReason]            NVARCHAR (MAX) NULL,
    [Comments]                    NVARCHAR (MAX) NULL,
    [DeliveryInstructions]        NVARCHAR (MAX) NULL,
    [InternalComments]            NVARCHAR (MAX) NULL,
    [TotalDryItems]               INT            NOT NULL,
    [TotalChillerItems]           INT            NOT NULL,
    [DeliveryRun]                 NVARCHAR (5)   NULL,
    [RunPosition]                 NVARCHAR (5)   NULL,
    [ReturnedDeliveryData]        NVARCHAR (MAX) NULL,
    [ConfirmedDeliveryTime]       AS             (TRY_CONVERT([datetime2](7),json_value([ReturnedDeliveryData],N''$.DeliveredWhen''),(126))),
    [ConfirmedReceivedBy]         AS             (json_value([ReturnedDeliveryData],N''$.ReceivedBy'')),
    [LastEditedBy]                INT            NOT NULL,
    [LastEditedWhen]              DATETIME2 (7)  CONSTRAINT [DF_Sales_Invoices_LastEditedWhen] DEFAULT (sysdatetime()) NOT NULL,
    CONSTRAINT [PK_Sales_Invoices] PRIMARY KEY CLUSTERED ([InvoiceID] ASC),
    CONSTRAINT [CK_Sales_Invoices_ReturnedDeliveryData_Must_Be_Valid_JSON] CHECK ([ReturnedDeliveryData] IS NULL OR isjson([ReturnedDeliveryData])<>(0)),
    CONSTRAINT [FK_Sales_Invoices_AccountsPersonID_Application_People] FOREIGN KEY ([AccountsPersonID]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Sales_Invoices_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Sales_Invoices_BillToCustomerID_Sales_Customers] FOREIGN KEY ([BillToCustomerID]) REFERENCES [Sales].[Customers] ([CustomerID]),
    CONSTRAINT [FK_Sales_Invoices_ContactPersonID_Application_People] FOREIGN KEY ([ContactPersonID]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Sales_Invoices_CustomerID_Sales_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers] ([CustomerID]),
    CONSTRAINT [FK_Sales_Invoices_DeliveryMethodID_Application_DeliveryMethods] FOREIGN KEY ([DeliveryMethodID]) REFERENCES [Application].[DeliveryMethods] ([DeliveryMethodID]),
    CONSTRAINT [FK_Sales_Invoices_OrderID_Sales_Orders] FOREIGN KEY ([OrderID]) REFERENCES [Sales].[Orders] ([OrderID]),
    CONSTRAINT [FK_Sales_Invoices_PackedByPersonID_Application_People] FOREIGN KEY ([PackedByPersonID]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Sales_Invoices_SalespersonPersonID_Application_People] FOREIGN KEY ([SalespersonPersonID]) REFERENCES [Application].[People] ([PersonID])
);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_CustomerID]
    ON [Sales].[Invoices]([CustomerID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_BillToCustomerID]
    ON [Sales].[Invoices]([BillToCustomerID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_OrderID]
    ON [Sales].[Invoices]([OrderID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_DeliveryMethodID]
    ON [Sales].[Invoices]([DeliveryMethodID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_ContactPersonID]
    ON [Sales].[Invoices]([ContactPersonID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_AccountsPersonID]
    ON [Sales].[Invoices]([AccountsPersonID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_SalespersonPersonID]
    ON [Sales].[Invoices]([SalespersonPersonID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_PackedByPersonID]
    ON [Sales].[Invoices]([PackedByPersonID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Sales_Invoices_ConfirmedDeliveryTime]
    ON [Sales].[Invoices]([ConfirmedDeliveryTime] ASC)
    INCLUDE([ConfirmedReceivedBy]);


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Invoices_CustomerID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Invoices_BillToCustomerID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Invoices_OrderID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Invoices_DeliveryMethodID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Invoices_ContactPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Invoices_AccountsPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Invoices_SalespersonPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''INDEX'', @level2name = N''FK_Sales_Invoices_PackedByPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Allows quick retrieval of invoices confirmed to have been delivered in a given time period'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''INDEX'', @level2name = N''IX_Sales_Invoices_ConfirmedDeliveryTime'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Ensures that if returned delivery data is present that it is valid JSON'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''CONSTRAINT'', @level2name = N''CK_Sales_Invoices_ReturnedDeliveryData_Must_Be_Valid_JSON'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = N''Details of customer invoices'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Numeric ID used for reference to an invoice within the database'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''InvoiceID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Customer for this invoice'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''CustomerID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Bill to customer for this invoice (invoices might be billed to a head office)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''BillToCustomerID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Sales order (if any) for this invoice'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''OrderID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''How these stock items are beign delivered'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''DeliveryMethodID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Customer contact for this invoice'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''ContactPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Customer accounts contact for this invoice'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''AccountsPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Salesperson for this invoice'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''SalespersonPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Person who packed this shipment (or checked the packing)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''PackedByPersonID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Date that this invoice was raised'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''InvoiceDate'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Purchase Order Number received from customer'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''CustomerPurchaseOrderNumber'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Is this a credit note (rather than an invoice)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''IsCreditNote'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Reason that this credit note needed to be generated (if applicable)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''CreditNoteReason'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Any comments related to this invoice (sent to customer)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''Comments'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Any comments related to delivery (sent to customer)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''DeliveryInstructions'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Any internal comments related to this invoice (not sent to the customer)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''InternalComments'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Total number of dry packages (information for the delivery driver)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''TotalDryItems'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Total number of chiller packages (information for the delivery driver)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''TotalChillerItems'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Delivery run for this shipment'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''DeliveryRun'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Position in the delivery run for this shipment'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''RunPosition'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''JSON-structured data returned from delivery devices for deliveries made directly by the organization'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''ReturnedDeliveryData'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Confirmed delivery date and time promoted from JSON delivery data'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''ConfirmedDeliveryTime'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Confirmed receiver promoted from JSON delivery data'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''Invoices'', @level2type = N''COLUMN'', @level2name = N''ConfirmedReceivedBy'';

')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_0d23d476e3cc77fc','Public WWI reference: Sales/Tables/InvoiceLines.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/Sales/Tables/InvoiceLines.sql','C73464737BEA9F610087C63A37F99B9BA95CDE8CDD1B7F24B174BBC9A42DD280','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.
CREATE TABLE [Sales].[InvoiceLines] (
    [InvoiceLineID]  INT             CONSTRAINT [DF_Sales_InvoiceLines_InvoiceLineID] DEFAULT (NEXT VALUE FOR [Sequences].[InvoiceLineID]) NOT NULL,
    [InvoiceID]      INT             NOT NULL,
    [StockItemID]    INT             NOT NULL,
    [Description]    NVARCHAR (100)  NOT NULL,
    [PackageTypeID]  INT             NOT NULL,
    [Quantity]       INT             NOT NULL,
    [UnitPrice]      DECIMAL (18, 2) NULL,
    [TaxRate]        DECIMAL (18, 3) NOT NULL,
    [TaxAmount]      DECIMAL (18, 2) NOT NULL,
    [LineProfit]     DECIMAL (18, 2) NOT NULL,
    [ExtendedPrice]  DECIMAL (18, 2) NOT NULL,
    [LastEditedBy]   INT             NOT NULL,
    [LastEditedWhen] DATETIME2 (7)   CONSTRAINT [DF_Sales_InvoiceLines_LastEditedWhen] DEFAULT (sysdatetime()) NOT NULL,
    CONSTRAINT [PK_Sales_InvoiceLines] PRIMARY KEY CLUSTERED ([InvoiceLineID] ASC),
    CONSTRAINT [FK_Sales_InvoiceLines_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Sales_InvoiceLines_InvoiceID_Sales_Invoices] FOREIGN KEY ([InvoiceID]) REFERENCES [Sales].[Invoices] ([InvoiceID]),
    CONSTRAINT [FK_Sales_InvoiceLines_PackageTypeID_Warehouse_PackageTypes] FOREIGN KEY ([PackageTypeID]) REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID]),
    CONSTRAINT [FK_Sales_InvoiceLines_StockItemID_Warehouse_StockItems] FOREIGN KEY ([StockItemID]) REFERENCES [Warehouse].[StockItems] ([StockItemID])
);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_InvoiceLines_InvoiceID]
    ON [Sales].[InvoiceLines]([InvoiceID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_InvoiceLines_StockItemID]
    ON [Sales].[InvoiceLines]([StockItemID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Sales_InvoiceLines_PackageTypeID]
    ON [Sales].[InvoiceLines]([PackageTypeID] ASC);


GO
CREATE COLUMNSTORE INDEX [NCCX_Sales_InvoiceLines]
    ON [Sales].[InvoiceLines]([InvoiceID], [StockItemID], [Quantity], [UnitPrice], [LineProfit], [LastEditedWhen]);


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''INDEX'', @level2name = N''FK_Sales_InvoiceLines_InvoiceID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''INDEX'', @level2name = N''FK_Sales_InvoiceLines_StockItemID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''INDEX'', @level2name = N''FK_Sales_InvoiceLines_PackageTypeID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = N''Detail lines from customer invoices'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Numeric ID used for reference to a line on an invoice within the database'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''COLUMN'', @level2name = N''InvoiceLineID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Invoice that this line is associated with'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''COLUMN'', @level2name = N''InvoiceID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Stock item for this invoice line'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''COLUMN'', @level2name = N''StockItemID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Description of the item supplied (Usually the stock item name but can be overridden)'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''COLUMN'', @level2name = N''Description'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Type of package supplied'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''COLUMN'', @level2name = N''PackageTypeID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Quantity supplied'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''COLUMN'', @level2name = N''Quantity'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Unit price charged'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''COLUMN'', @level2name = N''UnitPrice'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Tax rate to be applied'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''COLUMN'', @level2name = N''TaxRate'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Tax amount calculated'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''COLUMN'', @level2name = N''TaxAmount'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Profit made on this line item at current cost price'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''COLUMN'', @level2name = N''LineProfit'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Extended line price charged'', @level0type = N''SCHEMA'', @level0name = N''Sales'', @level1type = N''TABLE'', @level1name = N''InvoiceLines'', @level2type = N''COLUMN'', @level2name = N''ExtendedPrice'';

')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_5e4fd2f3e2e4a8ef','Public WWI reference: Warehouse/Tables/StockItems.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItems.sql','493E1C80487ADC972B1A6260593508617CB8E58853EA157FCA2B2B6EB1A747E9','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.
CREATE TABLE [Warehouse].[StockItems] (
    [StockItemID]            INT                                         CONSTRAINT [DF_Warehouse_StockItems_StockItemID] DEFAULT (NEXT VALUE FOR [Sequences].[StockItemID]) NOT NULL,
    [StockItemName]          NVARCHAR (100)                              NOT NULL,
    [SupplierID]             INT                                         NOT NULL,
    [ColorID]                INT                                         NULL,
    [UnitPackageID]          INT                                         NOT NULL,
    [OuterPackageID]         INT                                         NOT NULL,
    [Brand]                  NVARCHAR (50)                               NULL,
    [Size]                   NVARCHAR (20)                               NULL,
    [LeadTimeDays]           INT                                         NOT NULL,
    [QuantityPerOuter]       INT                                         NOT NULL,
    [IsChillerStock]         BIT                                         NOT NULL,
    [Barcode]                NVARCHAR (50)                               NULL,
    [TaxRate]                DECIMAL (18, 3)                             NOT NULL,
    [UnitPrice]              DECIMAL (18, 2)                             NOT NULL,
    [RecommendedRetailPrice] DECIMAL (18, 2)                             NULL,
    [TypicalWeightPerUnit]   DECIMAL (18, 3)                             NOT NULL,
    [MarketingComments]      NVARCHAR (MAX)                              NULL,
    [InternalComments]       NVARCHAR (MAX)                              NULL,
    [Photo]                  VARBINARY (MAX)                             NULL,
    [CustomFields]           NVARCHAR (MAX)                              NULL,
    [Tags]                   AS                                          (json_query([CustomFields],N''$.Tags'')),
    [SearchDetails]          AS                                          (concat([StockItemName],N'' '',[MarketingComments])),
    [LastEditedBy]           INT                                         NOT NULL,
    [ValidFrom]              DATETIME2 (7) GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]                DATETIME2 (7) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_Warehouse_StockItems] PRIMARY KEY CLUSTERED ([StockItemID] ASC),
    CONSTRAINT [FK_Warehouse_StockItems_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Warehouse_StockItems_ColorID_Warehouse_Colors] FOREIGN KEY ([ColorID]) REFERENCES [Warehouse].[Colors] ([ColorID]),
    CONSTRAINT [FK_Warehouse_StockItems_OuterPackageID_Warehouse_PackageTypes] FOREIGN KEY ([OuterPackageID]) REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID]),
    CONSTRAINT [FK_Warehouse_StockItems_SupplierID_Purchasing_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [Purchasing].[Suppliers] ([SupplierID]),
    CONSTRAINT [FK_Warehouse_StockItems_UnitPackageID_Warehouse_PackageTypes] FOREIGN KEY ([UnitPackageID]) REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID]),
    CONSTRAINT [UQ_Warehouse_StockItems_StockItemName] UNIQUE NONCLUSTERED ([StockItemName] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[Warehouse].[StockItems_Archive], DATA_CONSISTENCY_CHECK=ON));




GO
CREATE NONCLUSTERED INDEX [FK_Warehouse_StockItems_SupplierID]
    ON [Warehouse].[StockItems]([SupplierID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Warehouse_StockItems_ColorID]
    ON [Warehouse].[StockItems]([ColorID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Warehouse_StockItems_UnitPackageID]
    ON [Warehouse].[StockItems]([UnitPackageID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Warehouse_StockItems_OuterPackageID]
    ON [Warehouse].[StockItems]([OuterPackageID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''INDEX'', @level2name = N''FK_Warehouse_StockItems_SupplierID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''INDEX'', @level2name = N''FK_Warehouse_StockItems_ColorID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''INDEX'', @level2name = N''FK_Warehouse_StockItems_UnitPackageID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''INDEX'', @level2name = N''FK_Warehouse_StockItems_OuterPackageID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = N''Main entity table for stock items'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Numeric ID used for reference to a stock item within the database'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''StockItemID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Full name of a stock item (but not a full description)'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''StockItemName'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Usual supplier for this stock item'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''SupplierID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Color (optional) for this stock item'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''ColorID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Usual package for selling units of this stock item'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''UnitPackageID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Usual package for selling outers of this stock item (ie cartons, boxes, etc.)'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''OuterPackageID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Brand for the stock item (if the item is branded)'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''Brand'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Size of this item (eg: 100mm)'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''Size'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Number of days typically taken from order to receipt of this stock item'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''LeadTimeDays'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Quantity of the stock item in an outer package'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''QuantityPerOuter'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Does this stock item need to be in a chiller?'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''IsChillerStock'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Barcode for this stock item'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''Barcode'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Tax rate to be applied'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''TaxRate'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Selling price (ex-tax) for one unit of this product'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''UnitPrice'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Recommended retail price for this stock item'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''RecommendedRetailPrice'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Typical weight for one unit of this product (packaged)'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''TypicalWeightPerUnit'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Marketing comments for this stock item (shared outside the organization)'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''MarketingComments'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Internal comments (not exposed outside organization)'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''InternalComments'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Photo of the product'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''Photo'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Custom fields added by system users'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''CustomFields'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Advertising tags associated with this stock item (JSON array retrieved from CustomFields)'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''Tags'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Combination of columns used by full text search'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItems'', @level2type = N''COLUMN'', @level2name = N''SearchDetails'';

')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_1fb7c740b4d76ea2','Public WWI reference: Warehouse/Tables/StockGroups.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockGroups.sql','9ED45F27089E0940DC6BF8498F62D19AAFA02F527369DC8FA3E3246127550264','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.
CREATE TABLE [Warehouse].[StockGroups] (
    [StockGroupID]   INT                                         CONSTRAINT [DF_Warehouse_StockGroups_StockGroupID] DEFAULT (NEXT VALUE FOR [Sequences].[StockGroupID]) NOT NULL,
    [StockGroupName] NVARCHAR (50)                               NOT NULL,
    [LastEditedBy]   INT                                         NOT NULL,
    [ValidFrom]      DATETIME2 (7) GENERATED ALWAYS AS ROW START NOT NULL,
    [ValidTo]        DATETIME2 (7) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_Warehouse_StockGroups] PRIMARY KEY CLUSTERED ([StockGroupID] ASC),
    CONSTRAINT [FK_Warehouse_StockGroups_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [UQ_Warehouse_StockGroups_StockGroupName] UNIQUE NONCLUSTERED ([StockGroupName] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[Warehouse].[StockGroups_Archive], DATA_CONSISTENCY_CHECK=ON));


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = N''Groups for categorizing stock items (ie: novelties, toys, edible novelties, etc.)'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockGroups'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Numeric ID used for reference to a stock group within the database'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockGroups'', @level2type = N''COLUMN'', @level2name = N''StockGroupID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Full name of groups used to categorize stock items'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockGroups'', @level2type = N''COLUMN'', @level2name = N''StockGroupName'';

')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_1efd4c195b0137bb','Public WWI reference: Warehouse/Tables/StockItemStockGroups.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItemStockGroups.sql','78683E63CDEC019B3C530662E17CB2F2C5116CC8BF1B5FBDA8335ED740CC68D1','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.
CREATE TABLE [Warehouse].[StockItemStockGroups] (
    [StockItemStockGroupID] INT           CONSTRAINT [DF_Warehouse_StockItemStockGroups_StockItemStockGroupID] DEFAULT (NEXT VALUE FOR [Sequences].[StockItemStockGroupID]) NOT NULL,
    [StockItemID]           INT           NOT NULL,
    [StockGroupID]          INT           NOT NULL,
    [LastEditedBy]          INT           NOT NULL,
    [LastEditedWhen]        DATETIME2 (7) CONSTRAINT [DF_Warehouse_StockItemStockGroups_LastEditedWhen] DEFAULT (sysdatetime()) NOT NULL,
    CONSTRAINT [PK_Warehouse_StockItemStockGroups] PRIMARY KEY CLUSTERED ([StockItemStockGroupID] ASC),
    CONSTRAINT [FK_Warehouse_StockItemStockGroups_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID]),
    CONSTRAINT [FK_Warehouse_StockItemStockGroups_StockGroupID_Warehouse_StockGroups] FOREIGN KEY ([StockGroupID]) REFERENCES [Warehouse].[StockGroups] ([StockGroupID]),
    CONSTRAINT [FK_Warehouse_StockItemStockGroups_StockItemID_Warehouse_StockItems] FOREIGN KEY ([StockItemID]) REFERENCES [Warehouse].[StockItems] ([StockItemID]),
    CONSTRAINT [UQ_StockItemStockGroups_StockGroupID_Lookup] UNIQUE NONCLUSTERED ([StockGroupID] ASC, [StockItemID] ASC),
    CONSTRAINT [UQ_StockItemStockGroups_StockItemID_Lookup] UNIQUE NONCLUSTERED ([StockItemID] ASC, [StockGroupID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = N''Which stock items are in which stock groups'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItemStockGroups'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Internal reference for this linking row'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItemStockGroups'', @level2type = N''COLUMN'', @level2name = N''StockItemStockGroupID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Stock item assigned to this stock group (FK indexed via unique constraint)'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItemStockGroups'', @level2type = N''COLUMN'', @level2name = N''StockItemID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''StockGroup assigned to this stock item (FK indexed via unique constraint)'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItemStockGroups'', @level2type = N''COLUMN'', @level2name = N''StockGroupID'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Enforces uniqueness and indexes one side of the many to many relationship'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItemStockGroups'', @level2type = N''CONSTRAINT'', @level2name = N''UQ_StockItemStockGroups_StockGroupID_Lookup'';


GO
EXECUTE sp_addextendedproperty @name = N''Description'', @value = ''Enforces uniqueness and indexes one side of the many to many relationship'', @level0type = N''SCHEMA'', @level0name = N''Warehouse'', @level1type = N''TABLE'', @level1name = N''StockItemStockGroups'', @level2type = N''CONSTRAINT'', @level2name = N''UQ_StockItemStockGroups_StockItemID_Lookup'';

')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_d51d5a8aa5a8360c','Public WWI reference: Website/Stored Procedures/InvoiceCustomerOrders.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InvoiceCustomerOrders.sql','09C53C616DD0EE455687AD5D8DE049E4B27A6A75F1904F0FBB489BD4DBDE6811','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.

CREATE PROCEDURE Website.InvoiceCustomerOrders
@OrdersToInvoice Website.OrderIDList READONLY,
@PackedByPersonID int,
@InvoicedByPersonID int
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @InvoicesToGenerate TABLE
    (
        OrderID int PRIMARY KEY,
        InvoiceID int NOT NULL,
        TotalDryItems int NOT NULL,
        TotalChillerItems int NOT NULL
    );

    BEGIN TRY;

        -- Check that all orders exist, have been fully picked, and not already invoiced. Also allocate new invoice numbers.
        INSERT @InvoicesToGenerate (OrderID, InvoiceID, TotalDryItems, TotalChillerItems)
        SELECT oti.OrderID,
               NEXT VALUE FOR Sequences.InvoiceID,
               COALESCE((SELECT SUM(CASE WHEN si.IsChillerStock <> 0 THEN 0 ELSE 1 END)
                         FROM Sales.OrderLines AS ol
                         INNER JOIN Warehouse.StockItems AS si
                         ON ol.StockItemID = si.StockItemID
                         WHERE ol.OrderID = oti.OrderID), 0),
               COALESCE((SELECT SUM(CASE WHEN si.IsChillerStock <> 0 THEN 1 ELSE 0 END)
                         FROM Sales.OrderLines AS ol
                         INNER JOIN Warehouse.StockItems AS si
                         ON ol.StockItemID = si.StockItemID
                         WHERE ol.OrderID = oti.OrderID), 0)
        FROM @OrdersToInvoice AS oti
        INNER JOIN Sales.Orders AS o
        ON oti.OrderID = o.OrderID
        WHERE NOT EXISTS (SELECT 1 FROM Sales.Invoices AS i
                                   WHERE i.OrderID = oti.OrderID)
        AND o.PickingCompletedWhen IS NOT NULL;

        IF EXISTS (SELECT 1 FROM @OrdersToInvoice AS oti WHERE NOT EXISTS (SELECT 1 FROM @InvoicesToGenerate AS itg WHERE itg.OrderID = oti.OrderID))
        BEGIN
            PRINT N''At least one order ID either does not exist, is not picked, or is already invoiced'';
            THROW 51000, N''At least one orderID either does not exist, is not picked, or is already invoiced'', 1;
        END;

        BEGIN TRAN;

        INSERT Sales.Invoices
            (InvoiceID, CustomerID, BillToCustomerID, OrderID, DeliveryMethodID, ContactPersonID, AccountsPersonID,
             SalespersonPersonID, PackedByPersonID, InvoiceDate, CustomerPurchaseOrderNumber,
             IsCreditNote, CreditNoteReason, Comments, DeliveryInstructions, InternalComments,
             TotalDryItems, TotalChillerItems,  DeliveryRun, RunPosition,
             ReturnedDeliveryData,
             LastEditedBy, LastEditedWhen)
        SELECT itg.InvoiceID, c.CustomerID, c.BillToCustomerID, itg.OrderID, c.DeliveryMethodID, o.ContactPersonID, btc.PrimaryContactPersonID,
               o.SalespersonPersonID, @PackedByPersonID, SYSDATETIME(), o.CustomerPurchaseOrderNumber,
               0, NULL, NULL, c.DeliveryAddressLine1 + N'', '' + c.DeliveryAddressLine2, NULL,
               itg.TotalDryItems, itg.TotalChillerItems, c.DeliveryRun, c.RunPosition,
               JSON_MODIFY(N''{"Events": []}'', N''append $.Events'',
                   JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(N''{ }'', N''$.Event'', N''Ready for collection''),
                   N''$.EventTime'', CONVERT(nvarchar(20), SYSDATETIME(), 126)),
                   N''$.ConNote'', N''EAN-125-'' + CAST(itg.InvoiceID + 1050 AS nvarchar(20)))),
               @InvoicedByPersonID, SYSDATETIME()
        FROM @InvoicesToGenerate AS itg
        INNER JOIN Sales.Orders AS o
        ON itg.OrderID = o.OrderID
        INNER JOIN Sales.Customers AS c
        ON o.CustomerID = c.CustomerID
        INNER JOIN Sales.Customers AS btc
        ON btc.CustomerID = c.BillToCustomerID;

        INSERT Sales.InvoiceLines
            (InvoiceID, StockItemID, [Description], PackageTypeID,
             Quantity, UnitPrice, TaxRate, TaxAmount, LineProfit, ExtendedPrice,
             LastEditedBy, LastEditedWhen)
        SELECT itg.InvoiceID, ol.StockItemID, ol.[Description], ol.PackageTypeID,
               ol.PickedQuantity, ol.UnitPrice, ol.TaxRate,
               ROUND(ol.PickedQuantity * ol.UnitPrice * ol.TaxRate / 100.0, 2),
               ROUND(ol.PickedQuantity * (ol.UnitPrice - sih.LastCostPrice), 2),
               ROUND(ol.PickedQuantity * ol.UnitPrice, 2)
                 + ROUND(ol.PickedQuantity * ol.UnitPrice * ol.TaxRate / 100.0, 2),
               @InvoicedByPersonID, SYSDATETIME()
        FROM @InvoicesToGenerate AS itg
        INNER JOIN Sales.OrderLines AS ol
        ON itg.OrderID = ol.OrderID
        INNER JOIN Warehouse.StockItems AS si
        ON ol.StockItemID = si.StockItemID
        INNER JOIN Warehouse.StockItemHoldings AS sih
        ON si.StockItemID = sih.StockItemID
        ORDER BY ol.OrderID, ol.OrderLineID;

        INSERT Warehouse.StockItemTransactions
            (StockItemID, TransactionTypeID, CustomerID, InvoiceID, SupplierID, PurchaseOrderID,
             TransactionOccurredWhen, Quantity, LastEditedBy, LastEditedWhen)
        SELECT il.StockItemID, (SELECT TransactionTypeID FROM [Application].TransactionTypes WHERE TransactionTypeName = N''Stock Issue''),
               i.CustomerID, i.InvoiceID, NULL, NULL,
               SYSDATETIME(), 0 - il.Quantity, @InvoicedByPersonID, SYSDATETIME()
        FROM @InvoicesToGenerate AS itg
        INNER JOIN Sales.InvoiceLines AS il
        ON itg.InvoiceID = il.InvoiceID
        INNER JOIN Sales.Invoices AS i
        ON il.InvoiceID = i.InvoiceID
        ORDER BY il.InvoiceID, il.InvoiceLineID;

        WITH StockItemTotals
        AS
        (
            SELECT il.StockItemID, SUM(il.Quantity) AS TotalQuantity
            FROM Sales.InvoiceLines aS il
            WHERE il.InvoiceID IN (SELECT InvoiceID FROM @InvoicesToGenerate)
            GROUP BY il.StockItemID
        )
        UPDATE sih
        SET sih.QuantityOnHand -= sit.TotalQuantity,
            sih.LastEditedBy = @InvoicedByPersonID,
            sih.LastEditedWhen = SYSDATETIME()
        FROM Warehouse.StockItemHoldings AS sih
        INNER JOIN StockItemTotals AS sit
        ON sih.StockItemID = sit.StockItemID;

        INSERT Sales.CustomerTransactions
            (CustomerID, TransactionTypeID, InvoiceID, PaymentMethodID,
             TransactionDate, AmountExcludingTax, TaxAmount, TransactionAmount,
             OutstandingBalance, FinalizationDate, LastEditedBy, LastEditedWhen)
        SELECT i.BillToCustomerID,
               (SELECT TransactionTypeID FROM [Application].TransactionTypes WHERE TransactionTypeName = N''Customer Invoice''),
               itg.InvoiceID,
               NULL,
               SYSDATETIME(),
               (SELECT SUM(il.ExtendedPrice - il.TaxAmount) FROM Sales.InvoiceLines AS il WHERE il.InvoiceID = itg.InvoiceID),
               (SELECT SUM(il.TaxAmount) FROM Sales.InvoiceLines AS il WHERE il.InvoiceID = itg.InvoiceID),
               (SELECT SUM(il.ExtendedPrice) FROM Sales.InvoiceLines AS il WHERE il.InvoiceID = itg.InvoiceID),
               (SELECT SUM(il.ExtendedPrice) FROM Sales.InvoiceLines AS il WHERE il.InvoiceID = itg.InvoiceID),
               NULL,
               @InvoicedByPersonID,
               SYSDATETIME()
        FROM @InvoicesToGenerate AS itg
        INNER JOIN Sales.Invoices AS i
        ON itg.InvoiceID = i.InvoiceID;

        COMMIT;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        PRINT N''Unable to invoice these orders'';
        THROW;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_8ab0758d6435d38e','Public WWI reference: WebApi/Views/Invoices.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/WebApi/Views/Invoices.sql','1EEE276F10B639F437C6537D69F79BBA6268A0F0B85E38604F13F1A624449669','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.
CREATE VIEW [WebApi].[Invoices]
AS
SELECT  inv.InvoiceID, inv.InvoiceDate, inv.CustomerPurchaseOrderNumber, inv.IsCreditNote, inv.TotalDryItems, inv.TotalChillerItems, inv.DeliveryRun, inv.RunPosition,
        ReturnedDeliveryData = JSON_QUERY(inv.ReturnedDeliveryData), inv.ConfirmedDeliveryTime,
        inv.ConfirmedReceivedBy, c.CustomerName, sp.FullName AS SalesPersonName, contact.FullName AS ContactName, contact.PhoneNumber AS ContactPhone, contact.EmailAddress AS ContactEmail,
        sp.EmailAddress AS SalesPersonEmail, dm.DeliveryMethodName, inv.CustomerID, inv.OrderID, inv.DeliveryMethodID, inv.ContactPersonID, inv.AccountsPersonID, inv.SalespersonPersonID, inv.PackedByPersonID
FROM    Sales.Invoices AS inv INNER JOIN
            Sales.Customers AS c ON inv.CustomerID = c.CustomerID INNER JOIN
            Application.DeliveryMethods AS dm ON inv.DeliveryMethodID = dm.DeliveryMethodID INNER JOIN
            Application.People AS contact ON inv.ContactPersonID = contact.PersonID INNER JOIN
            Application.People AS sp ON inv.SalespersonPersonID = sp.PersonID')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_56491db249850b26','Public WWI reference: WebApi/Views/SalesOrders.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/WebApi/Views/SalesOrders.sql','38122E4CE72B602A4098730C40EB44B3492EE019343DB368EA16EBD557EBE80F','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.
CREATE   VIEW [WebApi].[SalesOrders]
AS
SELECT	o.OrderID, o.OrderDate, o.CustomerPurchaseOrderNumber,
		o.ExpectedDeliveryDate, o.PickingCompletedWhen,
		o.CustomerID, c.CustomerName, c.PhoneNumber, c.FaxNumber, c.WebsiteURL,
		DeliveryLocation = JSON_QUERY((SELECT
				[type] = ''Feature'',
				[geometry.type] = ''Point'',
				[geometry.coordinates] = JSON_QUERY(CONCAT(''['',c.DeliveryLocation.Long,'','',c.DeliveryLocation.Lat ,'']'')),
				[properties.DeliveryMethod] = dm.DeliveryMethodName,
				[properties.AddressLine1] = c.DeliveryAddressLine1,
				[properties.AddressLine2] = c.DeliveryAddressLine2,
				[properties.PostalCode] = c.DeliveryPostalCode,
				[properties.Instructions] = o.DeliveryInstructions
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)),
		SalesPerson = sp.FullName, SalesPersonPhone = sp.PhoneNumber, SalesPersonEmail = sp.EmailAddress
FROM	Sales.Orders o
		INNER JOIN Sales.Customers c
			ON o.CustomerID = c.CustomerID
			LEFT OUTER JOIN [Application].DeliveryMethods AS dm
				ON c.DeliveryMethodID = dm.DeliveryMethodID
		INNER JOIN Application.People sp
			ON o.SalespersonPersonID = sp.PersonID
		')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

MERGE INTO HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG t
USING (SELECT column1 DOC_ID,column2 TITLE,column3 ARTIFACT_TYPE,column4 SOURCE_PATH,column5 SOURCE_VERSION,column6 CONTENT FROM VALUES ('WWI_7191ceb576f8f8dc','Public WWI reference: WebApi/Views/SalesOrderLines.sql','PUBLIC_SQL_REFERENCE','https://raw.githubusercontent.com/microsoft/sql-server-samples/dac9747acaca4e54a3b5ea4c6de1c4be6c1b964a/samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt/WebApi/Views/SalesOrderLines.sql','5408D266D295D16B1E2EA4002227C52C97C7560B05CCE9E8900BA32A6D3354BB','Original Microsoft WWI SQL Server reference; MIT licensed. Not the deployed Snowflake definition. Some dependencies are absent from the simplified synthetic adaptation.
CREATE VIEW [WebApi].[SalesOrderLines]
AS
SELECT	ol.OrderLineID, ol.OrderID, ol.Description, ol.Quantity, ol.UnitPrice, ol.TaxRate, ol.PickingCompletedWhen,
		ProductName = si.StockItemName, si.Brand, si.Size, c.ColorName, pt.PackageTypeName
FROM	Sales.OrderLines ol
		INNER JOIN Warehouse.StockItems si
			ON ol.StockItemID = si.StockItemID
			INNER JOIN Warehouse.Colors c
				ON c.ColorID = si.ColorID
		INNER JOIN Warehouse.PackageTypes pt
			ON ol.PackageTypeID = pt.PackageTypeID
		

')) s
ON t.DOC_ID=s.DOC_ID
WHEN MATCHED THEN UPDATE SET TITLE=s.TITLE,ARTIFACT_TYPE=s.ARTIFACT_TYPE,SOURCE_PATH=s.SOURCE_PATH,SOURCE_VERSION=s.SOURCE_VERSION,CONTENT=s.CONTENT
WHEN NOT MATCHED THEN INSERT (DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT)
VALUES (s.DOC_ID,s.TITLE,s.ARTIFACT_TYPE,s.SOURCE_PATH,s.SOURCE_VERSION,s.CONTENT);

CREATE CORTEX SEARCH SERVICE IF NOT EXISTS HACKATHON_D2K_PREWORK.ANALYTICS.CSS_PREWORK_CATALOG
 ON CONTENT ATTRIBUTES ARTIFACT_TYPE, DOC_ID
 WAREHOUSE=DEFAULT_WH TARGET_LAG='1 day'
 AS SELECT DOC_ID,TITLE,ARTIFACT_TYPE,SOURCE_PATH,SOURCE_VERSION,CONTENT
 FROM HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG;

SELECT 'REPORTS' AS CHECK_NAME, COUNT(*) AS ACTUAL FROM HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG WHERE ARTIFACT_TYPE='SYNTHETIC_REPORT'
UNION ALL SELECT 'PUBLIC_SQL_FILES',COUNT(*) FROM HACKATHON_D2K_PREWORK.ANALYTICS.T_PREWORK_CATALOG WHERE ARTIFACT_TYPE='PUBLIC_SQL_REFERENCE';
SELECT SUM(INVOICE_COUNT) AS INVOICES,SUM(SALES_EXCLUDING_TAX) AS SALES_EXCLUDING_TAX,
 SUM(TAX) AS TAX,SUM(TOTAL_INCLUDING_TAX) AS TOTAL_INCLUDING_TAX
FROM HACKATHON_D2K_PREWORK.ANALYTICS.RPT_DAILY_INVOICE_SALES;