-- Restore the baseline specification; retain catalog artifacts for inspection.
ALTER AGENT HACKATHON_D2K_PREWORK.ANALYTICS.PREWORK_QUERY_AGENT
 MODIFY LIVE VERSION SET SPECIFICATION = $$
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
