{% macro evm_latest_block_height(schema, blockchain, network) %}
    SELECT
        {{ schema }}.udf_rpc('eth_blockNumber', []) as result,
        utils.udf_hex_to_int(result)::integer AS latest_block_height,
        COALESCE(
            block_height,
            latest_block_height
        ) AS min_height,
        iff(
            COALESCE(to_latest, false),
            latest_block_height,
            min_height
        ) AS max_height
{% endmacro %}

{% macro evm_target_blocks(schema, blockchain, network, batch_size=10) %}
    WITH heights AS (
        {{ evm_latest_block_height(schema, blockchain, network) | indent(4) -}}
    ),
    block_spine AS (
        SELECT
            ROW_NUMBER() OVER (
                ORDER BY
                    NULL
            ) - 1 + COALESCE(block_height, latest_block_height)::integer AS block_number,
            min_height,
            IFF(
                COALESCE(to_latest, false),
                block_height,
                min_height
            ) AS max_height,
            latest_block_height
        FROM
            TABLE(generator(ROWCOUNT => COALESCE(block_size, 1))),
            heights qualify block_number BETWEEN min_height
            AND max_height
    )

    SELECT
        CEIL(ROW_NUMBER() OVER (ORDER BY block_number) / {{ batch_size }}) AS batch_id,
        block_number,
        latest_block_height
    FROM block_spine
{% endmacro %}

{% macro evm_batch_udf_api(blockchain, network) %}
    live.udf_api(
        '{endpoint}'
        ,params
        ,concat_ws('/', 'integration', _utils.udf_provider(), '{{ blockchain }}', '{{ network }}')
    )::VARIANT:data::ARRAY AS data
{% endmacro %}

-- Get Raw EVM chain data
{% macro evm_bronze_blocks(schema, blockchain, network, table_name) %}
WITH blocks_agg AS (
    SELECT
        batch_id,
        ARRAY_AGG(
            utils.udf_json_rpc_call(
                'eth_getBlockByNumber',
                [utils.udf_int_to_hex(block_number), true]
            )
        ) AS params
    FROM
        {{ table_name }}
    GROUP BY batch_id
), result as (
    SELECT
        {{ evm_batch_udf_api(blockchain, network) }}
    FROM blocks_agg
)
, flattened as (
    SELECT
        COALESCE(value:result, {'error':value:error}) AS result
    FROM result, LATERAL FLATTEN(input => result.data) v
)

SELECT
    0 AS partition_key,
    utils.udf_hex_to_int(result:number::STRING)::INT AS block_number,
    result as data,
    SYSDATE() AS _inserted_timestamp
FROM flattened
{% endmacro %}

{% macro evm_bronze_receipts(schema, blockchain, network, table_name) %}
WITH blocks_agg AS (
    SELECT
        batch_id,
        latest_block_height,
        ARRAY_AGG(
            utils.udf_json_rpc_call(
                'eth_getBlockReceipts',
                [utils.udf_int_to_hex(block_number)]
            )
        ) AS params
    FROM
        {{ table_name }}
    GROUP BY 1,2
),

get_batch_result AS (
    SELECT
        latest_block_height,
        {{ evm_batch_udf_api(blockchain, network) }}
    FROM blocks_agg
)

SELECT
    0 AS partition_key,
    latest_block_height,
    utils.udf_hex_to_int(w.value:blockNumber::STRING)::INT AS block_number,
    w.index AS array_index,
    w.value AS DATA,
    SYSDATE() AS _inserted_timestamp
FROM
    (SELECT
        latest_block_height,
        v.value:result AS DATA
    FROM get_batch_result,
        LATERAL FLATTEN(data) v), LATERAL FLATTEN(data) w
{% endmacro %}

{% macro evm_bronze_transactions(table_name) %}
    SELECT
        0 AS partition_key,
        block_number,
        v.index::INT AS tx_position, -- mimic's streamline's logic to add tx_position
        OBJECT_CONSTRUCT(
            'array_index', v.index::INT
        ) AS VALUE,
        v.value as DATA,
        SYSDATE() AS _inserted_timestamp
    FROM
        {{ table_name }} AS r,
        lateral flatten(r.data:transactions) v
{% endmacro %}

