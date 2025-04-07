-- Get Near Chain Head

{% macro near_live_table_latest_block_height() %}
WITH rpc_call AS (
    SELECT
        live.udf_api(
            'https://rpc.mainnet.near.org',
            utils.udf_json_rpc_call('block', {'finality' : 'final'})
        ):data::object AS rpc_result 
    FROM dual
    ORDER BY 1 
    LIMIT 1 
)
SELECT
    rpc_result:result:header:height::INTEGER AS latest_block_height
FROM
    rpc_call
{% endmacro %}

{% macro near_live_table_min_max_block_height(start_block, block_count) %}
SELECT
    {{ start_block }} AS min_height,
    min_height + {{ block_count }} AS max_height, 
FROM
    dual    
{% endmacro %}

-- Get Near Block Data
{% macro near_live_table_target_blocks(start_block, block_count) %}
    
    WITH heights AS (
        SELECT
            min_height,
            max_height,
        FROM (
             {{- near_live_table_min_max_block_height(start_block=start_block, block_count=block_count) | indent(13) -}}
        )
    ),
    block_spine AS (
        SELECT
            ROW_NUMBER() OVER (
                ORDER BY
                    NULL
            ) - 1 + h.min_height::integer AS block_number,
        FROM
            heights h, 
            TABLE(generator(ROWCOUNT => {{ block_count }} )) 
        qualify block_number BETWEEN h.min_height AND h.max_height
    )
    SELECT
        block_number as block_height    
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
    {%- set near_live_table_fact_transactions = get_rendered_model('livequery_models', 'near_fact_transactions', schema, blockchain, network) -%}
    {{ near_live_table_fact_transactions }}
{% endmacro %}

{% macro near_live_table_fact_receipts(schema, blockchain, network) %}
WITH spine AS (
    {{ near_live_table_target_blocks(start_block='_block_height', block_count='row_count') | indent(4) -}}
),
raw_blocks AS (
    -- Fetching raw block data using the helper macro, assuming it handles the API call correctly
    {{ near_live_table_get_raw_block_data('spine') | indent(4) -}}
),
block_chunk_hashes AS (
    -- Extract block info and the chunk_hash from each chunk header
    SELECT
        rb.block_height,
        rb.rpc_data_result:header:timestamp::STRING AS block_timestamp_str,
        ch.value:chunk_hash::STRING AS chunk_hash,
        ch.value:shard_id::INTEGER AS shard_id, -- Keep shard_id temporarily for the chunk call
        ch.value:height_created::INTEGER AS chunk_height_created, -- Not in final schema, but might be useful
        ch.value:height_included::INTEGER AS chunk_height_included -- Not in final schema
    FROM raw_blocks rb,
         LATERAL FLATTEN(input => rb.rpc_data_result:chunks) ch
    -- Optimization: Potentially filter chunks with tx_root = '111...' if needed
),
raw_chunk_details AS (
    -- Fetch full chunk details using the chunk_hash
    SELECT
        bch.block_height,
        bch.block_timestamp_str,
        -- bch.shard_id, -- No longer needed after this CTE
        -- bch.chunk_hash, -- No longer needed after this CTE
        live.udf_api( -- Use the direct UDF call for chunk RPC
            'https://rpc.mainnet.near.org',
            utils.udf_json_rpc_call('chunk', {'chunk_id': bch.chunk_hash}) -- Use OBJECT format for parameters
        ):data:result AS chunk_data 
    FROM block_chunk_hashes bch
),
receipt_details AS (
    -- Flatten the receipts array from the chunk_data result and extract fields based on core__fact_receipts
    SELECT
        rcd.block_height,
        rcd.block_timestamp_str,
        receipt.value:receipt_id::STRING AS receipt_id,
        -- tx_hash is still unavailable directly from chunk RPC
        NULL::STRING AS tx_hash, 
        receipt.value:predecessor_id::STRING AS predecessor_id, 
        receipt.value:receiver_id::STRING AS receiver_id,
        receipt.value:receipt AS actions, -- Map raw receipt data to 'actions'
        receipt.value:outcome AS outcome, -- Map outcome object to 'outcome'
        receipt.value:outcome:gas_burnt::FLOAT AS gas_burnt,
        receipt.value:outcome:status::VARIANT AS status_value,
        receipt.value:outcome:logs::ARRAY AS logs,
        receipt.value:outcome:receipt_ids::ARRAY AS receipt_outcome_id,
        receipt.value:proof::ARRAY AS proof, 
        receipt.value:outcome:metadata::VARIANT AS metadata, 
        (receipt.value:outcome:status:SuccessValue IS NOT NULL OR receipt.value:outcome:status:SuccessReceiptId IS NOT NULL) AS receipt_succeeded
    FROM raw_chunk_details rcd,
         LATERAL FLATTEN(input => rcd.chunk_data:receipts) receipt
)
-- Final SELECT statement matching core__fact_receipts schema
SELECT
    TO_TIMESTAMP_NTZ(rd.block_timestamp_str) AS block_timestamp,
    rd.block_height AS block_id,
    rd.tx_hash, -- Mapped to NULL
    rd.receipt_id,
    rd.receipt_outcome_id,
    rd.receiver_id,
    rd.predecessor_id, 
    rd.actions,
    rd.outcome,
    rd.gas_burnt,
    rd.status_value,
    rd.logs,
    rd.proof,
    rd.metadata,
    rd.receipt_succeeded,
    rd.receipt_id AS fact_receipts_id, -- Map receipt_id to fact_receipts_id as per core__fact_receipts
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM receipt_details rd
{% endmacro %}

