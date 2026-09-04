{{ config(
    materialized='table',
    schema='silver'
) }}

WITH source_data AS (

    SELECT
        TRY_CAST(year AS INT) AS year,

        CASE
            WHEN LOWER(TRIM(region)) = 'north' THEN 'North'
            WHEN LOWER(TRIM(region)) = 'south' THEN 'South'
            WHEN LOWER(TRIM(region)) = 'central' THEN 'Central'
            WHEN LOWER(TRIM(region)) = 'north-east' THEN 'North-East'
            ELSE 'Unknown'
        END AS region,

        TRY_CAST(
            avg_property_value AS DECIMAL(18,2)
        ) AS avg_property_value,

        TRY_CAST(
            avg_interest_rate AS DECIMAL(10,4)
        ) AS avg_interest_rate,

        TRY_CAST(
            Interest_rate_spread AS DECIMAL(10,4)
        ) AS Interest_rate_spread,

        TRY_CAST(
            loan_status AS DECIMAL(2,1)
        ) AS loan_status,

        ROW_NUMBER() OVER (
            PARTITION BY
                year,
                region,
                avg_property_value,
                avg_interest_rate,
                Interest_rate_spread,
                loan_status
            ORDER BY year
        ) AS duplicate_rank

    FROM {{ source('bronze', 'economic_indicators') }}
),

deduplicated AS (

    SELECT
        year,
        region,
        avg_property_value,
        avg_interest_rate,
        Interest_rate_spread,
        loan_status
    FROM source_data
    WHERE duplicate_rank = 1
),

validated AS (

    SELECT
        year,
        region,

        CASE
            WHEN avg_property_value >= 0
                THEN avg_property_value
            ELSE NULL
        END AS avg_property_value,

        CASE
            WHEN avg_interest_rate BETWEEN 0 AND 100
                THEN avg_interest_rate
            ELSE NULL
        END AS avg_interest_rate,

        Interest_rate_spread,

        CASE
            WHEN loan_status IN (0, 1)
                THEN loan_status
            ELSE NULL
        END AS loan_status

    FROM deduplicated
)

SELECT
    year,
    region,
    avg_property_value,
    avg_interest_rate,
    Interest_rate_spread,
    loan_status

FROM validated