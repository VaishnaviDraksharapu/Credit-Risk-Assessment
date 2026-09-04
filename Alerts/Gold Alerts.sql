-- Databricks notebook source
-- MAGIC %python
-- MAGIC import requests
-- MAGIC
-- MAGIC webhook_url = "your webhook url"
-- MAGIC
-- MAGIC def send_slack_alert(message):
-- MAGIC     response = requests.post(
-- MAGIC         webhook_url,
-- MAGIC         json={"text": message},
-- MAGIC         headers={"Content-Type": "application/json"}
-- MAGIC     )
-- MAGIC
-- MAGIC     print("Status Code:", response.status_code)
-- MAGIC     print("Response:", response.text)

-- COMMAND ----------

SELECT
    table_name,
    column_name,
    data_type
FROM credit_analysis_catalog.information_schema.columns
WHERE table_schema = 'gold'
  AND table_name IN (
      'gold_applicant_risk_kpi',
      'gold_demographic_collateral_kpis',
      'gold_interest_rate_kpis',
      'gold_loan_portfolio_kpis',
      'gold_regional_risk_kpis'
  )
ORDER BY table_name, ordinal_position;