{{ config(
    materialized='table',
    schema='gold'
) }}

WITH loan_data AS (

    SELECT
        loan_id,
        applicant_id,
        loan_type,
        loan_purpose,
        secured_by,
        security_type,
        property_value
    FROM {{ ref('silver_loan_details') }}

    WHERE loan_id IS NOT NULL

),

deduplicated AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY loan_id
            ORDER BY loan_id
        ) AS rn

    FROM loan_data

)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY loan_id
    ) AS loan_key,

    loan_id,
    applicant_id,

    loan_type,
    loan_purpose,
    secured_by,
    security_type,
    property_value

FROM deduplicated

WHERE rn = 1