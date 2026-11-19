--Qué muestra: empresas y registros por provincia, capacidad real acumulada 
--y capacidad de diseño que pudimos interpretar en toneladas por día.

CREATE OR REPLACE TABLE
`proyecto-demo-514900.holcim_gold.gold_capacity_by_province`
AS

SELECT
    province,

    COUNT(*) AS total_registros,

    COUNT(DISTINCT company) AS total_empresas,

    COUNT(DISTINCT production_line) AS total_lineas_produccion,

    SUM(real_capacity) AS total_real_capacity,

    SUM(design_capacity_tpd) AS total_design_capacity_tpd,

    COUNTIF(design_capacity_tpd IS NOT NULL)
        AS registros_con_design_capacity_tpd,

    COUNTIF(in_operation = 1)
        AS registros_en_operacion

FROM
    `proyecto-demo-514900.holcim_silver.cement_plants_clean`

GROUP BY
    province;