{% macro evm_bronze_traces(schema, blockchain, network, table_name)%}
WITH blocks_agg AS (
    SELECT
        batch_id,
        ARRAY_AGG(
            utils.udf_json_rpc_call(
                'debug_traceBlockByNumber',
                [utils.udf_int_to_hex(s.block_number), {'tracer': 'callTracer'}],
                s.block_number -- to put block_number in the id to retrieve the block numberlater
            )
        ) AS params
    FROM
        {{ table_name }} s
    GROUP BY batch_id
), result as (
    SELECT
        {{ evm_batch_udf_api(blockchain, network) }}
    FROM blocks_agg
), flattened as (
    SELECT
        value:id::INT AS block_number,
        COALESCE(value:result, {'error':value:error}) AS result
    FROM result, LATERAL FLATTEN(input => result.data) v
)

SELECT
    0 AS partition_key,
    s.block_number,
    v.index::INT AS tx_position, -- mimic's streamline's logic to add tx_position
    OBJECT_CONSTRUCT(
        'array_index', v.index::INT
    ) AS VALUE,
    v.value AS DATA,
    SYSDATE() AS _inserted_timestamp
FROM flattened s,
LATERAL FLATTEN(input => result) v
{% endmacro %}

{% macro evm_fact_blocks(schema, blockchain, network) %}
    {%- set evm__fact_blocks = get_rendered_model('livequery_models', 'evm__fact_blocks', schema, blockchain, network) -%}
    {{ evm__fact_blocks }}
{% endmacro %}

{% macro evm_fact_transactions(schema, blockchain, network) %}
    {%- set evm__fact_transactions = get_rendered_model('livequery_models', 'evm__fact_transactions', schema, blockchain, network, 'False') -%}

    WITH __dbt__cte__core__fact_blocks AS (
        SELECT * FROM table({{ schema }}.tf_fact_blocks(block_height, to_latest, block_size))
    ),

    {{ evm__fact_transactions }}
{% endmacro %}

{% macro evm_fact_event_logs(schema, blockchain, network) %}
    {%- set evm__fact_event_logs = get_rendered_model('livequery_models', 'evm__fact_event_logs', schema, blockchain, network) -%}
    {{ evm__fact_event_logs }}
{% endmacro %}

{% macro evm_fact_traces(schema, blockchain, network) %}
    {%- set evm__fact_traces = get_rendered_model('livequery_models', 'evm__fact_traces', schema, blockchain, network) -%}
    {{ evm__fact_traces }}
{% endmacro %}

{% macro evm_ez_native_transfers(schema, blockchain, network) %}
    {%- set evm__ez_native_transfers = get_rendered_model('livequery_models', 'evm__ez_native_transfers', schema, blockchain, network) -%}
    {{ evm__ez_native_transfers }}
{% endmacro %}

{% macro evm_ez_decoded_event_logs(schema, blockchain, network) %}
    {%- set evm__ez_decoded_event_logs = get_rendered_model('livequery_models', 'evm__ez_decoded_event_logs', schema, blockchain, network) -%}
    {{ evm__ez_decoded_event_logs }}
{% endmacro %}

