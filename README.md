# 💳 Credit Risk Assessment Pipeline

## 🚀 Project Overview

The **Credit Risk Assessment Pipeline** is an end-to-end Data Engineering and Analytics project designed to ingest credit and loan datasets, process them through a layered data architecture, apply cleansing and transformation rules, build dimensional and fact models, and deliver analytics-ready datasets for credit risk reporting.

The solution is designed around **Azure Data Factory, ADLS Gen2, Databricks, PySpark, Delta Lake, dbt, data quality testing, dashboards, alerts, and monitoring**.

The project follows a **Bronze → Silver → Gold** layered architecture:

**Source CSV Files → ADF Ingestion → ADLS Gen2 → Bronze → Silver → Gold → Analytics Dashboards**

---

## 🎯 Project Objectives

- Build a structured pipeline for credit, applicant, loan, credit-history, and economic datasets.
- Ingest source CSV files into the Azure data platform.
- Preserve raw data in the Bronze layer with ingestion metadata.
- Clean, standardize, validate, and transform data in the Silver layer.
- Build reusable **dimension and fact tables** in the Gold layer.
- Apply data quality and validation checks across pipeline layers.
- Create analytics-ready datasets for credit risk and loan portfolio reporting.
- Provide dashboards for applicant, loan, credit, risk, and financial analysis.
- Implement alerts, logging, monitoring, and audit/lineage practices.

---

## 🏗️ High-Level Architecture

The repository contains a high-level Azure architecture showing the complete flow from source datasets through ingestion, ADLS Gen2 storage, Databricks processing, analytics, monitoring, alerts, testing, and consumption.

![Credit Risk Assessment Pipeline - High Level Architecture](Design/high_level_design.png)

### End-to-End Flow

```text
Source CSV Files
       ↓
Azure Data Factory
       ↓
ADLS Gen2 - Raw / Landing
       ↓
Bronze Layer
       ↓
Silver Layer
       ↓
Gold Layer
       ↓
Databricks Dashboards / Analytics
       ↓
Monitoring + Alerts + Audit
```

---

## 🧩 Low-Level Design

The Low-Level Design documents the detailed metadata, ingestion design, ADLS Gen2 storage layout, Bronze and Silver processing, source-to-target mapping, dimensional modeling, fact modeling, data quality, error handling, monitoring, and audit/lineage.

![Credit Risk Assessment Pipeline - Low Level Design](Design/low_level_design.png)

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| **Azure Data Factory** | Source ingestion and pipeline activities |
| **ADLS Gen2** | Raw and layered data storage |
| **Databricks** | Data processing and analytics |
| **PySpark** | Distributed data transformation |
| **Delta Lake** | Bronze, Silver, and Gold table storage |
| **dbt** | SQL-based transformation and dimensional modelling |
| **Apache Airflow** | Orchestration represented in the solution architecture |
| **Git / GitHub** | Version control and project management |
| **Databricks Dashboards** | Analytics and reporting |
| **Alerts / Monitoring** | Pipeline and data-quality notifications |

---

## 📂 Source Datasets

The repository contains five source CSV datasets under `Datasets/Source/`:

| Dataset | Purpose |
|---|---|
| `applicant_profiles.csv` | Applicant demographic and personal information |
| `credit_applications data.csv` | Loan / credit application information |
| `credit_history.csv` | Applicant credit history and repayment information |
| `loan_details.csv` | Loan and repayment details |
| `economic_indicators_.csv` | Economic indicators used for enrichment |

The source layer is maintained separately from the transformation code.

---

# 🥉 Bronze Layer – Raw Data Ingestion

The Bronze layer stores the ingested source data with minimal transformation.

### Bronze Processing

- Read source data from the raw/landing zone.
- Preserve the source structure.
- Add ingestion metadata.
- Store data as Delta tables.
- Record row counts and ingestion information.
- Keep the data available for downstream processing.

### Bronze Development

The repository contains dedicated notebooks for the Bronze datasets:

- `Applicant_profiles.dbquery.ipynb`
- `Credit_Applications.dbquery.ipynb`
- `Credit_History.dbquery.ipynb`
- `Economic_Indicators.dbquery.ipynb`
- `Loan_Details.dbquery.ipynb`

These notebooks are stored under `Development/Bronze/`.

---

# 🥈 Silver Layer – Data Cleaning & Transformation

The Silver layer converts raw Bronze data into standardized and validated datasets.

### Key Activities

