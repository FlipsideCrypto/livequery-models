
-- Get Near fact data
{% macro near_live_view_fact_blocks(schema, blockchain, network) %}
WITH heights AS (
    SELECT
        livequery_dev.live.udf_api(
            'https://rpc.mainnet.near.org',
            livequery_dev.utils.udf_json_rpc_call(
                'block',
                {'finality': 'final'}
            )
        ):data AS result,
        result:result:header:height::integer as latest_block_height,
        coalesce(
            132209591,
            latest_block_height
        ) as min_height,
        iff(
            coalesce(false, false),
            latest_block_height,
            min_height
        ) as max_height
),
spine AS (
    SELECT
        row_number() over (order by null) - 1 + COALESCE(132209591, 0)::integer as block_height,
        min_height,
        max_height,
        latest_block_height
    FROM
        table(generator(ROWCOUNT => 1000)),
        heights 
    QUALIFY block_height BETWEEN min_height AND max_height
),
raw_blocks AS (
    
    SELECT
        block_height,
        livequery_dev.live.udf_api(
            'https://rpc.mainnet.near.org',
            livequery_Dev.utils.udf_json_rpc_call(
                'block',
                {'block_id': block_height}
            )
        ):data.result AS block_data
    from
        spine

)
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
FROM raw_blocks;
{% endmacro %}