
CREATE OR REPLACE TABLE
`proyecto-demo-514900.holcim_silver.cement_plants_clean`
AS

WITH normalized AS (
    SELECT
        TRIM(company) AS company,
        TRIM(production_line) AS production_line,
        TRIM(province) AS province,
        TRIM(open_date) AS open_date,

        SAFE_CAST(real_capacity AS FLOAT64) AS real_capacity,

        TRIM(kiln_size) AS kiln_size,

        SAFE_CAST(
            SAFE_CAST(report_year AS FLOAT64) AS INT64
        ) AS report_year,

        SAFE_CAST(in_operation AS INT64) AS in_operation,

        SAFE_CAST(
            SAFE_CAST(open_year AS FLOAT64) AS INT64
        ) AS open_year,

        TRIM(city) AS city,
        TRIM(address) AS address,

        -- Conservar el valor original
        TRIM(design_capacity) AS design_capacity,

        -- Extraer capacidad solamente cuando está expresada en t/d
        SAFE_CAST(
            REGEXP_EXTRACT(
                LOWER(TRIM(design_capacity)),
                r'^([0-9]+(?:\.[0-9]+)?)\s*t/d$'
            ) AS FLOAT64
        ) AS design_capacity_tpd,

        TRIM(notes) AS notes,
        TRIM(status) AS status,
        SAFE_CAST(age AS FLOAT64) AS age,
        TRIM(region) AS region,
        TRIM(data_source) AS data_source,
        source_file,
        ingestion_timestamp

    FROM
        `proyecto-demo-514900.holcim_bronze.cement_plants_raw`

    WHERE
        company IS NOT NULL
        AND TRIM(company) != ''
        AND province IS NOT NULL
        AND TRIM(province) != ''
),

deduplicated AS (
    SELECT
        company,
        production_line,
        province,
        open_date,
        real_capacity,
        kiln_size,
        report_year,
        in_operation,
        open_year,
        city,
        address,
        design_capacity,
        design_capacity_tpd,
        notes,
        status,
        age,
        region,
        data_source,
        source_file,
        ingestion_timestamp

    FROM normalized

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY TO_JSON_STRING(STRUCT(
            company,
            production_line,
            province,
            open_date,
            real_capacity,
            kiln_size,
            report_year,
            in_operation,
            open_year,
            city,
            address,
            design_capacity,
            notes,
            status,
            age,
            region,
            data_source
        ))
        ORDER BY ingestion_timestamp DESC
    ) = 1
)

SELECT
    company,
    production_line,
    province,
    open_date,
    real_capacity,
    kiln_size,
    report_year,
    in_operation,
    open_year,
    city,
    address,
    design_capacity,
    design_capacity_tpd,
    notes,
    status,
    age,
    region,
    data_source,
    source_file,
    ingestion_timestamp

FROM deduplicated;