- Data cleansing
- Data type standardization
- Null handling
- Deduplication
- Range validation
- Business-rule validation
- Standardization of categorical values
- Joins and enrichment
- Writing cleaned Delta tables

### Silver Models

The repository contains SQL models for:

- `silver_applicant_profiles`
- `silver_credit_applications`
- `silver_credit_history`
- `silver_economic_indicators`
- `silver_loan_details`

These models are stored under `Development/Silver/`.

---

# 🥇 Gold Layer – Dimensional Model & Analytics

The Gold layer provides business-ready dimensional and fact tables.

## ⭐ Data Model

The project follows a **Star Schema** with four dimensions connected to a central credit application fact table.

![Credit Risk Analytics - Dimensional Data Model](Design/data_model_diagram.png)

### Dimension Tables

- `DIM_APPLICANT`
- `DIM_LOAN`
- `DIM_CREDIT_PROFILE`
- `DIM_ECONOMIC`

The corresponding SQL models are stored under `Development/Gold/Dimension Tables/`.

### Fact Table

- `FACT_CREDIT_APPLICATION`

The fact model is stored under `Development/Gold/Fact Tables/`.

### Fact Grain

**One row per credit / loan application.**

### Key Relationships

```text
                 DIM_APPLICANT
                       │
                       │
                       ▼
DIM_CREDIT_PROFILE → FACT_CREDIT_APPLICATION ← DIM_LOAN
                       ▲
                       │
                       │
                 DIM_ECONOMIC
```

---

# 🔄 Source-to-Target Transformation

The pipeline defines source-to-target mappings for important credit application attributes.

Typical transformation rules represented in the design include:

- Trimming and standardizing text values.
- Converting values to required data types.
- Standardizing dates.
- Validating monetary amounts.
- Validating interest-rate ranges.
- Applying business rules.
- Mapping source identifiers to dimensional keys.
- Handling null values according to defined rules.

---

# 🧪 Data Quality & Testing

Data quality is treated as a cross-layer capability.

### Validation Areas

- Schema validation
- Null checks
- Duplicate checks
- Range checks
- Referential checks
- Business-rule validation
- Row-count validation
- Transformation validation

### Test Notebooks

The repository contains:

- `Test Bronze.ipynb`
- `Test Silver.ipynb`
- `Test Gold.ipynb`

under `Tests/`.

---

# ⚠️ Alerts & Error Handling

The repository contains layer-specific SQL alert definitions:

- `Bronze Alerts.sql`
- `Silver Alerts.sql`
- `Gold Alerts.sql`

These are maintained under `Alerts/`.

The design also includes handling for invalid records, quarantine/reject paths, logging, alerting, and data-quality rules.

---

# 📊 Dashboards

The repository includes four dashboard deliverables:

### 1. Applicant Analysis Dashboard
Applicant-focused analysis and insights.

### 2. Applicant Demographics & Financial Insights Dashboard
Applicant demographics and financial analysis.

### 3. Credit & Risk Intelligence Dashboard
Credit and risk-focused analytical reporting.

### 4. Loan Portfolio Dashboard
Loan portfolio and lending analysis.

Dashboard files are available under `DashBoards/`.

---

# 📈 Analytics & Business Insights

The Gold layer and dashboards support analysis around:

### Applicant Analysis
- Applicant demographics
- Income and employment characteristics
- Applicant-level credit information

### Credit Risk
- Credit score and credit profile analysis
- Credit history indicators
- Risk-oriented application analysis

### Loan Portfolio
- Loan amount analysis
- Interest-rate analysis
- Loan type and purpose
- Loan portfolio trends

### Economic Analysis
- Economic indicators
- Property-value related metrics
- Interest-rate spread
- Regional and time-based analysis

---

# 🧰 dbt Implementation

The project uses dbt for SQL-based modelling.

The repository contains:

```text
Development/
├── Bronze/
├── Silver/
├── Gold/
└── source.yml

Macros/
└── generate_schema_name.sql
```

The `source.yml` file defines the Bronze source tables in the `credit_analysis_catalog.bronze` schema.

The dbt project configuration materializes Silver and Gold models as tables and separates Gold dimension and fact schemas:

```text
credit_analysis_catalog
│
├── silver
│
├── gold_dimensions
│
└── gold_facts
```

This configuration is defined in `dbt_project.yml`.

---

# 🔄 Pipeline Orchestration & Monitoring

