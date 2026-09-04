{{ config(
    materialized='table',
    schema='silver'
) }}

WITH source_data AS (

    SELECT
        CAST(applicant_id AS BIGINT) AS applicant_id,

        CAST(loan_id AS BIGINT) AS loan_id,

        CASE
            WHEN LOWER(TRIM(loan_type)) IN ('type1', 'type2', 'type3')
                THEN LOWER(TRIM(loan_type))
            ELSE 'Unknown'
        END AS loan_type,

        CASE
            WHEN LOWER(TRIM(loan_purpose)) IN ('p1', 'p2', 'p3', 'p4')
                THEN LOWER(TRIM(loan_purpose))
            ELSE 'Unknown'
        END AS loan_purpose,

        TRY_CAST(
            loan_amount AS DECIMAL(18,2)
        ) AS loan_amount,

        TRY_CAST(
            loan_term AS INT
        ) AS loan_term,

        TRY_CAST(
            property_value AS DECIMAL(18,2)
        ) AS property_value,

        TRY_CAST(
            loan_to_value AS DECIMAL(10,4)
        ) AS loan_to_value,

        CASE
            WHEN LOWER(TRIM(secured_by)) = 'home'
                THEN 'home'
            WHEN LOWER(TRIM(secured_by)) = 'land'
                THEN 'land'
            ELSE 'Unknown'
        END AS secured_by,

        CASE
            WHEN LOWER(TRIM(security_type)) = 'direct'
                THEN 'direct'
            WHEN LOWER(TRIM(security_type)) IN ('indirect', 'indriect')
                THEN 'indirect'
            ELSE 'Unknown'
        END AS security_type,

        ROW_NUMBER() OVER (
            PARTITION BY loan_id
            ORDER BY loan_id
        ) AS duplicate_rank

    FROM {{ source('bronze', 'loan_details') }}
),

deduplicated AS (

    SELECT
        applicant_id,
        loan_id,
        loan_type,
        loan_purpose,
        loan_amount,
        loan_term,
        property_value,
        loan_to_value,
        secured_by,
        security_type
    FROM source_data
    WHERE duplicate_rank = 1
),

validated AS (

    SELECT
        applicant_id,
        loan_id,
        loan_type,
        loan_purpose,

        CASE
            WHEN loan_amount >= 0
                THEN loan_amount
            ELSE NULL
        END AS loan_amount,

        CASE
            WHEN loan_term > 0
                THEN loan_term
            ELSE NULL
        END AS loan_term,

        CASE
            WHEN property_value >= 0
                THEN property_value
            ELSE NULL
        END AS property_value,

        CASE
            WHEN loan_to_value >= 0
                 AND loan_to_value <= 100
                THEN loan_to_value
            ELSE NULL
        END AS loan_to_value,

        secured_by,
        security_type

    FROM deduplicated
)

SELECT
    applicant_id,
    loan_id,
    loan_type,
    loan_purpose,
    loan_amount,
    loan_term,
    property_value,
    loan_to_value,
    secured_by,
    security_type

FROM validated