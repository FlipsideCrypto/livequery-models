-- models/tests/test_fact_blocks_transformations.sql
{{ config(
    materialized = 'view'
) }}

SELECT * FROM {{ ref('near_models','core__fact_blocks')}}