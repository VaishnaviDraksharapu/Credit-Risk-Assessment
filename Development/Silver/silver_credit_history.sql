{{ config(
    materialized='table',
) }}

WITH source_data AS (

    SELECT
        CAST(applicant_id AS BIGINT) AS applicant_id,

        CASE
            WHEN LOWER(TRIM(credit_worthiness)) IN ('l1', 'l2')
                THEN LOWER(TRIM(credit_worthiness))
            ELSE 'Unknown'
        END AS credit_worthiness,

        CASE
            WHEN LOWER(TRIM(open_credit)) IN ('opc', 'nopc')
                THEN LOWER(TRIM(open_credit))
            ELSE 'Unknown'
        END AS open_credit,

        CASE
            WHEN UPPER(TRIM(credit_type)) IN ('EXP', 'EQUI', 'CRIF', 'CIB')
                THEN UPPER(TRIM(credit_type))
            ELSE 'Unknown'
        END AS credit_type,

        COALESCE(
            TRY_CAST(credit_score AS INT),
            0
        ) AS credit_score,

        CASE
            WHEN UPPER(TRIM(co_applicant_credit_type)) IN ('CIB', 'EXP')
                THEN UPPER(TRIM(co_applicant_credit_type))
            ELSE 'Unknown'
        END AS co_applicant_credit_type,

        CASE
            WHEN LOWER(TRIM(negative_amortization)) IN ('neg_amm', 'not_neg')
                THEN LOWER(TRIM(negative_amortization))
            ELSE 'Unknown'
        END AS negative_amortization,

        CASE
            WHEN LOWER(TRIM(interest_only)) IN ('int_only', 'not_int')
                THEN LOWER(TRIM(interest_only))
            ELSE 'Unknown'
        END AS interest_only,

        CASE
            WHEN LOWER(TRIM(lump_sum_payment)) IN ('lpsm', 'not_lpsm')
                THEN LOWER(TRIM(lump_sum_payment))
            ELSE 'Unknown'
        END AS lump_sum_payment,

        TRY_CAST(
            debt_to_income_ratio AS DECIMAL(10,2)
        ) AS debt_to_income_ratio,

        ROW_NUMBER() OVER (
            PARTITION BY applicant_id
            ORDER BY applicant_id
        ) AS duplicate_rank

   FROM {{ source('bronze', 'credit_history') }}
),

deduplicated AS (

    SELECT
        applicant_id,
        credit_worthiness,
        open_credit,
        credit_type,
        credit_score,
        co_applicant_credit_type,
        negative_amortization,
        interest_only,
        lump_sum_payment,
        debt_to_income_ratio

    FROM source_data
    WHERE duplicate_rank = 1
),

dti_imputed AS (

    SELECT
        applicant_id,
        credit_worthiness,
        open_credit,
        credit_type,
        credit_score,
        co_applicant_credit_type,
        negative_amortization,
        interest_only,
        lump_sum_payment,

        COALESCE(
            debt_to_income_ratio,
            (
                SELECT percentile_approx(
                    debt_to_income_ratio,
                    0.5
                )
                FROM deduplicated
                WHERE debt_to_income_ratio IS NOT NULL
            )
        ) AS debt_to_income_ratio

    FROM deduplicated
)

SELECT
    applicant_id,
    credit_worthiness,
    open_credit,
    credit_type,
    credit_score,
    co_applicant_credit_type,
    negative_amortization,
    interest_only,
    lump_sum_payment,
    debt_to_income_ratio

FROM dti_imputed