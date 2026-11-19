
CREATE OR REPLACE TABLE
`proyecto-demo-514900.holcim_gold.gold_energy_by_province_year`
AS

SELECT
    province,
    doc_year,
    production_type,

    COUNT(*) AS total_registros,

    COUNT(DISTINCT company) AS total_empresas,

    SUM(clinker_production) AS total_clinker_production,

    SUM(cement_production) AS total_cement_production,

    SUM(clinker_coal) AS total_clinker_coal,

    SUM(clinker_electricity) AS total_clinker_electricity,

    SUM(clinker_energy) AS total_clinker_energy,

    SUM(cement_coal) AS total_cement_coal,

    SUM(cement_electricity) AS total_cement_electricity,

    SUM(cement_energy) AS total_cement_energy

FROM
    `proyecto-demo-514900.holcim_silver.energy_statistics_clean`

GROUP BY
    province,
    doc_year,
    production_type;
