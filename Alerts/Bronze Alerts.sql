-- Databricks notebook source
-- MAGIC %python
-- MAGIC import requests
-- MAGIC
-- MAGIC webhook_url = "your webhook url"
-- MAGIC
-- MAGIC def send_alert(message):
-- MAGIC     response = requests.post(
-- MAGIC         webhook_url,
-- MAGIC         json={"text": message}
-- MAGIC     )
-- MAGIC     print(response.status_code)

-- COMMAND ----------

SHOW TABLES IN credit_analysis_catalog.bronze;

-- COMMAND ----------

-- MAGIC %python
-- MAGIC tables = [
-- MAGIC     "applicant_profiles",
-- MAGIC     "credit_application",
-- MAGIC     "credit_history",
-- MAGIC     "economic_indicators",
-- MAGIC     "loan_details"
-- MAGIC ]
-- MAGIC
-- MAGIC for table in tables:
-- MAGIC     count = spark.sql(f"""
-- MAGIC         SELECT COUNT(*) AS cnt
-- MAGIC         FROM credit_analysis_catalog.bronze.{table}
-- MAGIC     """).collect()[0]["cnt"]
-- MAGIC
-- MAGIC     print(f"{table}: {count} records")

-- COMMAND ----------

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
-- MAGIC     if response.status_code == 200:
-- MAGIC         print("✅ Slack alert sent")
-- MAGIC     else:
-- MAGIC         print("❌ Slack alert failed")
-- MAGIC         print(response.text)

-- COMMAND ----------

-- MAGIC %python
-- MAGIC tables = [
-- MAGIC     "applicant_profiles",
-- MAGIC     "credit_application",
-- MAGIC     "credit_history",
-- MAGIC     "economic_indicators",
-- MAGIC     "loan_details"
-- MAGIC ]
-- MAGIC
-- MAGIC for table in tables:
-- MAGIC     count = spark.sql(f"""
-- MAGIC         SELECT COUNT(*) AS cnt
-- MAGIC         FROM credit_analysis_catalog.bronze.{table}
-- MAGIC     """).collect()[0]["cnt"]
-- MAGIC
-- MAGIC     print(f"{table}: {count} records")

-- COMMAND ----------

-- MAGIC %python
-- MAGIC tables = [
-- MAGIC     "applicant_profiles",
-- MAGIC     "credit_application",
-- MAGIC     "credit_history",
-- MAGIC     "economic_indicators",
-- MAGIC     "loan_details"
-- MAGIC ]
-- MAGIC
-- MAGIC empty_tables = []
-- MAGIC
-- MAGIC for table in tables:
-- MAGIC
-- MAGIC     count = spark.sql(f"""
-- MAGIC         SELECT COUNT(*) AS cnt
-- MAGIC         FROM credit_analysis_catalog.bronze.{table}
-- MAGIC     """).collect()[0]["cnt"]
-- MAGIC
-- MAGIC     print(f"{table}: {count} records")
-- MAGIC
-- MAGIC     if count == 0:
-- MAGIC         empty_tables.append(table)

-- COMMAND ----------

-- MAGIC %python
-- MAGIC
-- MAGIC if empty_tables:
-- MAGIC
-- MAGIC     test_message = """
-- MAGIC 🚨 CREDIT ANALYSIS — BRONZE ALERT TEST
-- MAGIC
-- MAGIC This is a test message from the Bronze Alerts notebook.
-- MAGIC
-- MAGIC Databricks → Python → Slack Webhook is working.
-- MAGIC """
-- MAGIC
-- MAGIC     send_slack_alert(message)
-- MAGIC
-- MAGIC else:
-- MAGIC
-- MAGIC     print("✅ Bronze Alert Check Passed")
-- MAGIC     print("All Bronze tables contain data.")

-- COMMAND ----------

-- MAGIC %python
-- MAGIC import requests
-- MAGIC
-- MAGIC test_url = webhook_url
-- MAGIC
-- MAGIC payload = {
-- MAGIC     "text": "🚨 TEST - Credit Analysis Databricks Alert"
-- MAGIC }
-- MAGIC
-- MAGIC response = requests.post(
-- MAGIC     test_url,
-- MAGIC     json=payload,
-- MAGIC     headers={"Content-Type": "application/json"}
-- MAGIC )
-- MAGIC
-- MAGIC print("Status Code:", response.status_code)
-- MAGIC print("Response:", response.text)

-- COMMAND ----------

-- MAGIC %python
-- MAGIC empty_tables = []
-- MAGIC
-- MAGIC for table, count in table_counts.items():
-- MAGIC
-- MAGIC     if count == 0:
-- MAGIC         empty_tables.append(table)
-- MAGIC
-- MAGIC
-- MAGIC if empty_tables:
-- MAGIC
-- MAGIC     message = f"""
-- MAGIC 🚨 CREDIT ANALYSIS — BRONZE ALERT
-- MAGIC
-- MAGIC Empty Bronze tables detected:
-- MAGIC
-- MAGIC {chr(10).join("• " + table for table in empty_tables)}
-- MAGIC
-- MAGIC ⚠️ Data ingestion may have failed.
-- MAGIC Please check the Bronze pipeline.
-- MAGIC """
-- MAGIC
-- MAGIC     send_slack_alert(message)
-- MAGIC
-- MAGIC else:
-- MAGIC
-- MAGIC     print("✅ BRONZE CHECK PASSED")
-- MAGIC     print("All Bronze tables contain data.")

-- COMMAND ----------

-- MAGIC %python
-- MAGIC # Check applicant_profiles
-- MAGIC
-- MAGIC count = spark.sql("""
-- MAGIC     SELECT COUNT(*) AS cnt
-- MAGIC     FROM credit_analysis_catalog.bronze.applicant_profiles
-- MAGIC """).collect()[0]["cnt"]
-- MAGIC
-- MAGIC print("Applicant Profiles Count:", count)

-- COMMAND ----------

-- MAGIC %python
-- MAGIC if count >= 0:
-- MAGIC
-- MAGIC     message = f"""
-- MAGIC 🚨 CREDIT ANALYSIS — BRONZE ALERT TEST
-- MAGIC
-- MAGIC Table: applicant_profiles
-- MAGIC Records: {count}
-- MAGIC
-- MAGIC ⚠️ Test condition triggered successfully.
-- MAGIC """
-- MAGIC
-- MAGIC     send_slack_alert(message)
-- MAGIC
-- MAGIC else:
-- MAGIC     print("No alert")