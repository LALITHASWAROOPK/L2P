-- EVENT-BUILT (hackathon 2026-10-23). L2P consumer tools: released-product discovery and bounded reads only.
-- Reads only the object named by L2P.RELEASES where IS_CURRENT, after verifying its content hash.
USE WAREHOUSE DEFAULT_WH;
USE DATABASE HACKATHON_D2K_PREWORK;

-- Tool: discover the currently released product (or report none).
CREATE OR REPLACE PROCEDURE L2P_CONSUMER.DISCOVER_RELEASED_PRODUCT()
RETURNS VARCHAR LANGUAGE SQL EXECUTE AS OWNER AS
$$
DECLARE
  n NUMBER;
  obj VARCHAR;
  dr VARCHAR;
  out VARIANT;
  flds VARIANT;
BEGIN
  SELECT COUNT(*) INTO :n FROM L2P.RELEASES WHERE PRODUCT = 'DAILY_INVOICED_SALES' AND IS_CURRENT;
  IF (n = 0) THEN
    RETURN TO_JSON(OBJECT_CONSTRUCT('available', FALSE, 'products', ARRAY_CONSTRUCT(),
      'note', 'No product has passed validation and been released. No data can be queried.'));
  END IF;
  SELECT RELEASE_OBJECT INTO :obj FROM L2P.RELEASES WHERE PRODUCT = 'DAILY_INVOICED_SALES' AND IS_CURRENT;
  SELECT MIN(INVOICE_DATE)||'..'||MAX(INVOICE_DATE) INTO :dr FROM IDENTIFIER(:obj);
  SELECT OBJECT_CONSTRUCT('available', TRUE, 'product', r.PRODUCT, 'version', r.VERSION,
           'release_object', r.RELEASE_OBJECT, 'released_at', r.RELEASED_AT, 'row_count', r.ROW_COUNT,
           'content_hash', r.CONTENT_HASH, 'validation_run_id', r.VALIDATION_RUN_ID, 'source_snapshot_id', r.SNAPSHOT_ID,
           'grain', ARRAY_CONSTRUCT('INVOICE_DATE','CUSTOMER_ID','STOCK_ITEM_ID'),
           'not_available', ARRAY_CONSTRUCT('currency','margin','marketing consent','campaign response','causal uplift','returns','discounts','calendar zero-fill'),
           'date_range', :dr)
    INTO :out FROM L2P.RELEASES r WHERE r.PRODUCT = 'DAILY_INVOICED_SALES' AND r.IS_CURRENT;
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT('name', FIELD_NAME, 'type', DATA_TYPE, 'definition', SOURCE_EXPRESSION)) WITHIN GROUP (ORDER BY ORDINAL)
    INTO :flds FROM L2P.CONTRACT_FIELDS WHERE PRODUCT = 'DAILY_INVOICED_SALES' AND CONTRACT_VERSION = 1;
  RETURN TO_JSON(OBJECT_INSERT(:out, 'fields', :flds));
END;
$$;

-- Tool: rank customers by computed invoiced sales from the current release only.
CREATE OR REPLACE PROCEDURE L2P_CONSUMER.RANK_CUSTOMERS_BY_SALES(TOP_N NUMBER, START_DATE VARCHAR, END_DATE VARCHAR)
RETURNS VARCHAR LANGUAGE SQL EXECUTE AS OWNER AS
$$
DECLARE
  n NUMBER;
  ver NUMBER;
  obj VARCHAR;
  rec_hash VARCHAR;
  now_hash VARCHAR;
  d0 DATE;
  d1 DATE;
  k NUMBER;
  res VARIANT;
  qid VARCHAR;
