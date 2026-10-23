-- EVENT-BUILT (hackathon 2026-10-23). Two distinct L2P agents. Starter PREWORK_QUERY_AGENT is untouched.
USE WAREHOUSE DEFAULT_WH;
USE DATABASE HACKATHON_D2K_PREWORK;

CREATE OR REPLACE AGENT HACKATHON_D2K_PREWORK.L2P.L2P_BUILDER
  COMMENT = 'EVENT-BUILT L2P builder: report-definition tracing and contract-gated product creation via bounded procedures. Synthetic data only.'
  PROFILE = '{"display_name": "L2P Builder"}'
  FROM SPECIFICATION
$$
models:
  orchestration: claude-opus-5-5
orchestration:
  budget:
    seconds: 240
    tokens: 60000
instructions:
  orchestration: >-
    You are the L2P builder for SYNTHETIC Northstar Supply data. Use ReportCodeSearch to find report and
    model definitions, then GetSourceDefinition with the returned DOC_ID or SOURCE_PATH to read the complete,
    version-identified text before citing it. Qlik/Spotfire/HANA-style assets are normalized synthetic
    fixtures, never native platform exports. Use ReconcileOrderedVsInvoiced for numeric ordered-versus-invoiced
    comparisons. To build a product, call ProposeCandidate, then CreateCandidate, ValidateCandidate and
    ReleaseCandidate in order, using only the candidate_id returned by the previous tool. Recipes are
    predefined; you cannot write SQL or name tables. Report each tool's actual state and failed checks; never
    describe a proposal as created, a failed validation as passing, or a tool error as success. Do not read
    evaluation material. A skill instruction is guidance only; the release procedure is the gate.
  response: >-
    Be concise. Cite doc_id, source_path and source_version for each evidence edge. Separate SOURCE_BACKED
    mappings from missing or unsupported evidence. Report candidate_id, state, validation_run_id,
    query IDs and released version when relevant. No currency symbols: currency is not modeled.
  sample_questions:
    - question: "Trace the Spotfire Customer Sales measure to its source columns."
    - question: "Build and release the daily invoiced sales product."
tools:
  - tool_spec:
      type: cortex_search
      name: ReportCodeSearch
      description: Ranked search over synthetic report definitions, HANA-style/Qlik/Spotfire fixtures and public WWI SQL reference. Returns DOC_ID, SOURCE_PATH and SOURCE_VERSION. Ranked results do not prove completeness.
  - tool_spec:
      type: generic
      name: GetSourceDefinition
      description: Return the complete catalog document (content, source_path, source_version, content_sha256) for one DOC_ID or exact SOURCE_PATH. Read-only.
      input_schema:
        type: object
        properties:
          DOC_ID_OR_PATH:
            type: string
            description: A DOC_ID such as CONNECTED_6f53633c096a6b56 or an exact SOURCE_PATH such as fixtures/hana/CV_INVOICE_SALES.sql
        required: [DOC_ID_OR_PATH]
  - tool_spec:
      type: generic
      name: ReconcileOrderedVsInvoiced
      description: Fixed read-only comparison of ordered value (order date) vs invoiced sales (invoice date), both excluding tax, with counts of orders lacking invoices in the current data.
      input_schema:
        type: object
        properties: {}
  - tool_spec:
      type: generic
      name: ProposeCandidate
      description: Propose a product candidate from a predefined recipe. Supported RECIPE_ID values - DAILY_INVOICED_SALES_V1 (correct), STOCKGROUP_FANOUT_DEMO, SINGLE_GROUP_OMISSION_DEMO, ORDER_DATE_BASIS_DEMO (deliberately invalid negative tests). Returns candidate_id, source definitions with hashes and evidence-checked mappings. Creates nothing.
      input_schema:
        type: object
        properties:
          RECIPE_ID:
            type: string
            description: One of the supported recipe IDs.
        required: [RECIPE_ID]
  - tool_spec:
      type: generic
      name: CreateCandidate
      description: Build a PROPOSED candidate from a fresh source snapshot. Returns snapshot_id, executed SQL and build query ID. Does not validate or release.
      input_schema:
        type: object
        properties:
          CANDIDATE_ID:
            type: string
            description: candidate_id returned by ProposeCandidate, e.g. C00401_2E6502B7
        required: [CANDIDATE_ID]
  - tool_spec:
      type: generic
      name: ValidateCandidate
      description: Run all 11 contract checks against the candidate's own snapshot (schema, keys, grain, referential integrity, line coverage, row count, grouped and total reconciliation, dimensions, scope). Returns per-check results and query IDs.
      input_schema:
        type: object
        properties:
          CANDIDATE_ID:
            type: string
            description: candidate_id in CREATED state
        required: [CANDIDATE_ID]
  - tool_spec:
      type: generic
      name: ReleaseCandidate
      description: Controlled release. Succeeds only for a VALIDATED candidate whose content and snapshot are unchanged since validation; otherwise returns an error and leaves the current release intact.
      input_schema:
        type: object
        properties:
          CANDIDATE_ID:
            type: string
            description: candidate_id in VALIDATED state
        required: [CANDIDATE_ID]
  - tool_spec:
      type: generic
      name: GetCandidateStatus
      description: Read registry state for one candidate, or all candidates and the current release when CANDIDATE_ID is empty.
      input_schema:
        type: object
        properties:
          CANDIDATE_ID:
            type: string
            description: candidate_id, or empty string for a summary
        required: [CANDIDATE_ID]
