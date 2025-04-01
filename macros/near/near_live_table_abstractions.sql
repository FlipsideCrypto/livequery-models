-- Get Near Chain Head

{% macro near_live_table_latest_block_height() %}
    SELECT
        (
            SELECT
                rpc_result:result:header:height::INTEGER
            FROM
                (
                    SELECT
                        live.udf_api(
                            'https://rpc.mainnet.near.org',
                            utils.udf_json_rpc_call('block', {'finality' : 'final'})
                        ) :data AS rpc_result
                )
        ) AS latest_block_height,
        coalesce(_block_height, latest_block_height) AS min_height,
        IFF(
            coalesce(to_latest, false),
            latest_block_height,
            min_height
        ) AS max_height
{% endmacro %}

-- Get Near Block Data
{% macro near_live_table_target_blocks() %}
    
    WITH heights AS (
        {{ near_live_table_latest_block_height() | indent(4) -}}
    ),
    block_spine AS (
        SELECT
            ROW_NUMBER() OVER (
                ORDER BY
                    NULL
            ) - 1 + h.min_height::integer AS block_number,
            h.min_height,
            h.max_height,
            h.latest_block_height
        FROM
            TABLE(generator(ROWCOUNT => 1000)),
            heights h
        qualify block_number BETWEEN h.min_height AND h.max_height
    )
    SELECT
        block_number as block_height,
        latest_block_height
    FROM block_spine
{% endmacro %}

{% macro near_live_table_get_spine(table_name) %}
SELECT
    block_height,
    ROW_NUMBER() OVER (ORDER BY block_height) - 1 as partition_num
FROM 
    (
        SELECT 
            row_number() over (order by seq4()) - 1 + COALESCE(block_id, 0)::integer as block_height,
            min_height,
            max_height
        
        FROM
                TABLE(generator(ROWCOUNT => IFF(
                    COALESCE(to_latest, false),
                    latest_block_height - min_height + 1,
                    1
                ))),
                {{ table_name }}
            qualify block_height BETWEEN min_height AND max_height
    )
{% endmacro %}
   
{% macro near_live_table_get_raw_block_data(spine) %} 
SELECT
    block_height,
    DATE_PART('EPOCH', SYSDATE()) :: INTEGER AS request_timestamp,
    live.udf_api(
        'POST',
        '{Service}',
        {'Content-Type' : 'application/json'},
        {
            'jsonrpc' : '2.0',
            'method' : 'block',
            'id' : 'Flipside/getBlock/' || request_timestamp || '/' || block_height :: STRING,
            'params':{'block_id': block_height}
        },
        'Vault/prod/near/quicknode/mainnet'
    ):data.result AS rpc_data_result
from
    {{spine}}

{% endmacro %}

{% macro near_live_table_extract_raw_block_data(raw_blocks) %}
SELECT 
    block_data:header:height::string as block_id,
    TO_TIMESTAMP_NTZ(
            block_data :header :timestamp :: STRING
        ) AS block_timestamp, 
    block_data:header:hash::STRING as block_hash,
    ARRAY_SIZE(block_data:chunks)::NUMBER as tx_count,
    block_data:header as header,
    block_data:header:challenges_result::ARRAY as block_challenges_result,
    block_data:header:challenges_root::STRING as block_challenges_root,
    block_data:header:chunk_headers_root::STRING as chunk_headers_root,
    block_data:header:chunk_tx_root::STRING as chunk_tx_root,
    block_data:header:chunk_mask::ARRAY as chunk_mask,
    block_data:header:chunk_receipts_root::STRING as chunk_receipts_root,
    block_data:chunks as chunks,
    block_data:header:chunks_included::NUMBER as chunks_included,
    block_data:header:epoch_id::STRING as epoch_id,
    block_data:header:epoch_sync_data_hash::STRING as epoch_sync_data_hash,
    block_data:events as events,
    block_data:header:gas_price::NUMBER as gas_price,
    block_data:header:last_ds_final_block::STRING as last_ds_final_block,
    block_data:header:last_final_block::STRING as last_final_block,
    block_data:header:latest_protocol_version::NUMBER as latest_protocol_version,
    block_data:header:next_bp_hash::STRING as next_bp_hash,
    block_data:header:next_epoch_id::STRING as next_epoch_id,
    block_data:header:outcome_root::STRING as outcome_root,
    block_data:header:prev_hash::STRING as prev_hash,
    block_data:header:prev_height::NUMBER as prev_height,
    block_data:header:prev_state_root::STRING as prev_state_root,
    block_data:header:random_value::STRING as random_value,
    block_data:header:rent_paid::FLOAT as rent_paid,
    block_data:header:signature::STRING as signature,
    block_data:header:total_supply::NUMBER as total_supply,
    block_data:header:validator_proposals as validator_proposals,
    block_data:header:validator_reward::NUMBER as validator_reward,
    MD5(block_data:header:height::STRING) as fact_blocks_id,
    SYSDATE() as inserted_timestamp,
    SYSDATE() as modified_timestamp