-- UDTF Return Columns
{% macro get_fact_blocks_columns() %}
    {% set columns = [
        {'name': 'block_number', 'type': 'INTEGER'},
        {'name': 'block_hash', 'type': 'STRING'},
        {'name': 'block_timestamp', 'type': 'TIMESTAMP_NTZ'},
        {'name': 'network', 'type': 'STRING'},
        {'name': 'tx_count', 'type': 'INTEGER'},
        {'name': 'size', 'type': 'INTEGER'},
        {'name': 'miner', 'type': 'STRING'},
        {'name': 'mix_hash', 'type': 'STRING', 'flag': 'uses_mix_hash'},
        {'name': 'extra_data', 'type': 'STRING'},
        {'name': 'parent_hash', 'type': 'STRING'},
        {'name': 'gas_used', 'type': 'INTEGER'},
        {'name': 'gas_limit', 'type': 'INTEGER'},
        {'name': 'base_fee_per_gas', 'type': 'INTEGER', 'flag': 'uses_base_fee'},
        {'name': 'difficulty', 'type': 'INTEGER'},
        {'name': 'total_difficulty', 'type': 'INTEGER', 'flag': 'uses_total_difficulty'},
        {'name': 'sha3_uncles', 'type': 'STRING'},
        {'name': 'uncle_blocks', 'type': 'VARIANT'},
        {'name': 'nonce', 'type': 'INTEGER'},
        {'name': 'receipts_root', 'type': 'STRING'},
        {'name': 'state_root', 'type': 'STRING'},
        {'name': 'transactions_root', 'type': 'STRING'},
        {'name': 'logs_bloom', 'type': 'STRING'},
        {'name': 'blob_gas_used', 'type': 'INTEGER', 'flag': 'uses_blob_gas_used'},
        {'name': 'excess_blob_gas', 'type': 'INTEGER', 'flag': 'uses_blob_gas_used'},
        {'name': 'parent_beacon_block_root', 'type': 'STRING', 'flag': 'uses_parent_beacon_block_root'},
        {'name': 'withdrawals', 'type': 'VARIANT', 'flag': 'uses_withdrawals'},
        {'name': 'withdrawals_root', 'type': 'STRING', 'flag': 'uses_withdrawals'},
        {'name': 'fact_blocks_id', 'type': 'STRING'},
        {'name': 'inserted_timestamp', 'type': 'TIMESTAMP_NTZ'},
        {'name': 'modified_timestamp', 'type': 'TIMESTAMP_NTZ'}
    ] %}
    {{ return(columns) }}
{% endmacro %}

{% macro get_fact_transactions_columns() %}
    {% set columns = [
        {'name': 'block_number', 'type': 'NUMBER'},
        {'name': 'block_timestamp', 'type': 'TIMESTAMP_NTZ'},
        {'name': 'tx_hash', 'type': 'STRING'},
        {'name': 'from_address', 'type': 'STRING'},
        {'name': 'to_address', 'type': 'STRING'},
        {'name': 'origin_function_signature', 'type': 'STRING'},
        {'name': 'value', 'type': 'FLOAT'},
        {'name': 'value_precise_raw', 'type': 'STRING'},
        {'name': 'value_precise', 'type': 'STRING'},
        {'name': 'tx_fee', 'type': 'FLOAT'},
        {'name': 'tx_fee_precise', 'type': 'STRING'},
        {'name': 'tx_succeeded', 'type': 'BOOLEAN'},
        {'name': 'tx_type', 'type': 'NUMBER'},
        {'name': 'nonce', 'type': 'NUMBER'},
        {'name': 'tx_position', 'type': 'NUMBER'},
        {'name': 'input_data', 'type': 'STRING'},
        {'name': 'gas_price', 'type': 'FLOAT'},
        {'name': 'gas_used', 'type': 'NUMBER'},
        {'name': 'gas_limit', 'type': 'NUMBER'},
        {'name': 'cumulative_gas_used', 'type': 'NUMBER'},
        {'name': 'effective_gas_price', 'type': 'NUMBER'},
        {'name': 'max_fee_per_gas', 'type': 'FLOAT', 'flag': 'uses_eip_1559'},
        {'name': 'max_priority_fee_per_gas', 'type': 'FLOAT', 'flag': 'uses_eip_1559'},
        {'name': 'l1_fee', 'type': 'FLOAT', 'flag': 'uses_l1_columns'},
        {'name': 'l1_fee_precise_raw', 'type': 'STRING', 'flag': 'uses_l1_columns'},
        {'name': 'l1_fee_precise', 'type': 'STRING', 'flag': 'uses_l1_columns'},
        {'name': 'l1_fee_scalar', 'type': 'FLOAT', 'flag': 'uses_l1_columns'},
        {'name': 'l1_gas_used', 'type': 'FLOAT', 'flag': 'uses_l1_columns'},
        {'name': 'l1_gas_price', 'type': 'FLOAT', 'flag': 'uses_l1_columns'},
        {'name': 'l1_base_fee_scalar', 'type': 'FLOAT', 'flag': 'uses_l1_columns'},
        {'name': 'l1_blob_base_fee', 'type': 'FLOAT', 'flag': 'uses_blob_base_fee'},
        {'name': 'l1_blob_base_fee_scalar', 'type': 'FLOAT', 'flag': 'uses_blob_base_fee'},
        {'name': 'mint', 'type': 'FLOAT', 'flag': 'uses_mint'},
        {'name': 'mint_precise_raw', 'type': 'STRING', 'flag': 'uses_mint'},
        {'name': 'mint_precise', 'type': 'STRING', 'flag': 'uses_mint'},
        {'name': 'eth_value', 'type': 'FLOAT', 'flag': 'uses_eth_value'},
        {'name': 'eth_value_precise_raw', 'type': 'STRING', 'flag': 'uses_eth_value'},
        {'name': 'eth_value_precise', 'type': 'STRING', 'flag': 'uses_eth_value'},
        {'name': 'y_parity', 'type': 'FLOAT', 'flag': 'uses_y_parity'},
        {'name': 'access_list', 'type': 'VARIANT', 'flag': 'uses_access_list'},
        {'name': 'r', 'type': 'STRING'},
        {'name': 's', 'type': 'STRING'},
        {'name': 'v', 'type': 'NUMBER'},
        {'name': 'source_hash', 'type': 'STRING', 'flag': 'uses_source_hash'},
        {'name': 'fact_transactions_id', 'type': 'STRING'},
        {'name': 'inserted_timestamp', 'type': 'TIMESTAMP_NTZ'},
        {'name': 'modified_timestamp', 'type': 'TIMESTAMP_NTZ'}
    ] %}
    {{ return(columns) }}
{% endmacro %}

