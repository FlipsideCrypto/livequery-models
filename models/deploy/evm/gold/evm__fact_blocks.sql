{{ config(
    materialized = 'view',
    tags = ['fsc_evm', 'core', 'override']
) }}

SELECT * FROM {{ ref('fsc_evm', 'core__fact_blocks')}}