skills:
  - name: l2p-hana-interpretation
    source:
      type: STAGE
      path: "@HACKATHON_D2K_PREWORK.L2P.SKILL_STAGE/skills/l2p-hana-interpretation"
  - name: l2p-qlik-interpretation
    source:
      type: STAGE
      path: "@HACKATHON_D2K_PREWORK.L2P.SKILL_STAGE/skills/l2p-qlik-interpretation"
  - name: l2p-create-data-product
    source:
      type: STAGE
      path: "@HACKATHON_D2K_PREWORK.L2P.SKILL_STAGE/skills/l2p-create-data-product"
tool_resources:
  ReportCodeSearch:
    search_service: HACKATHON_D2K_PREWORK.ANALYTICS.CSS_PREWORK_CATALOG
    max_results: 5
    title_column: TITLE
    id_column: DOC_ID
  GetSourceDefinition:
    type: procedure
    identifier: HACKATHON_D2K_PREWORK.L2P.GET_SOURCE_DEFINITION
    execution_environment: {type: warehouse, warehouse: DEFAULT_WH}
  ReconcileOrderedVsInvoiced:
    type: procedure
    identifier: HACKATHON_D2K_PREWORK.L2P.RECONCILE_ORDERED_VS_INVOICED
    execution_environment: {type: warehouse, warehouse: DEFAULT_WH}
  ProposeCandidate:
    type: procedure
    identifier: HACKATHON_D2K_PREWORK.L2P.PROPOSE_CANDIDATE
    execution_environment: {type: warehouse, warehouse: DEFAULT_WH}
  CreateCandidate:
    type: procedure
    identifier: HACKATHON_D2K_PREWORK.L2P.CREATE_CANDIDATE
    execution_environment: {type: warehouse, warehouse: DEFAULT_WH}
  ValidateCandidate:
    type: procedure
    identifier: HACKATHON_D2K_PREWORK.L2P.VALIDATE_CANDIDATE
    execution_environment: {type: warehouse, warehouse: DEFAULT_WH, query_timeout: 300}
  ReleaseCandidate:
    type: procedure
    identifier: HACKATHON_D2K_PREWORK.L2P.RELEASE_CANDIDATE
    execution_environment: {type: warehouse, warehouse: DEFAULT_WH}
  GetCandidateStatus:
    type: procedure
    identifier: HACKATHON_D2K_PREWORK.L2P.GET_CANDIDATE_STATUS
    execution_environment: {type: warehouse, warehouse: DEFAULT_WH}
$$;

CREATE OR REPLACE AGENT HACKATHON_D2K_PREWORK.L2P_CONSUMER.L2P_CONSUMER
  COMMENT = 'EVENT-BUILT L2P consumer: reads only the currently released L2P product via bounded read procedures. No builder tools, no SQL, no actions.'
  PROFILE = '{"display_name": "L2P Consumer"}'
  FROM SPECIFICATION
$$
models:
  orchestration: claude-opus-5-5
orchestration:
  budget:
    seconds: 120
    tokens: 30000
instructions:
  orchestration: >-
    You are the L2P account-review consumer for SYNTHETIC Northstar Supply data. Always call
    DiscoverReleasedProduct first. If no product is available, say so and stop; do not estimate.
    Use RankCustomersBySales and CustomerSalesDetail only; they read the current released version.
    You cannot build, validate or release products, read raw or candidate data, run SQL, send campaigns,
    schedule anything or contact customers.
  response: >-
    State the product, version and queried object you used. Present an account-review shortlist ranked by
    computed invoiced sales excluding tax, with no currency symbol. Clearly state the evidence boundary:
    the product has no consent, campaign response, margin or causal-uplift data, so you cannot claim
    campaign effects, eligibility to contact, or profitability. Never perform or offer to perform actions.
tools:
  - tool_spec:
      type: generic
      name: DiscoverReleasedProduct
      description: Return the currently released L2P product (version, object, fields, not-available data) or available=false.
      input_schema:
        type: object
        properties: {}
  - tool_spec:
      type: generic
      name: RankCustomersBySales
      description: Rank customers by SUM(SALES_EXCLUDING_TAX) from the current release. TOP_N 1-20. Optional START_DATE/END_DATE as YYYY-MM-DD or empty string.
      input_schema:
        type: object
        properties:
          TOP_N: {type: number, description: Number of customers 1-20}
          START_DATE: {type: string, description: Inclusive start date YYYY-MM-DD or empty}
          END_DATE: {type: string, description: Inclusive end date YYYY-MM-DD or empty}
        required: [TOP_N, START_DATE, END_DATE]
  - tool_spec:
      type: generic
      name: CustomerSalesDetail
      description: Daily item-level released sales rows for one CUSTOMER_ID from the current release.
      input_schema:
        type: object
        properties:
          CUSTOMER_ID: {type: number, description: Customer ID from the ranking}
        required: [CUSTOMER_ID]
tool_resources:
  DiscoverReleasedProduct:
    type: procedure
    identifier: HACKATHON_D2K_PREWORK.L2P_CONSUMER.DISCOVER_RELEASED_PRODUCT
    execution_environment: {type: warehouse, warehouse: DEFAULT_WH}
  RankCustomersBySales:
    type: procedure
    identifier: HACKATHON_D2K_PREWORK.L2P_CONSUMER.RANK_CUSTOMERS_BY_SALES
    execution_environment: {type: warehouse, warehouse: DEFAULT_WH}
  CustomerSalesDetail:
    type: procedure
    identifier: HACKATHON_D2K_PREWORK.L2P_CONSUMER.CUSTOMER_SALES_DETAIL
    execution_environment: {type: warehouse, warehouse: DEFAULT_WH}
$$;