{% macro get_fact_traces_columns() %}
    {% set columns = [
        {'name': 'block_number', 'type': 'INTEGER'},
        {'name': 'block_timestamp', 'type': 'TIMESTAMP_NTZ'},
        {'name': 'tx_hash', 'type': 'STRING'},
        {'name': 'tx_position', 'type': 'INTEGER'},
        {'name': 'trace_index', 'type': 'INTEGER'},
        {'name': 'from_address', 'type': 'STRING'},
        {'name': 'to_address', 'type': 'STRING'},
        {'name': 'input', 'type': 'STRING'},
        {'name': 'output', 'type': 'STRING'},
        {'name': 'type', 'type': 'STRING'},
        {'name': 'trace_address', 'type': 'STRING'},
        {'name': 'sub_traces', 'type': 'INTEGER'},
        {'name': 'value', 'type': 'FLOAT'},
        {'name': 'value_precise_raw', 'type': 'STRING'},
        {'name': 'value_precise', 'type': 'STRING'},
        {'name': 'value_hex', 'type': 'STRING'},
        {'name': 'gas', 'type': 'INTEGER'},
        {'name': 'gas_used', 'type': 'INTEGER'},
        {'name': 'origin_from_address', 'type': 'STRING'},
        {'name': 'origin_to_address', 'type': 'STRING'},
        {'name': 'origin_function_signature', 'type': 'STRING'},
        {'name': 'before_evm_transfers', 'type': 'VARIANT', 'flag': 'uses_traces_arb_mode'},
        {'name': 'after_evm_transfers', 'type': 'VARIANT', 'flag': 'uses_traces_arb_mode'},
        {'name': 'trace_succeeded', 'type': 'BOOLEAN'},
        {'name': 'error_reason', 'type': 'STRING'},
        {'name': 'revert_reason', 'type': 'STRING'},
        {'name': 'tx_succeeded', 'type': 'BOOLEAN'},
        {'name': 'fact_traces_id', 'type': 'STRING'},
        {'name': 'inserted_timestamp', 'type': 'TIMESTAMP_NTZ'},
        {'name': 'modified_timestamp', 'type': 'TIMESTAMP_NTZ'}
    ] %}
    {{ return(columns) }}
{% endmacro %}
