
CREATE OR REPLACE TABLE
`proyecto-demo-514900.holcim_silver.energy_statistics_clean`
AS

WITH normalized AS (
    SELECT
        SAFE_CAST(`no` AS INT64) AS record_no,
        TRIM(company) AS company,
        TRIM(province) AS province,
        TRIM(production_type) AS production_type,
        TRIM(production_line) AS production_line,
        TRIM(kiln_type) AS kiln_type,
        TRIM(open_date) AS open_date,

        SAFE_CAST(
            SAFE_CAST(doc_year AS FLOAT64) AS INT64
        ) AS doc_year,

        SAFE_CAST(capacity AS FLOAT64) AS capacity,
        SAFE_CAST(real_capacity AS FLOAT64) AS real_capacity,
        SAFE_CAST(clinker_production AS FLOAT64) AS clinker_production,
        SAFE_CAST(clinker_coal AS FLOAT64) AS clinker_coal,
        SAFE_CAST(clinker_electricity AS FLOAT64) AS clinker_electricity,
        SAFE_CAST(clinker_energy AS FLOAT64) AS clinker_energy,
        SAFE_CAST(cement_production AS FLOAT64) AS cement_production,
        SAFE_CAST(col_52_5_production AS FLOAT64) AS col_52_5_production,
        SAFE_CAST(col_42_5_production AS FLOAT64) AS col_42_5_production,
        SAFE_CAST(col_32_5_production AS FLOAT64) AS col_32_5_production,
        SAFE_CAST(cement_coal AS FLOAT64) AS cement_coal,
        SAFE_CAST(cement_electricity AS FLOAT64) AS cement_electricity,

        SAFE_CAST(
            REGEXP_REPLACE(
                TRIM(cement_energy),
                r'\s*\.\s*',
                '.'
            ) AS FLOAT64
        ) AS cement_energy,

        TRIM(notes) AS notes,
        TRIM(source) AS source,
        source_file,
        ingestion_timestamp

    FROM
        `proyecto-demo-514900.holcim_bronze.energy_statistics_raw`

    WHERE
        company IS NOT NULL
        AND TRIM(company) != ''
        AND province IS NOT NULL
        AND TRIM(province) != ''
),

deduplicated AS (
    SELECT
        record_no,
        company,
        province,
        production_type,
        production_line,
        kiln_type,
        open_date,
        doc_year,
        capacity,
        real_capacity,
        clinker_production,
        clinker_coal,
        clinker_electricity,
        clinker_energy,
        cement_production,
        col_52_5_production,
        col_42_5_production,
        col_32_5_production,
        cement_coal,
        cement_electricity,
        cement_energy,
        notes,
        source,
        source_file,
        ingestion_timestamp

    FROM normalized

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY TO_JSON_STRING(STRUCT(
            record_no,
            company,
            province,
            production_type,
            production_line,
            kiln_type,
            open_date,
            doc_year,
            capacity,
            real_capacity,
            clinker_production,
            clinker_coal,
            clinker_electricity,
            clinker_energy,
            cement_production,
            col_52_5_production,
            col_42_5_production,
            col_32_5_production,
            cement_coal,
            cement_electricity,
            cement_energy,
            notes,
            source
        ))
        ORDER BY ingestion_timestamp DESC
    ) = 1
)

SELECT
    record_no,
    company,
    province,
    production_type,
    production_line,
    kiln_type,
    open_date,
    doc_year,
    capacity,
    real_capacity,
    clinker_production,
    clinker_coal,
    clinker_electricity,
    clinker_energy,
    cement_production,
    col_52_5_production,
    col_42_5_production,
    col_32_5_production,
    cement_coal,
    cement_electricity,
    cement_energy,
    notes,
    source,
    source_file,
    ingestion_timestamp

FROM deduplicated;
