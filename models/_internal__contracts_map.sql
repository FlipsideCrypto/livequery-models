{{ config(
    materialized = 'view'
) }}

SELECT
    address,
    symbol,
    decimals,
    CASE
        blockchain
        WHEN 'avalanche' THEN 'avalanche_c'
        WHEN 'arbitrum' THEN 'arbitrum_one'
        WHEN 'optimism' THEN 'optimistic-ethereum"'
        ELSE blockchain
    END AS blockchain
FROM
    {{ source(
        'crosschain',
        'dim_contracts'
    ) }}
