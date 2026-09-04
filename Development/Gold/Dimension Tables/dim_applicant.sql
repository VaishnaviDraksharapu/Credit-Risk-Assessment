{{ config(
    materialized='table',
    schema='gold'
) }}

WITH applicant_data AS (

    SELECT
        applicant_id,
        gender,
        age,
        income,
        business_or_commercial,
        occupancy_type,
        construction_type,
        total_units,
        region
    FROM {{ ref('Silver_applicant_profiles') }}
    WHERE applicant_id IS NOT NULL

),

deduplicated AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY applicant_id
            ORDER BY applicant_id
        ) AS rn
    FROM applicant_data

)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY applicant_id
    ) AS applicant_key,

    applicant_id,

    gender,
    age,
    income,
    business_or_commercial,
    occupancy_type,
    construction_type,
    total_units,
    region

FROM deduplicated
WHERE rn = 1