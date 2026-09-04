{{ config(
    materialized='table',
    schema='gold'
) }}

WITH economic_data AS (

    SELECT
        year,
        region,
        avg_property_value,
        avg_interest_rate,
        Interest_rate_spread,
        loan_status
    FROM {{ ref('silver_economic_indicators') }}

    WHERE year IS NOT NULL
      AND region IS NOT NULL

),

deduplicated AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                year,
                region
            ORDER BY year
        ) AS rn

    FROM economic_data

)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY year, region
    ) AS economic_key,

    year,
    region,

    avg_property_value,
    avg_interest_rate,
    Interest_rate_spread,
    loan_status

FROM deduplicated

WHERE rn = 1