BEGIN
  SELECT COUNT(*) INTO :n FROM L2P.RELEASES WHERE PRODUCT = 'DAILY_INVOICED_SALES' AND IS_CURRENT;
  IF (n = 0) THEN
    RETURN TO_JSON(OBJECT_CONSTRUCT('ok', FALSE, 'error', 'NO_RELEASED_PRODUCT', 'note', 'Nothing has been released; no ranking is possible.'));
  END IF;
  SELECT VERSION, RELEASE_OBJECT, CONTENT_HASH INTO :ver, :obj, :rec_hash FROM L2P.RELEASES WHERE PRODUCT = 'DAILY_INVOICED_SALES' AND IS_CURRENT;
  IF (NOT REGEXP_LIKE(:obj, '^HACKATHON_D2K_PREWORK\\.L2P_RELEASE\\.DAILY_INVOICED_SALES_V[0-9]{4}$')) THEN
    RETURN TO_JSON(OBJECT_CONSTRUCT('ok', FALSE, 'error', 'RELEASE_POINTER_INVALID'));
  END IF;
  SELECT HASH_AGG(*)::VARCHAR INTO :now_hash FROM IDENTIFIER(:obj);
  IF (NOT EQUAL_NULL(now_hash, rec_hash)) THEN
    RETURN TO_JSON(OBJECT_CONSTRUCT('ok', FALSE, 'error', 'RELEASED_DATA_CHANGED_SINCE_RELEASE', 'version', :ver,
      'note', 'Released object no longer matches its release hash; refusing to serve it.'));
  END IF;
  k := LEAST(GREATEST(COALESCE(:TOP_N, 10), 1), 20);
  d0 := TRY_TO_DATE(NULLIF(:START_DATE, ''));
  d1 := TRY_TO_DATE(NULLIF(:END_DATE, ''));
  IF ((NULLIF(:START_DATE, '') IS NOT NULL AND d0 IS NULL) OR (NULLIF(:END_DATE, '') IS NOT NULL AND d1 IS NULL)) THEN
    RETURN TO_JSON(OBJECT_CONSTRUCT('ok', FALSE, 'error', 'INVALID_DATE', 'expected_format', 'YYYY-MM-DD'));
  END IF;
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT('rank', RNK, 'customer_id', CUSTOMER_ID, 'customer_name', CUSTOMER_NAME,
           'sales_excluding_tax', SALES, 'invoice_lines', LINES, 'active_days', DAYS, 'distinct_items', ITEMS,
           'first_invoice_date', FIRST_D, 'last_invoice_date', LAST_D)) WITHIN GROUP (ORDER BY RNK)
    INTO :res
    FROM (SELECT CUSTOMER_ID, ANY_VALUE(CUSTOMER_NAME) CUSTOMER_NAME, SUM(SALES_EXCLUDING_TAX) SALES, SUM(INVOICE_LINE_COUNT) LINES,
                 COUNT(DISTINCT INVOICE_DATE) DAYS, COUNT(DISTINCT STOCK_ITEM_ID) ITEMS, MIN(INVOICE_DATE) FIRST_D, MAX(INVOICE_DATE) LAST_D,
                 RANK() OVER (ORDER BY SUM(SALES_EXCLUDING_TAX) DESC) RNK
            FROM IDENTIFIER(:obj)
           WHERE (:d0 IS NULL OR INVOICE_DATE >= :d0) AND (:d1 IS NULL OR INVOICE_DATE <= :d1)
           GROUP BY CUSTOMER_ID
          QUALIFY RNK <= :k);
  qid := LAST_QUERY_ID();
  RETURN TO_JSON(OBJECT_CONSTRUCT('ok', TRUE, 'product', 'DAILY_INVOICED_SALES', 'version', :ver, 'queried_object', :obj,
    'content_hash_verified', :now_hash, 'query_id', :qid, 'top_n', :k, 'start_date', :d0, 'end_date', :d1,
    'measure', 'SUM(SALES_EXCLUDING_TAX) = invoice ExtendedPrice minus TaxAmount; no currency modeled',
    'ranking', COALESCE(:res, ARRAY_CONSTRUCT()),
    'evidence_boundary', 'Ranking is by computed invoiced sales only. No consent, campaign response, margin or uplift data exists in this product.'));
END;
$$;

-- Tool: daily sales for one customer from the current release only (bounded drill-down).
CREATE OR REPLACE PROCEDURE L2P_CONSUMER.CUSTOMER_SALES_DETAIL(CUSTOMER_ID NUMBER)
RETURNS VARCHAR LANGUAGE SQL EXECUTE AS OWNER AS
$$
DECLARE
  n NUMBER;
  ver NUMBER;
  obj VARCHAR;
  rec_hash VARCHAR;
  now_hash VARCHAR;
  res VARIANT;
BEGIN
  SELECT COUNT(*) INTO :n FROM L2P.RELEASES WHERE PRODUCT = 'DAILY_INVOICED_SALES' AND IS_CURRENT;
  IF (n = 0) THEN RETURN TO_JSON(OBJECT_CONSTRUCT('ok', FALSE, 'error', 'NO_RELEASED_PRODUCT')); END IF;
  SELECT VERSION, RELEASE_OBJECT, CONTENT_HASH INTO :ver, :obj, :rec_hash FROM L2P.RELEASES WHERE PRODUCT = 'DAILY_INVOICED_SALES' AND IS_CURRENT;
  IF (NOT REGEXP_LIKE(:obj, '^HACKATHON_D2K_PREWORK\\.L2P_RELEASE\\.DAILY_INVOICED_SALES_V[0-9]{4}$')) THEN
    RETURN TO_JSON(OBJECT_CONSTRUCT('ok', FALSE, 'error', 'RELEASE_POINTER_INVALID'));
  END IF;
  SELECT HASH_AGG(*)::VARCHAR INTO :now_hash FROM IDENTIFIER(:obj);
  IF (NOT EQUAL_NULL(now_hash, rec_hash)) THEN
    RETURN TO_JSON(OBJECT_CONSTRUCT('ok', FALSE, 'error', 'RELEASED_DATA_CHANGED_SINCE_RELEASE', 'version', :ver));
  END IF;
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT('invoice_date', INVOICE_DATE, 'stock_item_id', STOCK_ITEM_ID, 'stock_item_name', STOCK_ITEM_NAME,
           'quantity', QUANTITY, 'sales_excluding_tax', SALES_EXCLUDING_TAX)) WITHIN GROUP (ORDER BY INVOICE_DATE, STOCK_ITEM_ID)
    INTO :res FROM IDENTIFIER(:obj) WHERE CUSTOMER_ID = :CUSTOMER_ID;
  RETURN TO_JSON(OBJECT_CONSTRUCT('ok', TRUE, 'version', :ver, 'queried_object', :obj, 'query_id', LAST_QUERY_ID(),
    'customer_id', :CUSTOMER_ID, 'rows', COALESCE(:res, ARRAY_CONSTRUCT())));
END;
$$;
