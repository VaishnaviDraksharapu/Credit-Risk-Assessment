{{ config(
    materialized='table',
    schema='gold'
) }}

WITH credit_data AS (

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
    FROM {{ ref('silver_credit_history') }}

    WHERE applicant_id IS NOT NULL

),

deduplicated AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY applicant_id
            ORDER BY applicant_id
        ) AS rn

    FROM credit_data

)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY applicant_id
    ) AS credit_profile_key,

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

FROM deduplicated

WHERE rn = 1