FROM {{raw_blocks}}

{% endmacro %}

{% macro near_live_table_fact_blocks(schema, blockchain, network) %}
    {%- set near_live_table_fact_blocks = get_rendered_model('livequery_models', 'near_fact_blocks', schema, blockchain, network) -%}
    {{ near_live_table_fact_blocks }}
{% endmacro %}

{% macro near_live_table_fact_transactions(schema, blockchain, network) %}
WITH spine AS (
    {{ near_live_table_target_blocks() | indent(4) -}}
),
raw_block_details AS (
    SELECT
        s.block_height,
        live.udf_api(
            'https://rpc.mainnet.near.org',
            utils.udf_json_rpc_call('block', {'block_id': s.block_height})
        ):data:result AS block_data
    FROM spine s
),
block_chunks AS (
    SELECT
        b.block_height,
        b.block_data:header:timestamp::STRING AS block_timestamp_str,
        f.value AS chunk
    FROM raw_block_details b,
            LATERAL FLATTEN(input => b.block_data:chunks) f
),
chunk_txs AS (
    SELECT
        bc.block_height,
        bc.block_timestamp_str,
        tx.value:hash::STRING AS tx_hash,
        tx.value:signer_id::STRING AS tx_signer -- Crucial for EXPERIMENTAL_tx_status
    FROM block_chunks bc,
            LATERAL FLATTEN(input => bc.chunk:transactions) tx
),
tx_status_details AS (
    SELECT
        tx.block_height,
        tx.block_timestamp_str,
        tx.tx_hash,
        tx.tx_signer,
        live.udf_api(
            'https://rpc.mainnet.near.org',
            utils.udf_json_rpc_call(
                'EXPERIMENTAL_tx_status',
                [tx.tx_hash, tx.tx_signer]
                -- Possibly add {'wait_until': 'FINAL'} if needed/supported by UDF
            )
        ):data:result AS tx_result
    FROM chunk_txs tx
)
SELECT
    tx_hash,
    block_height AS block_id,
    TO_TIMESTAMP_NTZ(block_timestamp_str) AS block_timestamp,
    tx_result:transaction:nonce::INT AS nonce,
    tx_result:transaction:signature::STRING AS signature,
    tx_result:transaction:receiver_id::STRING AS tx_receiver,
    tx_result:transaction:signer_id::STRING AS tx_signer,
    tx_result:transaction AS tx, -- Entire transaction object
    tx_result:transaction_outcome:outcome:gas_burnt::FLOAT AS gas_used,
    0.0::FLOAT AS transaction_fee, -- Placeholder - needs calculation
    0.0::FLOAT AS attached_gas, -- Placeholder - needs extraction from tx:actions
    (tx_result:status:SuccessValue IS NOT NULL) AS tx_succeeded,
    MD5(tx_hash) AS fact_transactions_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM tx_status_details
{% endmacro %}

