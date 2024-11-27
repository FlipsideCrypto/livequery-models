-- models/tests/test_fact_blocks_transformations.sql
{{ config(
    materialized = 'view',
    tags = ['near_models','core','override']
) }}

SELECT * FROM {{ ref('near_models','core__fact_blocks')}}