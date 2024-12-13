{% macro get_package_model(package_name, model_name) %}
    {%- for node in graph.nodes.values() -%}
        {%- if node.package_name == package_name and node.name == model_name -%}
            {{ return(node) }}
        {%- endif -%}
    {%- endfor -%}

    {# Return None if model not found #}
    {{ return(none) }}
{% endmacro %}

{% macro render_model_sql(package_name, model_name) %}
    {# Get the model #}
    {%- set model = get_package_model(package_name, model_name) -%}
    {%- if not model -%}
        {{ return(none) }}
    {%- endif -%}

    {# Compile/render the SQL #}
    {%- set compiled_sql = render(model.raw_code) -%}

    {# Trim and check if starts with WITH #}
    {%- set trimmed_sql = compiled_sql.strip() -%}
    {%- if trimmed_sql.upper().startswith('WITH ') -%}
        {%- set compiled_sql = ', ' ~ trimmed_sql[5:] -%}
    {%- endif -%}

    {{ return(compiled_sql) }}
{% endmacro %}

{% macro evm_live_view_latest_block_height(schema, blockchain, network) %}
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

{% macro evm_live_view_target_blocks(schema, blockchain, network, batch_size=10) %}
    WITH heights AS (
        {{ evm_live_view_latest_block_height(schema, blockchain, network) | indent(4) -}}
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
            TABLE(generator(ROWCOUNT => 1000)),
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
{% macro evm_live_view_bronze_blocks(schema, blockchain, network, table_name) %}
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
    utils.udf_hex_to_int(result:number::STRING)::INT AS block_number,
    result as data
FROM flattened
{% endmacro %}

{% macro evm_live_view_bronze_receipts(schema, blockchain, network, table_name) %}
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
    latest_block_height,
    utils.udf_hex_to_int(w.value:blockNumber::STRING)::INT AS block_number,
    w.index AS array_index,
    w.value AS DATA
FROM
    (SELECT
        latest_block_height,
        v.value:result AS DATA
    FROM get_batch_result,
        LATERAL FLATTEN(data) v), LATERAL FLATTEN(data) w
{% endmacro %}

{% macro evm_live_view_bronze_logs(table_name) %}
SELECT
    r.block_number,
    v.value
FROM
    {{ table_name }} AS r,
    lateral flatten(r.data:logs) v
{% endmacro %}

{% macro evm_live_view_bronze_transactions(table_name) %}
SELECT
    block_number,
    v.index::INT AS tx_position, -- mimic's streamline's logic to add tx_position
    v.value as DATA
FROM
    {{ table_name }} AS r,
    lateral flatten(r.data:transactions) v
{% endmacro %}

{% macro evm_live_view_bronze_traces(schema, blockchain, network, table_name)%}
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
    s.block_number,
    v.index::INT AS tx_position, -- mimic's streamline's logic to add tx_position
    v.value:result AS full_traces,
    SYSDATE() AS _inserted_timestamp
FROM flattened s,
LATERAL FLATTEN(input => result) v
{% endmacro %}

{% macro evm_live_view_bronze_token_balances(schema, blockchain, network, table_name) %}
WITH block_spine AS (
    SELECT
        CEIL(ROW_NUMBER() OVER (ORDER BY block_number, address, contract_address) / 10) AS batch_id,
        block_number,
        address,
        contract_address
    FROM
        {{ table_name }}
),
blocks_agg AS (
    SELECT
        batch_id,
        ARRAY_AGG(
            utils.udf_json_rpc_call(
                'eth_call',
                ARRAY_CONSTRUCT(
                    OBJECT_CONSTRUCT(
                        'to',
                        contract_address,
                        'data',
                        CONCAT(
                            '0x70a08231000000000000000000000000',
                            SUBSTR(
                                address,
                                3
                            )
                        )
                    ),
                    utils.udf_int_to_hex(block_number)
                ),
                CONCAT(
                    block_number,
                    '-',
                    address,
                    '-',
                    contract_address
                )
            )
        ) AS params
    FROM
        block_spine
    GROUP BY batch_id
), result as (
    SELECT
        {{ evm_batch_udf_api(blockchain, network) }}
    FROM blocks_agg
)

SELECT
    SPLIT(value:id::STRING, '-')[0]::INT AS block_number,
    SPLIT(value:id::STRING, '-')[1]::STRING AS address,
    SPLIT(value:id::STRING, '-')[2]::STRING AS contract_address,
    COALESCE(value:result, {'error':value:error}) AS DATA
FROM result, LATERAL FLATTEN(input => result.data) v
{% endmacro %}

{% macro evm_live_view_bronze_eth_balances(schema, blockchain, network, table_name) %}
WITH block_spine AS (
    SELECT
        CEIL(ROW_NUMBER() OVER (ORDER BY block_number, address) / 10) AS batch_id,
        block_number,
        address
    FROM
        {{ table_name }}
),
blocks_agg AS (
    SELECT
        batch_id,
        ARRAY_AGG(
            utils.udf_json_rpc_call(
                'eth_getBalance',
                ARRAY_CONSTRUCT(address, utils.udf_int_to_hex(block_number)),
                CONCAT(
                    block_number,
                    '-',
                    address
                )
            )
        ) AS params
    FROM
        block_spine
    GROUP BY batch_id
), result as (
    SELECT
        {{ evm_batch_udf_api(blockchain, network) }}
    FROM blocks_agg
)

SELECT
    SPLIT(value:id::STRING, '-')[0]::INT AS block_number,
    SPLIT(value:id::STRING, '-')[1]::STRING AS address,
    COALESCE(value:result, {'error':value:error}) AS DATA
FROM result, LATERAL FLATTEN(input => result.data) v
{% endmacro %}

-- Transformation macro for EVM chains
{% macro evm_silver_blocks(table_name) %}
SELECT
    block_number,
    0 AS partition_key, -- No partition key for realtime data
    data AS block_json,
    {{ dbt_utils.generate_surrogate_key(['block_number']) | indent(4) }} AS blocks_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    'override' AS _invocation_id
FROM
    {{ table_name }}
{% endmacro %}

{% macro evm_silver_receipts(table_name) %}
{% set uses_receipts_by_hash = var('GLOBAL_USES_RECEIPTS_BY_HASH', false) %}

SELECT
    block_number,
    0 AS partition_key,  -- No partition key for realtime data
    {% if uses_receipts_by_hash %}
        tx_hash,
    {% else %}
        array_index,
    {% endif %}
    DATA      AS receipts_json,
    SYSDATE() AS _inserted_timestamp,
    {% if uses_receipts_by_hash %}
        {{ dbt_utils.generate_surrogate_key(['block_number','tx_hash']) }} AS receipts_id,
    {% else %}
        {{ dbt_utils.generate_surrogate_key(['block_number','array_index']) }} AS receipts_id,
    {% endif %}
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    'override' AS _invocation_id
FROM
    {{ table_name }}
{% endmacro %}

{% macro evm_live_view_silver_logs(silver_receipts, silver_transactions) %}
SELECT
    r.block_number,
    txs.block_timestamp,
    r.tx_hash,
    txs.origin_function_signature,
    r.from_address AS origin_from_address,
    r.to_address AS origin_to_address,
    utils.udf_hex_to_int(v.VALUE :logIndex::STRING)::INT AS event_index,
    v.VALUE :address::STRING AS contract_address,
    v.VALUE :blockHash::STRING AS block_hash,
    v.VALUE :data::STRING AS DATA,
    v.VALUE :removed::BOOLEAN AS event_removed,
    v.VALUE :topics AS topics,
    r.tx_status,
    CASE
        WHEN txs.block_timestamp IS NULL
        OR txs.origin_function_signature IS NULL THEN TRUE
        ELSE FALSE
    END AS is_pending,
FROM
    {{ silver_receipts }} AS r
    LEFT JOIN {{ silver_transactions }} AS txs on txs.tx_hash = r.tx_hash,
    lateral flatten(r.logs) v
{% endmacro %}

{% macro evm_live_view_silver_transactions(table_name) %}
SELECT
    block_number,
    0 AS partition_key,  -- No partition key for realtime data
    tx_position,
    DATA AS transaction_json,
    SYSDATE() AS _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(['block_number','tx_position']) }} AS transactions_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    'override' AS _invocation_id
FROM
    {{ table_name }}
{% endmacro %}

{% macro evm_live_view_silver_traces(raw_traces) %}
flatten_traces AS (
    SELECT
        block_number,
        tx_position,
        IFF(
            path IN (
                'result',
                'result.value',
                'result.type',
                'result.to',
                'result.input',
                'result.gasUsed',
                'result.gas',
                'result.from',
                'result.output',
                'result.error',
                'result.revertReason',
                'gasUsed',
                'gas',
                'type',
                'to',
                'from',
                'value',
                'input',
                'error',
                'output',
                'revertReason'
            ),
            'ORIGIN',
            REGEXP_REPLACE(REGEXP_REPLACE(path, '[^0-9]+', '_'), '^_|_$', '')
        ) AS trace_address,
        _inserted_timestamp,
        OBJECT_AGG(
            key,
            VALUE
        ) AS trace_json,
        CASE
            WHEN trace_address = 'ORIGIN' THEN NULL
            WHEN POSITION(
                '_' IN trace_address
            ) = 0 THEN 'ORIGIN'
            ELSE REGEXP_REPLACE(
                trace_address,
                '_[0-9]+$',
                '',
                1,
                1
            )
        END AS parent_trace_address,
        SPLIT(
            trace_address,
            '_'
        ) AS str_array
    FROM
        {{ raw_traces }},
        TABLE(
            FLATTEN(
                input => PARSE_JSON(full_traces),
                recursive => TRUE
            )
        ) f
    WHERE
        f.index IS NULL
        AND f.key != 'calls'
        AND f.path != 'result'
    GROUP BY
        block_number,
        tx_position,
        trace_address,
        _inserted_timestamp
),
sub_traces AS (
    SELECT
        block_number,
        tx_position,
        parent_trace_address,
        COUNT(*) AS sub_traces
    FROM
        flatten_traces
    GROUP BY
        block_number,
        tx_position,
        parent_trace_address
),
num_array AS (
    SELECT
        block_number,
        tx_position,
        trace_address,
        ARRAY_AGG(flat_value) AS num_array
    FROM
        (
            SELECT
                block_number,
                tx_position,
                trace_address,
                IFF(
                    VALUE :: STRING = 'ORIGIN',
                    -1,
                    VALUE :: INT
                ) AS flat_value
            FROM
                flatten_traces,
                LATERAL FLATTEN (
                    input => str_array
                )
        )
    GROUP BY
        block_number,
        tx_position,
        trace_address
),
cleaned_traces AS (
    SELECT
        b.block_number,
        b.tx_position,
        b.trace_address,
        IFNULL(
            sub_traces,
            0
        ) AS sub_traces,
        num_array,
        ROW_NUMBER() over (
            PARTITION BY b.block_number,
            b.tx_position
            ORDER BY
                num_array ASC
        ) - 1 AS trace_index,
        trace_json,
        b._inserted_timestamp
    FROM
        flatten_traces b
        LEFT JOIN sub_traces s
        ON b.block_number = s.block_number
        AND b.tx_position = s.tx_position
        AND b.trace_address = s.parent_trace_address
        JOIN num_array n
        ON b.block_number = n.block_number
        AND b.tx_position = n.tx_position
        AND b.trace_address = n.trace_address
),
final_traces AS (
    SELECT
        tx_position,
        trace_index,
        block_number,
        trace_address,
        trace_json :error :: STRING AS error_reason,
        trace_json :from :: STRING AS from_address,
        trace_json :to :: STRING AS to_address,
        IFNULL(
            utils.udf_hex_to_int(
                trace_json :value :: STRING
            ),
            '0'
        ) AS eth_value_precise_raw,
        ethereum.utils.udf_decimal_adjust(
            eth_value_precise_raw,
            18
        ) AS eth_value_precise,
        eth_value_precise :: FLOAT AS eth_value,
        utils.udf_hex_to_int(
            trace_json :gas :: STRING
        ) :: INT AS gas,
        utils.udf_hex_to_int(
            trace_json :gasUsed :: STRING
        ) :: INT AS gas_used,
        trace_json :input :: STRING AS input,
        trace_json :output :: STRING AS output,
        trace_json :type :: STRING AS TYPE,
        concat_ws(
            '_',
            TYPE,
            trace_address
        ) AS identifier,
        concat_ws(
            '-',
            block_number,
            tx_position,
            identifier
        ) AS _call_id,
        _inserted_timestamp,
        trace_json AS DATA,
        sub_traces
    FROM
        cleaned_traces
),
new_records AS (
    SELECT
        f.block_number,
        t.tx_hash,
        t.block_timestamp,
        t.tx_status,
        f.tx_position,
        f.trace_index,
        f.from_address,
        f.to_address,
        f.eth_value_precise_raw,
        f.eth_value_precise,
        f.eth_value,
        f.gas,
        f.gas_used,
        f.input,
        f.output,
        f.type,
        f.identifier,
        f.sub_traces,
        f.error_reason,
        IFF(
            f.error_reason IS NULL,
            'SUCCESS',
            'FAIL'
        ) AS trace_status,
        f.data,
        IFF(
            t.tx_hash IS NULL
            OR t.block_timestamp IS NULL
            OR t.tx_status IS NULL,
            TRUE,
            FALSE
        ) AS is_pending,
        f._call_id,
        f._inserted_timestamp
    FROM
        final_traces f
        LEFT OUTER JOIN transactions t
        ON f.tx_position = t.position
        AND f.block_number = t.block_number
),
traces_final AS (
    SELECT
        block_number,
        tx_hash,
        block_timestamp,
        tx_status,
        tx_position,
        trace_index,
        from_address,
        to_address,
        eth_value_precise_raw,
        eth_value_precise,
        eth_value,
        gas,
        gas_used,
        input,
        output,
        TYPE,
        identifier,
        sub_traces,
        error_reason,
        trace_status,
        DATA,
        is_pending,
        _call_id,
        _inserted_timestamp
    FROM
        new_records
)
{% endmacro %}

{% macro evm_live_view_silver_token_balances(schema, blockchain, network) %}
WITH silver_logs AS (
    SELECT
        CONCAT('0x', SUBSTR(l.topics [1] :: STRING, 27, 42)) AS address1,
        CONCAT('0x', SUBSTR(l.topics [2] :: STRING, 27, 42)) AS address2,
        l.contract_address,
        l.block_timestamp,
        l.block_number
    FROM
    (
        {{ evm_live_view_fact_event_logs(schema, blockchain, network) | indent(4) -}}
    ) l
    WHERE
        (
            l.topics [0] :: STRING = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'
            OR (
                l.topics [0] :: STRING = '0x7fcf532c15f0a6db0bd6d0e038bea71d30d808c7d98cb3bf7268a95bf5081b65'
                AND l.contract_address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
            )
            OR (
                l.topics [0] :: STRING = '0xe1fffcc4923d04b559f4d29a8bfc6cda04eb5b0d3c460751c2402c5c5cc9109c'
                AND l.contract_address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
            )
        )
),

transfers AS (
    SELECT
        DISTINCT block_number,
        block_timestamp,
        contract_address,
        address1 AS address
    FROM
        silver_logs
    WHERE
        address1 IS NOT NULL
        AND address1 <> '0x0000000000000000000000000000000000000000'
    UNION
    SELECT
        DISTINCT block_number,
        block_timestamp,
        contract_address,
        address2 AS address
    FROM
        silver_logs
    WHERE
        address2 IS NOT NULL
        AND address2 <> '0x0000000000000000000000000000000000000000'
),

balances AS (
    {{ evm_live_view_bronze_token_balances(schema, blockchain, network, 'transfers') | indent(4) -}}
)

SELECT
    b.block_number,
    block_timestamp,
    address,
    contract_address,
    IFF(DATA :: STRING = '{}', NULL, DATA :: STRING) AS casted_data,
    CASE
        WHEN
            LENGTH(
                casted_data
            ) <= 4300
            AND casted_data IS NOT NULL THEN LEFT(casted_data, 66)
        ELSE NULL
        END
    AS hex_balance,
    TRY_TO_NUMBER(
        CASE
            WHEN LENGTH(
                hex_balance
            ) <= 4300
            AND hex_balance IS NOT NULL THEN utils.udf_hex_to_int(hex_balance)
            ELSE NULL
        END
    ) AS balance,
    SYSDATE() AS _inserted_timestamp,
    cast(
        coalesce(
            cast(block_number as TEXT),
            '_dbt_utils_surrogate_key_null_'
        ) || '-' ||
        coalesce(
            cast(address as TEXT),
            '_dbt_utils_surrogate_key_null_'
        ) || '-' ||
        coalesce(
            cast(contract_address as TEXT),
            '_dbt_utils_surrogate_key_null_'
        ) as TEXT
    ) AS id,
    id AS token_balances_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM balances b
LEFT JOIN (
    SELECT DISTINCT block_number, block_timestamp FROM transfers
) USING (block_number)
{% endmacro %}

{% macro evm_live_view_silver_eth_balances(schema, blockchain, network) %}
WITH silver_traces AS (
    SELECT
        block_timestamp,
        block_number,
        from_address,
        to_address
    FROM
    (
        {{ evm_live_view_fact_traces(schema, blockchain, network) | indent(4) -}}
    ) l
    WHERE
        VALUE > 0 -- VALUE is the amount of ETH transferred
        AND trace_status = 'SUCCESS'
        AND tx_status = 'SUCCESS'
),

stacked AS (
    SELECT
        DISTINCT block_number,
        block_timestamp,
        from_address AS address
    FROM
        silver_traces
    WHERE
        from_address IS NOT NULL
        AND from_address <> '0x0000000000000000000000000000000000000000'
    UNION
    SELECT
        DISTINCT block_number,
        block_timestamp,
        to_address AS address
    FROM
        silver_traces
    WHERE
        to_address IS NOT NULL
        AND to_address <> '0x0000000000000000000000000000000000000000'
),

eth_balances AS (
    {{ evm_live_view_bronze_eth_balances(schema, blockchain, network, 'stacked') | indent(4) -}}
)

SELECT
    block_number,
    block_timestamp,
    address,
    IFF(DATA :: STRING = '{}', NULL, DATA :: STRING) AS casted_data,
    CASE
        WHEN casted_data IS NOT NULL THEN casted_data
        ELSE NULL
        END
    AS hex_balance,
    TRY_TO_NUMBER(
        CASE
            WHEN hex_balance IS NOT NULL THEN utils.udf_hex_to_int(hex_balance)
            ELSE NULL
        END
    ) AS balance,
    SYSDATE() AS _inserted_timestamp,
    cast(
        coalesce(
            cast(block_number as TEXT),
            '_dbt_utils_surrogate_key_null_'
        ) || '-' ||
        coalesce(
            cast(address as TEXT),
            '_dbt_utils_surrogate_key_null_'
        ) as TEXT
    ) AS id,
    id AS eth_balances_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM eth_balances
LEFT JOIN (
    SELECT DISTINCT block_number, block_timestamp FROM stacked
) USING (block_number)
{% endmacro %}

-- Get EVM chain fact data
{% macro evm_fact_blocks(schema, blockchain, network) %}
    {%- if execute -%}
    WITH __dbt__cte__silver__blocks AS (
        WITH spine AS (
            {{ evm_live_view_target_blocks(schema, blockchain, network) | indent(4) -}}
        ),

        raw_block_txs AS (
            {{ evm_live_view_bronze_blocks(schema, blockchain, network, 'spine') | indent(4) -}}
        )

        {{ evm_silver_blocks('raw_block_txs') | indent(4) -}}
    )
    {%- set rendered_sql = render_model_sql('fsc_evm', 'core__fact_blocks') -%}
    {{- rendered_sql -}}

    {%- endif -%}
{% endmacro %}

{% macro evm_fact_transactions(schema, blockchain, network) %}
{%- if execute -%}
WITH spine AS (
    {{ evm_live_view_target_blocks(schema, blockchain, network) | indent(4) -}}
),
raw_receipts AS (
    {{ evm_live_view_bronze_receipts(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_block_txs AS (
    {{ evm_live_view_bronze_blocks(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_transactions AS (
    {{ evm_live_view_bronze_transactions('raw_block_txs') | indent(4) -}}
),
__dbt__cte__silver__blocks AS (
    {{ evm_silver_blocks('raw_block_txs') | indent(4) -}}
),
__dbt__cte__silver__transactions AS (
    SELECT
        block_number,
        0 AS partition_key, -- No partition key for realtime data
        tx_position,
        data AS transaction_json,
        SYSDATE() AS _inserted_timestamp,
        {{ dbt_utils.generate_surrogate_key(['block_number','tx_position']) }} AS transactions_id,
        SYSDATE() AS inserted_timestamp,
        SYSDATE() AS modified_timestamp,
        'override' AS _invocation_id
    FROM
        raw_transactions
),
__dbt__cte__silver__receipts AS (
    {{ evm_silver_receipts('raw_receipts') | indent(4) -}}
),
__dbt__cte__core__fact_blocks AS (
    {%- set rendered_sql = render_model_sql('fsc_evm', 'core__fact_blocks') -%}
    {{- rendered_sql -}}
)

    {%- set rendered_sql = render_model_sql('fsc_evm', 'core__fact_transactions') -%}
    {{- rendered_sql -}}
{%- endif -%}
{% endmacro %}

{% macro evm_live_view_fact_event_logs(schema, blockchain, network) %}
WITH spine AS (
    {{ evm_live_view_target_blocks(schema, blockchain, network, 5) | indent(4) -}}
),
raw_block_txs AS (
    {{ evm_live_view_bronze_blocks(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_receipts AS (
    {{ evm_live_view_bronze_receipts(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_logs AS (
    {{ evm_live_view_bronze_logs('raw_receipts') | indent(4) -}}
),
raw_transactions AS (
    {{ evm_live_view_bronze_transactions('raw_block_txs') | indent(4) -}}
),
blocks AS (
    {{ evm_live_view_silver_blocks('raw_block_txs') | indent(4) -}}
),
receipts AS (
    {{ evm_live_view_silver_receipts('raw_receipts') | indent(4) -}}
),
transactions AS (
    {{ evm_live_view_silver_transactions('raw_transactions', 'blocks', 'receipts') | indent(4) -}}
),
logs AS (
    {{ evm_live_view_silver_logs('receipts', 'transactions') | indent(4) -}}
)
SELECT
    block_number,
    block_timestamp,
    tx_hash,
    origin_function_signature,
    origin_from_address,
    origin_to_address,
    event_index,
    contract_address,
    topics,
    DATA,
    event_removed,
    tx_status,
    CONCAT(
        tx_hash :: STRING,
        '-',
        event_index :: STRING
    ) AS _log_id,
    md5(
        cast(
            coalesce(
                cast(tx_hash as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) || '-' || coalesce(
                cast(event_index as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) as TEXT
        )
    ) AS fact_event_logs_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM logs
{% endmacro %}

{% macro evm_live_view_fact_decoded_event_logs(schema, blockchain, network) %}
WITH _ez_decoded_event_logs AS (
    {{ evm_live_view_ez_decoded_event_logs(schema, blockchain, network) | indent(4) -}}
)

SELECT
    block_number,
    block_timestamp,
    tx_hash,
    event_index,
    contract_address,
    event_name,
    decoded_log,
    full_decoded_log,
    fact_decoded_event_logs_id,
    inserted_timestamp,
    modified_timestamp
FROM _ez_decoded_event_logs
{% endmacro %}

{% macro evm_live_view_fact_transactions_bak(schema, blockchain, network) %}

WITH spine AS (
    {{ evm_live_view_target_blocks(schema, blockchain, network, 5) | indent(4) -}}
),
raw_receipts AS (
    {{ evm_live_view_bronze_receipts(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_block_txs AS (
    {{ evm_live_view_bronze_blocks(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_transactions AS (
    {{ evm_live_view_bronze_transactions('raw_block_txs') | indent(4) -}}
),
blocks AS (
    {{ evm_live_view_silver_blocks('raw_block_txs') | indent(4) -}}
),
receipts AS (
    {{ evm_live_view_silver_receipts('raw_receipts') | indent(4) -}}
),
transactions AS (
    {{ evm_live_view_silver_transactions('raw_transactions', 'blocks', 'receipts') | indent(4) -}}
)
SELECT
    block_number,
    block_timestamp,
    block_hash,
    tx_hash,
    nonce,
    POSITION,
    origin_function_signature,
    from_address,
    to_address1 as to_address,
    VALUE,
    value_precise_raw,
    value_precise::STRING as value_precise,
    tx_fee,
    tx_fee_precise::STRING as tx_fee_precise,
    gas_price,
    gas AS gas_limit,
    gas_used,
    cumulative_gas_used,
    input_data,
    tx_status AS status,
    effective_gas_price,
    max_fee_per_gas,
    max_priority_fee_per_gas,
    r,
    s,
    v,
    tx_type,
    chain_id,
    blob_versioned_hashes,
    max_fee_per_blob_gas,
    blob_gas_used,
    blob_gas_price,
    md5(
        cast(
            coalesce(
                cast(tx_hash as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) as TEXT
        )
    ) AS fact_transactions_id,
    SYSDATE() inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    transactions

{% endmacro %}

{% macro evm_live_view_fact_traces(schema, blockchain, network) %}
WITH spine AS (
    {{ evm_live_view_target_blocks(schema, blockchain, network) | indent(4) -}}
),
raw_receipts AS (
    {{ evm_live_view_bronze_receipts(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_block_txs AS (
    {{ evm_live_view_bronze_blocks(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_transactions AS (
    {{ evm_live_view_bronze_transactions('raw_block_txs') | indent(4) -}}
),
blocks AS (
    {{ evm_live_view_silver_blocks('raw_block_txs') | indent(4) -}}
),
receipts AS (
    {{ evm_live_view_silver_receipts('raw_receipts') | indent(4) -}}
),
transactions AS (
    {{ evm_live_view_silver_transactions('raw_transactions', 'blocks', 'receipts') | indent(4) -}}
),
raw_traces AS (
    {{ evm_live_view_bronze_traces(schema, blockchain, network, 'spine') | indent(4) -}}
),

{{ evm_live_view_silver_traces('raw_traces') | indent(4) -}}

SELECT
    tx_hash,
    block_number,
    block_timestamp,
    from_address,
    to_address,
    eth_value AS VALUE,
    eth_value_precise_raw AS value_precise_raw,
    eth_value_precise AS value_precise,
    gas,
    gas_used,
    input,
    output,
    TYPE,
    identifier,
    DATA,
    tx_status,
    sub_traces,
    trace_status,
    error_reason,
    trace_index,
    md5(
        cast(
            coalesce(
                cast(tx_hash as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) || '-' || coalesce(
                cast(trace_index as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) as TEXT
        )
    ) as fact_traces_id,
    COALESCE(
        _inserted_timestamp,
        '2000-01-01'
    ) AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM traces_final
{% endmacro %}

{% macro evm_live_view_fact_decoded_traces(schema, blockchain, network) %}
WITH spine AS (
    {{ evm_live_view_target_blocks(schema, blockchain, network, 5) | indent(4) -}}
),
raw_receipts AS (
    {{ evm_live_view_bronze_receipts(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_block_txs AS (
    {{ evm_live_view_bronze_blocks(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_transactions AS (
    {{ evm_live_view_bronze_transactions('raw_block_txs') | indent(4) -}}
),
blocks AS (
    {{ evm_live_view_silver_blocks('raw_block_txs') | indent(4) -}}
),
receipts AS (
    {{ evm_live_view_silver_receipts('raw_receipts') | indent(4) -}}
),
transactions AS (
    {{ evm_live_view_silver_transactions('raw_transactions', 'blocks', 'receipts') | indent(4) -}}
),
raw_traces AS (
    {{ evm_live_view_bronze_traces(schema, blockchain, network, 'spine') | indent(4) -}}
),

{{ evm_live_view_silver_traces('raw_traces') | indent(4) -}}
,

decoded_traces AS (
    SELECT
        t.block_number,
        t.tx_hash,
        t.block_timestamp,
        t.tx_status,
        t.tx_position,
        t.trace_index,
        t.from_address,
        t.to_address,
        t.eth_value AS VALUE,
        t.eth_value_precise_raw AS value_precise_raw,
        t.eth_value_precise AS value_precise,
        t.gas,
        t.gas_used,
        t.TYPE AS TYPE,
        t.identifier,
        t.sub_traces,
        t.error_reason,
        t.trace_status,
        A.abi AS abi,
        A.function_name AS function_name,
        CASE
            WHEN TYPE = 'DELEGATECALL' THEN from_address
            ELSE to_address
        END AS abi_address,
        t.input AS input,
        COALESCE(
            t.output,
            '0x'
        ) AS output,
        OBJECT_CONSTRUCT('input', input, 'output', output, 'function_name', function_name) AS function_data,
        utils.udf_evm_decode_trace(abi, function_data)[0] AS decoded_data
    FROM traces_final t
    INNER JOIN {{ blockchain }}.SILVER.COMPLETE_FUNCTION_ABIS A
        ON A.parent_contract_address = abi_address
        AND LEFT(
            t.input,
            10
        ) = LEFT(
            A.function_signature,
            10
        )
        AND t.block_number BETWEEN A.start_block
        AND A.end_block
    AND t.block_number IS NOT NULL

)

SELECT
    block_number,
    tx_hash,
    block_timestamp,
    tx_status,
    tx_position,
    trace_index,
    from_address,
    to_address,
    VALUE,
    value_precise_raw,
    value_precise,
    gas,
    gas_used,
    TYPE,
    identifier,
    sub_traces,
    error_reason,
    trace_status,
    input,
    output,
    decoded_data :function_name :: STRING AS function_name,
    decoded_data :decoded_input_data AS decoded_input_data,
    decoded_data :decoded_output_data AS decoded_output_data,
    md5(
        cast(
            coalesce(
                cast(tx_hash as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) || '-' || coalesce(
                cast(trace_index as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) as TEXT
        )
    ) AS fact_decoded_traces_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM decoded_traces
{% endmacro %}

{% macro evm_live_view_fact_token_balances(schema, blockchain, network) %}
WITH silver_token_balances AS (
    {{ evm_live_view_silver_token_balances(schema, blockchain, network) | indent(4) -}}
)

SELECT
    block_number,
    block_timestamp,
    address AS user_address,
    contract_address,
    balance,
    token_balances_id AS fact_token_balances_id,
    inserted_timestamp,
    modified_timestamp
FROM
    silver_token_balances
{% endmacro %}

{% macro evm_live_view_fact_eth_balances(schema, blockchain, network) %}
WITH silver_eth_balances AS (
    {{ evm_live_view_silver_eth_balances(schema, blockchain, network) | indent(4) -}}
)

SELECT
    block_number,
    block_timestamp,
    address AS user_address,
    balance,
    eth_balances_id AS fact_eth_balances_id,
    inserted_timestamp,
    modified_timestamp
FROM silver_eth_balances
{% endmacro %}

-- Get EVM chain ez data
{% macro evm_live_view_ez_decoded_event_logs(schema, blockchain, network) %}
WITH _fact_event_logs AS (
    {{ evm_live_view_fact_event_logs(schema, blockchain, network) | indent(4) -}}
),

_silver_decoded_logs AS (
    SELECT
        block_number,
        block_timestamp,
        tx_hash,
        origin_function_signature,
        origin_from_address,
        origin_to_address,
        event_index,
        topics,
        DATA,
        contract_address,
        OBJECT_CONSTRUCT('topics', topics, 'data', data, 'address', contract_address) AS event_data,
        abi,
        utils.udf_evm_decode_log(abi, event_data)[0] AS decoded_data,
        event_removed,
        decoded_data:name::string AS event_name,
        {{ blockchain }}.utils.udf_transform_logs(decoded_data) AS transformed,
        _log_id,
        inserted_timestamp,
        tx_status
    FROM
        _fact_event_logs
    JOIN
        {{ blockchain }}.core.dim_contract_abis
    USING
        (contract_address)
    WHERE
        tx_status = 'SUCCESS'
),

_flatten_logs AS (
    SELECT
        b.tx_hash,
        b.block_number,
        b.event_index,
        b.event_name,
        b.contract_address,
        b.decoded_data,
        b.transformed,
        b._log_id,
        b.inserted_timestamp,
        OBJECT_AGG(
            DISTINCT CASE
                WHEN v.value :name = '' THEN CONCAT(
                    'anonymous_',
                    v.index
                )
                ELSE v.value :name
            END,
            v.value :value
        ) AS decoded_flat
    FROM
        _silver_decoded_logs b,
        LATERAL FLATTEN(
            input => b.transformed :data
        ) v
    GROUP BY
        b.tx_hash,
        b.block_number,
        b.event_index,
        b.event_name,
        b.contract_address,
        b.decoded_data,
        b.transformed,
        b._log_id,
        b.inserted_timestamp
)

SELECT
    block_number,
    C.block_timestamp,
    B.tx_hash,
    B.event_index,
    B.contract_address,
    D.name AS contract_name,
    B.event_name,
    B.decoded_flat AS decoded_log,
    B.decoded_data AS full_decoded_log,
    C.origin_function_signature,
    C.origin_from_address,
    C.origin_to_address,
    C.topics,
    C.DATA,
    C.event_removed,
    C.tx_status,
    md5(_log_id) AS fact_decoded_event_logs_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM _flatten_logs AS B
LEFT JOIN _silver_decoded_logs AS C USING (block_number, _log_id)
LEFT JOIN {{ blockchain }}.core.dim_contracts AS D
    ON B.contract_address = D.address
{% endmacro %}

{% macro evm_live_view_ez_token_transfers(schema, blockchain, network) %}
WITH fact_logs AS (
    {{ evm_live_view_fact_event_logs(schema, blockchain, network) | indent(4) -}}
)

SELECT
    block_number,
    block_timestamp,
    tx_hash,
    event_index,
    origin_function_signature,
    origin_from_address,
    origin_to_address,
    contract_address::STRING AS contract_address,
    CONCAT('0x', SUBSTR(topics [1], 27, 40))::STRING AS from_address,
    CONCAT('0x', SUBSTR(topics [2], 27, 40))::STRING AS to_address,
    utils.udf_hex_to_int(SUBSTR(DATA, 3, 64)) AS raw_amount_precise,
    raw_amount_precise::FLOAT AS raw_amount,
    IFF(
        C.decimals IS NOT NULL,
        raw_amount_precise * power(10, C.decimals * -1),
        NULL
    ) AS amount_precise,
    amount_precise::FLOAT AS amount,
    IFF(
        C.decimals IS NOT NULL
        AND price IS NOT NULL,
        amount * price,
        NULL
    ) AS amount_usd,
    C.decimals AS decimals,
    C.symbol AS symbol,
    price AS token_price,
    CASE
        WHEN C.decimals IS NULL THEN 'false'
        ELSE 'true'
    END AS has_decimal,
    CASE
        WHEN price IS NULL THEN 'false'
        ELSE 'true'
    END AS has_price,
    _log_id,
    md5(
        cast(
            coalesce(
                cast(tx_hash as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) || '-' || coalesce(
                cast(event_index as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) as TEXT
        )
    ) as ez_token_transfers_id,
    SYSDATE() AS _inserted_timestamp,
    sysdate() as inserted_timestamp,
    sysdate() as modified_timestamp
FROM
    fact_logs l
    LEFT JOIN {{ blockchain }}.price.EZ_PRICES_HOURLY p ON l.contract_address = p.token_address
    AND DATE_TRUNC('hour', l.block_timestamp) = HOUR
    LEFT JOIN {{ blockchain }}.core.DIM_CONTRACTS C ON l.contract_address = C.address
WHERE
    topics [0]::STRING = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'
    AND tx_status = 'SUCCESS'
    and raw_amount IS NOT NULL
    AND to_address IS NOT NULL
AND from_address IS NOT NULL
{% endmacro %}

{% macro evm_live_view_ez_native_transfers(schema, blockchain, network) %}
WITH spine AS (
    {{ evm_live_view_target_blocks(schema, blockchain, network) | indent(4) -}}
),
raw_receipts AS (
    {{ evm_live_view_bronze_receipts(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_block_txs AS (
    {{ evm_live_view_bronze_blocks(schema, blockchain, network, 'spine') | indent(4) -}}
),
raw_transactions AS (
    {{ evm_live_view_bronze_transactions('raw_block_txs') | indent(4) -}}
),
blocks AS (
    {{ evm_live_view_silver_blocks('raw_block_txs') | indent(4) -}}
),
receipts AS (
    {{ evm_live_view_silver_receipts('raw_receipts') | indent(4) -}}
),
transactions AS (
    {{ evm_live_view_silver_transactions('raw_transactions', 'blocks', 'receipts') | indent(4) -}}
),
raw_traces AS (
    {{ evm_live_view_bronze_traces(schema, blockchain, network, 'spine') | indent(4) -}}
),
{{ evm_live_view_silver_traces('raw_traces') | indent(4) -}}
,
eth_base AS (
    SELECT
        tx_hash,
        block_number,
        block_timestamp,
        identifier,
        from_address,
        to_address,
        eth_value AS amount,
        _call_id,
        _inserted_timestamp,
        eth_value_precise_raw AS amount_precise_raw,
        eth_value_precise AS amount_precise,
        tx_position,
        trace_index
    FROM
        traces_final
    WHERE
        eth_value > 0
        AND tx_status = 'SUCCESS'
        AND trace_status = 'SUCCESS'
        AND TYPE NOT IN (
            'DELEGATECALL',
            'STATICCALL'
        )
),
tx_table AS (
    SELECT
        block_number,
        tx_hash,
        from_address AS origin_from_address,
        to_address1 AS origin_to_address,
        origin_function_signature
    FROM
        transactions
    WHERE
        tx_hash IN (
            SELECT
                DISTINCT tx_hash
            FROM
                eth_base
        )
),
native_transfers AS (
    SELECT
        e.tx_hash,
        e.block_number,
        e.block_timestamp,
        e.identifier,
        t.origin_from_address,
        t.origin_to_address,
        t.origin_function_signature,
        e.from_address,
        e.to_address,
        e.amount,
        e.amount_precise_raw,
        e.amount_precise,
        ROUND(
            e.amount * p.price,
            2
        ) AS amount_usd,
        e._call_id,
        e._inserted_timestamp,
        e.tx_position,
        e.trace_index,
        md5(
            cast(
                coalesce(cast(e.tx_hash as TEXT), '_dbt_utils_surrogate_key_null_')
                || '-' || coalesce(cast(e.trace_index as TEXT), '_dbt_utils_surrogate_key_null_')
                as TEXT
            )
        ) as native_transfers_id,
        SYSDATE() as inserted_timestamp,
        SYSDATE() as modified_timestamp
    FROM
        eth_base e
        JOIN tx_table t ON e.tx_hash = t.tx_hash AND e.block_number = t.block_number
        LEFT JOIN {{ blockchain }}.PRICE.EZ_PRICES_HOURLY p
            ON DATE_TRUNC('hour', e.block_timestamp) = p.HOUR
            AND p.token_address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'  -- WETH address
)
SELECT
    tx_hash,
    block_number,
    block_timestamp,
    tx_position,
    trace_index,
    identifier AS trace_type,
    origin_from_address,
    origin_to_address,
    origin_function_signature,
    from_address AS trace_from_address,
    to_address AS trace_to_address,
    amount,
    amount_precise_raw,
    amount_precise,
    amount_usd,
    COALESCE(
        native_transfers_id,
        md5(
            cast(
                coalesce(cast(tx_hash as TEXT), '_dbt_utils_surrogate_key_null_')
                || '-' || coalesce(cast(trace_index as TEXT), '_dbt_utils_surrogate_key_null_')
                as TEXT
            )
        )
    ) AS ez_native_transfers_id,
    COALESCE(
        inserted_timestamp,
        '2000-01-01'
    ) AS inserted_timestamp,
    COALESCE(
        modified_timestamp,
        '2000-01-01'
    ) AS modified_timestamp
FROM
    native_transfers
QUALIFY (ROW_NUMBER() OVER (
    PARTITION BY block_number, tx_position, trace_index
    ORDER BY _inserted_timestamp DESC
)) = 1
{% endmacro %}
