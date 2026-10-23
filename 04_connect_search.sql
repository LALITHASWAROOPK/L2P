-- PREWORK: retain InvoiceData and add basic report/code search. No execution workflow.
USE WAREHOUSE DEFAULT_WH;
ALTER AGENT HACKATHON_D2K_PREWORK.ANALYTICS.PREWORK_QUERY_AGENT
 MODIFY LIVE VERSION SET SPECIFICATION = $$
models:
  orchestration: claude-opus-5-5
instructions:
  response: >-
    Be brief and clearly identify synthetic data and report fixtures. Currency is not
    modeled: never add dollar signs or a currency code. Format tabular answers as
    labeled Markdown tables; disclose partial displays. Offer only configured actions.
    You cannot schedule, create/publish data products or execute arbitrary SQL.
    You can retrieve catalog definitions and query invoice metrics. Do not claim a
    complete lineage trace or reconciliation: those workflows are not configured.
  orchestration: >-
    Use InvoiceData for numeric invoice questions. Sales means excluding tax unless
    otherwise requested. Use ReportCodeSearch for existing reports, descriptions,
    calculations and public reference code. Distinguish SYNTHETIC_REPORT (adapted
    Snowflake report query) from PUBLIC_SQL_REFERENCE (original SQL Server code,
    not deployed here; some dependencies omitted). SYNTHETIC_CONNECTED_METADATA contains
    original fictional HANA-style model definitions, Qlik scripts and normalized Spotfire
    metadata. These are not native validated platform exports or running dashboards.
    Search results are ranked and
    do not prove completeness or absence. Base formula explanations on returned
    definitions; state missing evidence instead of guessing. Data-product requests
    can receive relevant definitions and proposed SQL, but never a claim of creation,
    execution, validation or scheduling. Do not dump daily data unless requested.
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: InvoiceData
      description: 'Query synthetic invoices by customer, product and date. Sales excludes tax unless named including tax.'
  - tool_spec:
      type: cortex_search
      name: ReportCodeSearch
      description: 'Find synthetic sales reports, connected HANA-style/Qlik/Spotfire metadata and preserved Microsoft WWI SQL reference by business wording, report name, field or calculation. Not a full lineage engine or exhaustive catalog.'
tool_resources:
  InvoiceData:
    semantic_view: HACKATHON_D2K_PREWORK.ANALYTICS.SV_INVOICE_STARTER
    execution_environment:
      type: warehouse
      warehouse: DEFAULT_WH
  ReportCodeSearch:
    search_service: HACKATHON_D2K_PREWORK.ANALYTICS.CSS_PREWORK_CATALOG
    max_results: 5
    title_column: TITLE
    id_column: DOC_ID
    columns_and_descriptions:
      CONTENT:
        description: 'Complete short report definition or public SQL reference, including provenance and limitations.'
      ARTIFACT_TYPE:
        description: 'SYNTHETIC_REPORT, PUBLIC_SQL_REFERENCE or SYNTHETIC_CONNECTED_METADATA. Filter by type when seeking reports versus reference code.'
      SOURCE_PATH:
        description: 'Local relative report file or public pinned Microsoft source URL.'
      SOURCE_VERSION:
        description: 'SHA256 of the source definition.'
$$;
ALTER AGENT HACKATHON_D2K_PREWORK.ANALYTICS.PREWORK_QUERY_AGENT
 SET COMMENT='Prework starter: invoice queries and synthetic report/public SQL search. No custom lineage engine, product publishing, scheduling or write tool.';