{% macro near_live_table_fact_transactions_unabstracted(start_block, _tl_name) %}
WITH spine AS (
    
        
        WITH heights AS (
            
            SELECT
                f.value::INTEGER AS latest_block_height,
                coalesce({{ start_block }}, latest_block_height) AS min_height,
                IFF(
                    coalesce({{ _tl_name }}, false),
                    latest_block_height,
                    min_height
                ) AS max_height
            FROM
                (
                    SELECT
                        ARRAY_CONSTRUCT( 
                            live.udf_api(
                                'https://rpc.mainnet.near.org',
                                utils.udf_json_rpc_call('block', {'finality' : 'final'})
                            ) :data :result:header:height::INTEGER
                        ) AS result_array
                ) volatile_data
                , LATERAL FLATTEN(input => volatile_data.result_array) f
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
block_chunk_hashes AS (
    -- Updated: Extract only block info and the chunk_hash from each chunk header
    SELECT
        b.block_height,
        b.block_data:header:timestamp::STRING AS block_timestamp_str,
        ch.value:chunk_hash::STRING AS chunk_hash, -- Get the hash of the chunk
        ch.value:shard_id::INTEGER AS shard_id -- Extract shard_id here
    FROM raw_block_details b,
         LATERAL FLATTEN(input => b.block_data:chunks) ch -- Flatten the chunks array (chunk headers)
    WHERE ch.value:tx_root::STRING <> '11111111111111111111111111111111' -- Optimization: Skip chunks with no transactions
),
raw_chunk_details AS (
    -- New CTE: Fetch full chunk details using the chunk_hash
    SELECT
        bch.block_height,
        bch.block_timestamp_str,
        bch.shard_id, -- Pass shard_id through
        live.udf_api(
            'https://rpc.mainnet.near.org',
            utils.udf_json_rpc_call('chunk', [bch.chunk_hash]) -- Call 'chunk' RPC method with hash
        ):data:result AS chunk_data -- The result contains the 'transactions' array
    FROM block_chunk_hashes bch
),
chunk_txs AS (
    -- Updated: Flatten the transactions array from the actual chunk_data result
    SELECT
        rcd.block_height,
        rcd.block_timestamp_str,
        rcd.shard_id, -- Pass shard_id through
        tx.value:hash::STRING AS tx_hash,
        tx.value:signer_id::STRING AS tx_signer
    FROM raw_chunk_details rcd,
         LATERAL FLATTEN(input => rcd.chunk_data:transactions) tx -- Flatten transactions from the 'chunk' RPC result
),
tx_status_details AS (
    -- This CTE remains the same
    SELECT
        tx.block_height,
        tx.block_timestamp_str,
        tx.shard_id, -- Pass shard_id through
        tx.tx_hash,
        tx.tx_signer,
        live.udf_api(
            'https://rpc.mainnet.near.org',
            utils.udf_json_rpc_call(
                'EXPERIMENTAL_tx_status',
                [tx.tx_hash, tx.tx_signer]
            )
        ):data:result AS tx_result
    FROM chunk_txs tx
),
-- New CTE to calculate attached gas per transaction
tx_attached_gas AS (
    SELECT
        tsd.tx_hash,
        -- Calculate attached gas by summing gas from FunctionCall actions
        SUM(iff(action.value:FunctionCall is not null, action.value:FunctionCall:gas::NUMBER, 0)) AS calculated_attached_gas
    FROM
        tx_status_details tsd,
        LATERAL FLATTEN(input => tsd.tx_result:transaction:actions) action
    GROUP BY
        tsd.tx_hash
)
-- Final SELECT joining the details and the calculated gas
SELECT
    tsd.tx_hash,
    tsd.block_height AS block_id,
    TO_TIMESTAMP_NTZ(tsd.block_timestamp_str) AS block_timestamp,
    tsd.tx_result:transaction:nonce::INT AS nonce,
    tsd.tx_result:transaction:signature::STRING AS signature,
    tsd.tx_result:transaction:receiver_id::STRING AS tx_receiver,
    tsd.tx_result:transaction:signer_id::STRING AS tx_signer,
    tsd.tx_result:transaction AS tx,
    tsd.tx_result:transaction_outcome:outcome:gas_burnt::FLOAT AS gas_used,
    (tsd.tx_result:transaction_outcome:outcome:tokens_burnt::NUMBER / pow(10, 24))::FLOAT AS transaction_fee,
    -- Use the pre-calculated attached gas from the new CTE
    COALESCE(tag.calculated_attached_gas, 0)::FLOAT AS attached_gas,
    (tsd.tx_result:status:SuccessValue IS NOT NULL) AS tx_succeeded,
    MD5(tsd.tx_hash) AS fact_transactions_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    tx_status_details tsd
    -- Left join in case a transaction has zero actions (though COALESCE above handles null)
    LEFT JOIN tx_attached_gas tag ON tsd.tx_hash = tag.tx_hash
{% endmacro %}

