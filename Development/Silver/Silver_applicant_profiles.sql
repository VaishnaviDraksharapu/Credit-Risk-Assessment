{{ config(
    materialized='table'
) }}

WITH cleaned_data AS (

    SELECT
        -- Applicant ID
        CAST(applicant_id AS BIGINT) AS applicant_id,

        -- Gender: trim spaces and standardize capitalization
        CASE
            WHEN LOWER(TRIM(gender)) = 'male'
                THEN 'Male'
            WHEN LOWER(TRIM(gender)) = 'female'
                THEN 'Female'
            WHEN LOWER(TRIM(gender)) = 'joint'
                THEN 'Joint'
            WHEN LOWER(TRIM(gender)) = 'sex not available'
                THEN 'Sex Not Available'
            ELSE 'Sex Not Available'
        END AS gender,

        -- Age: standardize valid age buckets
        CASE
            WHEN TRIM(age) IN (
                '<25',
                '25-34',
                '35-44',
                '45-54',
                '55-64',
                '65-74',
                '>74'
            )
                THEN TRIM(age)
            WHEN age IS NULL
                THEN 'Unknown'
            ELSE 'Unknown'
        END AS age,

        -- Income: convert to Decimal
        -- Missing income remains NULL
        TRY_CAST(income AS DECIMAL(18,2)) AS income,

        -- Business / Commercial
        CASE
            WHEN LOWER(TRIM(business_or_commercial)) = 'nob/c'
                THEN 'nob/c'
            WHEN LOWER(TRIM(business_or_commercial)) = 'b/c'
                THEN 'b/c'
            ELSE 'Unknown'
        END AS business_or_commercial,

        -- Occupancy Type
        CASE
            WHEN LOWER(TRIM(occupancy_type)) IN ('pr', 'sr', 'ir')
                THEN LOWER(TRIM(occupancy_type))
            ELSE 'Unknown'
        END AS occupancy_type,

        -- Construction Type
        CASE
            WHEN LOWER(TRIM(construction_type)) IN ('sb', 'mh')
                THEN LOWER(TRIM(construction_type))
            ELSE 'Unknown'
        END AS construction_type,

        -- Total Units
        CASE
            WHEN UPPER(TRIM(total_units)) IN ('1U', '2U', '3U', '4U')
                THEN UPPER(TRIM(total_units))
            ELSE 'Unknown'
        END AS total_units,

        -- Region
        CASE
            WHEN LOWER(TRIM(region)) = 'north'
                THEN 'North'
            WHEN LOWER(TRIM(region)) = 'south'
                THEN 'South'
            WHEN LOWER(TRIM(region)) = 'central'
                THEN 'Central'
            WHEN LOWER(TRIM(region)) = 'north-east'
                THEN 'North-East'
            ELSE 'Unknown'
        END AS region,

        -- Income quality flag
        CASE
            WHEN income IS NULL
                THEN 'Missing'
            WHEN TRY_CAST(income AS DECIMAL(18,2)) >= 0
                THEN 'Valid'
            ELSE 'Invalid'
        END AS income_quality_flag,

        -- Age quality flag
        CASE
            WHEN age IS NULL
                THEN 'Missing'
            WHEN TRIM(age) IN (
                '<25',
                '25-34',
                '35-44',
                '45-54',
                '55-64',
                '65-74',
                '>74'
            )
                THEN 'Valid'
            ELSE 'Invalid'
        END AS age_quality_flag,

        -- Duplicate handling
        ROW_NUMBER() OVER (
            PARTITION BY applicant_id
            ORDER BY applicant_id
        ) AS duplicate_rank

    FROM {{ source('bronze', 'applicant_profiles') }}
)

SELECT
    applicant_id,
    gender,
    age,
    income,
    business_or_commercial,
    occupancy_type,
    construction_type,
    total_units,
    region,
    income_quality_flag,
    age_quality_flag

FROM cleaned_data

WHERE duplicate_rank = 1