{{ config(
    materialized='table',
    schema='gold'
) }}

WITH applications AS (

    SELECT
        applicant_id,
        year,
        loan_limit,
        approv_in_adv,
        loan_type,
        loan_purpose,
        loan_amount,
        rate_of_interest,
        Interest_rate_spread,
        Upfront_charges,
        term,
        submission_of_application,
        region,
        application_status
    FROM {{ ref('Silver_credit_applications') }}

),

/* ============================================================
   APPLICANT DIMENSION
   ============================================================ */

applicant_dimension AS (

    SELECT
        applicant_key,
        applicant_id
    FROM {{ ref('dim_applicant') }}

),

/* ============================================================
   CREDIT PROFILE DIMENSION
   ============================================================ */

credit_dimension AS (

    SELECT
        credit_profile_key,
        applicant_id
    FROM {{ ref('dim_credit_profile') }}

),

/* ============================================================
   LOAN MAPPING
   Credit application does not contain loan_id.
   Therefore select one loan per applicant to avoid
   multiplying fact rows.
   ============================================================ */

loan_mapping AS (

    SELECT
        loan_key,
        loan_id,
        applicant_id,
        loan_to_value,
        loan_term
    FROM (

        SELECT
            dl.loan_key,
            dl.loan_id,
            dl.applicant_id,
            ld.loan_to_value,
            ld.loan_term,

            ROW_NUMBER() OVER (
                PARTITION BY dl.applicant_id
                ORDER BY dl.loan_id
            ) AS rn

        FROM {{ ref('dim_loan') }} dl

        LEFT JOIN {{ ref('silver_loan_details') }} ld
            ON dl.loan_id = ld.loan_id

    )

    WHERE rn = 1

),

/* ============================================================
   ECONOMIC DIMENSION
   Match application using year + region
   ============================================================ */

economic_dimension AS (

    SELECT
        economic_key,
        year,
        region,
        loan_status
    FROM {{ ref('dim_economic') }}

),

/* ============================================================
   FINAL FACT
   Grain:
   One row = one credit application
   ============================================================ */

final_fact AS (

    SELECT

        /* Surrogate primary key */
        ROW_NUMBER() OVER (
            ORDER BY
                a.applicant_id,
                a.year,
                a.loan_amount
        ) AS application_key,

        /* Foreign keys */

        ad.applicant_key,

        cd.credit_profile_key,

        lm.loan_key,

        ed.economic_key,

        /* Business keys */

        a.applicant_id,

        lm.loan_id,

        a.year,

        /* Descriptive application attributes */

        a.loan_limit,

        a.approv_in_adv,

        a.loan_type,

        a.loan_purpose,

        a.submission_of_application,

        a.region,

        /* Measures */

        a.loan_amount,

        a.rate_of_interest,

        a.Interest_rate_spread,

        a.Upfront_charges,

        a.term,

        a.application_status,

        /* Loan measures */

        lm.loan_to_value,

        lm.loan_term,

        /* Economic indicator */

        ed.loan_status

    FROM applications a

    LEFT JOIN applicant_dimension ad
        ON a.applicant_id = ad.applicant_id

    LEFT JOIN credit_dimension cd
        ON a.applicant_id = cd.applicant_id

    LEFT JOIN loan_mapping lm
        ON a.applicant_id = lm.applicant_id

    LEFT JOIN economic_dimension ed
        ON a.year = ed.year
       AND LOWER(TRIM(a.region))
           = LOWER(TRIM(ed.region))

)

SELECT *
FROM final_fact