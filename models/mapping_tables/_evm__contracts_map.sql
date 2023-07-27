{{ config(
    materialized = 'view',
    grants = {'+select': ['INTERNAL_DEV']}
) }}

SELECT
    address,
    symbol,
    decimals,
    CASE
    blockchain
        WHEN 'avalanche' THEN 'avalanche_c'
        WHEN 'arbitrum' THEN 'arbitrum_one'
        ELSE blockchain
    END AS blockchain
FROM
    {{ source(
        'crosschain',
        'dim_contracts'
    ) }}