The architecture includes orchestration, monitoring, testing, logging, alerts, and audit/lineage as cross-cutting capabilities.

### Orchestration

- Source ingestion
- Layer execution
- Dependency management
- Pipeline monitoring
- Failure handling

### Monitoring

- Pipeline execution monitoring
- Data-quality monitoring
- Transformation logs
- Failure alerts
- Audit information

### Audit & Lineage

The design tracks information such as:

- Source file/path
- Ingestion timestamp
- Record counts
- Pipeline execution information
- Created/updated timestamps
- User/system information

---

# 📁 Repository Structure

```text
Credit-Risk-Assessment-Pipeline/
│
├── Alerts/
│   ├── Bronze Alerts.sql
│   ├── Silver Alerts.sql
│   └── Gold Alerts.sql
│
├── DashBoards/
│   ├── Applicant Analysis Dashboard.pdf
│   ├── Applicant Demographics &Financial Insights Dashbaord.pdf
│   ├── Credit &Risk Intelligence Dashbaord.pdf
│   └── Loan _Portfolio Dashboard.pdf
│
├── Datasets/
│   └── Source/
│       ├── applicant_profiles.csv
│       ├── credit_applications data.csv
│       ├── credit_history.csv
│       ├── economic_indicators_.csv
│       └── loan_details.csv
│
├── Design/
│   ├── Data-Lake information.pdf
│   ├── data_model_diagram.png
│   ├── high_level_design.png
│   └── low_level_design.png
│
├── Development/
│   ├── Bronze/
│   ├── Silver/
│   ├── Gold/
│   │   ├── Dimension Tables/
│   │   └── Fact Tables/
│   └── source.yml
│
├── Macros/
│   └── generate_schema_name.sql
│
├── Tests/
│   ├── Test Bronze.ipynb
│   ├── Test Silver.ipynb
│   └── Test Gold.ipynb
│
├── dbt_project.yml
└── README.md
```

The current repository structure contains these major areas for alerts, dashboards, source datasets, design artifacts, development, macros, tests, and dbt configuration.

---

# 🔐 Data Architecture

The platform is organized into clear processing zones:

```text
┌───────────────────────┐
│     Source CSVs       │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│ Azure Data Factory    │
│ Ingestion & Metadata  │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│ ADLS Gen2             │
│ Raw / Landing Zone    │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│ Bronze - Raw Delta    │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│ Silver - Clean Delta  │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│ Gold - Star Schema    │
│ Dimensions + Fact     │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│ Dashboards & Analytics│
└───────────────────────┘
```

---

# 📌 Key Outcomes

- Layered credit-risk data architecture.
- Structured ingestion and storage design.
- Standardized Silver transformation layer.
- Star-schema Gold model.
- Reusable dbt-based SQL models.
- Data-quality testing across Bronze, Silver, and Gold.
- Layer-specific alert definitions.
- Analytics dashboards for credit, applicants, and loan portfolios.
- Architecture and data-model documentation maintained alongside the implementation.

---

# 🔮 Future Enhancements

- Automated CI/CD for dbt and Databricks deployments.
- Expanded automated data-quality reporting.
- Centralized pipeline observability.
- Automated documentation and lineage generation.
- Additional credit-risk analytics and predictive modelling.
- Production-grade orchestration and scheduling integration.

---

# 📚 Project Documentation

| Document | Location |
|---|---|
| High-Level Architecture | `Design/high_level_design.png` |
| Low-Level Design | `Design/low_level_design.png` |
| Dimensional Data Model | `Design/data_model_diagram.png` |
| Data Lake Information | `Design/Data-Lake information.pdf` |
| Source Definitions | `Development/source.yml` |
| dbt Configuration | `dbt_project.yml` |
| Layer Tests | `Tests/` |
| Alerts | `Alerts/` |
| Dashboards | `DashBoards/` |

---

# 👨‍💻 Project

**Credit Risk Assessment Pipeline**

Built as an end-to-end Data Engineering project focused on structured ingestion, layered processing, dimensional modelling, data quality, monitoring, and analytics.

---

## 📌 Conclusion

This project demonstrates a complete credit-risk data platform that moves source credit and loan data through ingestion, storage, transformation, validation, dimensional modelling, and analytics.

The combination of **Azure Data Factory, ADLS Gen2, Databricks, PySpark, Delta Lake, dbt, testing, alerts, dashboards, and monitoring** provides a structured foundation for scalable credit-risk analytics.
