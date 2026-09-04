{{ config(
    materialized='table'
) }}

WITH cleaned_data AS (

    SELECT

        -- Applicant ID
        CAST(applicant_id AS BIGINT) AS applicant_id,

        -- Application year
        CAST(year AS INT) AS year,

        -- Loan limit
        CASE
            WHEN LOWER(TRIM(loan_limit)) = 'cf'
                THEN 'cf'
            WHEN LOWER(TRIM(loan_limit)) = 'ncf'
                THEN 'ncf'
            ELSE NULL
        END AS loan_limit,

        -- Approval in advance
        CASE
            WHEN LOWER(TRIM(approv_in_adv)) = 'pre'
                THEN 'pre'
            WHEN LOWER(TRIM(approv_in_adv)) = 'nopre'
                THEN 'nopre'
            ELSE NULL
        END AS approv_in_adv,

        -- Loan type
        CASE
            WHEN LOWER(TRIM(loan_type)) = 'type1'
                THEN 'type1'
            WHEN LOWER(TRIM(loan_type)) = 'type2'
                THEN 'type2'
            WHEN LOWER(TRIM(loan_type)) = 'type3'
                THEN 'type3'
            ELSE NULL
        END AS loan_type,

        -- Loan purpose
        CASE
            WHEN LOWER(TRIM(loan_purpose)) = 'p1'
                THEN 'p1'
            WHEN LOWER(TRIM(loan_purpose)) = 'p2'
                THEN 'p2'
            WHEN LOWER(TRIM(loan_purpose)) = 'p3'
                THEN 'p3'
            WHEN LOWER(TRIM(loan_purpose)) = 'p4'
                THEN 'p4'
            ELSE NULL
        END AS loan_purpose,

        -- Loan amount
        TRY_CAST(
            loan_amount AS DECIMAL(18,2)
        ) AS loan_amount,

        -- Rate of interest
        TRY_CAST(
            rate_of_interest AS DECIMAL(10,4)
        ) AS rate_of_interest,

        -- Interest rate spread
        TRY_CAST(
            Interest_rate_spread AS DECIMAL(10,4)
        ) AS Interest_rate_spread,

        -- Upfront charges
        TRY_CAST(
            Upfront_charges AS DECIMAL(18,2)
        ) AS Upfront_charges,

        -- Loan term
        TRY_CAST(
            term AS INT
        ) AS term,

        -- Submission of application
        CASE
            WHEN LOWER(TRIM(submission_of_application)) = 'to_inst'
                THEN 'to_inst'
            WHEN LOWER(TRIM(submission_of_application)) = 'not_inst'
                THEN 'not_inst'
            ELSE NULL
        END AS submission_of_application,

        -- Region
        TRIM(region) AS region,

        -- Application status
        TRY_CAST(
            application_status AS DECIMAL(2,1)
        ) AS application_status,

        -- Keep one record for each applicant
        ROW_NUMBER() OVER (
            PARTITION BY applicant_id
            ORDER BY applicant_id
        ) AS duplicate_rank

    FROM {{ source('bronze', 'credit_application') }}
)

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

FROM cleaned_data

WHERE duplicate_rank = 1