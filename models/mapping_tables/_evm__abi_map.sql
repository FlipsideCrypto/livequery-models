{{ config(
    materialized = 'view',
    grants = {'+select': ['INTERNAL_DEV']}
) }}

SELECT
    parent_contract_address,
    event_name,
    event_signature,
    abi,
    start_block,
    end_block,
    CASE blockchain
        WHEN 'avalanche' THEN 'avalanche_c'
        WHEN 'arbitrum' THEN 'arbitrum_one'
        ELSE blockchain
    END AS blockchain
FROM
    {{ source(
        'crosschain',
        'dim_evm_event_abis'
    ) }}
