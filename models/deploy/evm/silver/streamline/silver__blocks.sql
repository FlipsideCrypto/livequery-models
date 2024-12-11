{{ config(
    materialized = 'view',
    tags = ['ethereum_models','core','override']
) }}

WITH spine AS (
    {{ evm_live_view_target_blocks(schema, blockchain, network) | indent(4) -}}
),

raw_block_txs AS (
    {{ evm_live_view_bronze_blocks(schema, blockchain, network, 'spine') | indent(4) -}}
)

SELECT
    block_number,
    0 AS partition_key, -- No partition key for realtime data
    data AS block_json,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(['block_number']) }} AS blocks_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    'override' AS _invocation_id
FROM
    raw_block_txs
