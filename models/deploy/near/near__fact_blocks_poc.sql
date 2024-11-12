{{ config(
    materialized = 'view',
    secure = false
) }}

SELECT * 

FROM 
    {# {{ ref("near-models","core__fact_blocks")}} #}
    table(generator(rowcount => 10))
LIMIT 10