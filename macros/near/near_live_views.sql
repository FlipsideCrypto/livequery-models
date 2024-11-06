
-- Get Near fact data
{% macro near_live_view_fact_blocks(schema, blockchain, network) %}
    WITH blocks AS (

        SELECT
            *
        FROM
            NEAR_DEV.silver.streamline_blocks
    )
    SELECT
        block_id,
        block_timestamp,
        block_hash,
        tx_count, -- TO DEPRECATE
        block_author,
        header,
        header :challenges_result :: ARRAY AS block_challenges_result,
        header :challenges_root :: STRING AS block_challenges_root,
        header :chunk_headers_root :: STRING AS chunk_headers_root,
        header :chunk_tx_root :: STRING AS chunk_tx_root,
        header :chunk_mask :: ARRAY AS chunk_mask,
        header :chunk_receipts_root :: STRING AS chunk_receipts_root,
        chunks,
        header :chunks_included :: NUMBER AS chunks_included,
        epoch_id,
        header :epoch_sync_data_hash :: STRING AS epoch_sync_data_hash,
        events, -- TO DEPRECATE
        gas_price,
        header :last_ds_final_block :: STRING AS last_ds_final_block,
        header :last_final_block :: STRING AS last_final_block,
        latest_protocol_version,
        header: next_bp_hash :: STRING AS next_bp_hash,
        next_epoch_id,
        header :outcome_root :: STRING AS outcome_root,
        prev_hash,
        header :prev_height :: NUMBER AS prev_height,
        header :prev_state_root :: STRING AS prev_state_root,
        header :random_value :: STRING AS random_value,
        header :rent_paid :: FLOAT AS rent_paid,
        header :signature :: STRING AS signature,
        total_supply,
        validator_proposals,
        validator_reward,
        COALESCE(
            streamline_blocks_id,
            
        
    md5(cast(coalesce(cast(block_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
        ) AS fact_blocks_id,
        COALESCE(inserted_timestamp, _inserted_timestamp, '2000-01-01' :: TIMESTAMP_NTZ) AS inserted_timestamp,
        COALESCE(modified_timestamp, _inserted_timestamp, '2000-01-01' :: TIMESTAMP_NTZ) AS modified_timestamp
    FROM
        blocks
{% endmacro %}