{{ config(
    materialized = 'view'
) }}

SELECT
    parent_contract_address,
    event_name,
    event_signature,
    abi,
    start_block,
    end_block,
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
        'dim_evm_event_abis'
    ) }}
