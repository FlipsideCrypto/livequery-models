{% macro get_rendered_model(package_name, model_name, schema, blockchain, network) %}
    {% if execute %}
    {{ log("=== Starting get_rendered_model ===", info=True) }}
    {# Use a list to store the node to avoid scope issues #}
    {%- set nodes = [] -%}
    {{ log("Looking for node: " ~ package_name ~ "." ~ model_name, info=True) }}
    {%- for node in graph.nodes.values() -%}
        {%- if node.package_name == package_name and node.name == model_name -%}
            {{ log("Found target node: " ~ node.unique_id, info=True) }}
            {%- do nodes.append(node) -%}
        {%- endif -%}
    {%- endfor -%}

    {%- if nodes | length == 0 -%}
        {{ log("No target node found!", info=True) }}
        {{ return('') }}
    {%- endif -%}

    {%- set target_node = nodes[0] -%}
    {{ log("Processing node: " ~ target_node.unique_id, info=True) }}
    {{ log("Dependencies: " ~ target_node.depends_on.nodes | join(", "), info=True) }}

    {# First render all dependency CTEs #}
    {%- set ctes = [] -%}
    {%- for dep_id in target_node.depends_on.nodes -%}
        {%- set dep_node = graph.nodes[dep_id] -%}
        {%- set rendered_sql = render(dep_node.raw_code) | trim -%}

        {%- if rendered_sql -%}
            {%- set cte_sql -%}
__dbt__cte__{{ dep_node.name }} AS (
    {{ rendered_sql }}
)
            {%- endset -%}
            {%- do ctes.append(cte_sql) -%}
        {%- endif -%}
    {%- endfor -%}

    {{ log("Number of CTEs generated: " ~ ctes | length, info=True) }}

    {# Combine CTEs with main query #}
    {%- set final_sql -%}
WITH {{ ctes | join(',\n\n') }}

{{ render(target_node.raw_code) }}
    {%- endset -%}

    {{ log("=== End get_rendered_model ===", info=True) }}

    {{ return(final_sql) }}
    {% endif %}
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
    0 AS partition_key,
    utils.udf_hex_to_int(result:number::STRING)::INT AS block_number,
    result as data,
    SYSDATE() AS _inserted_timestamp
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

{% macro evm_live_view_bronze_transactions(table_name) %}
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
    0 AS partition_key,
    s.block_number,
    v.index::INT AS tx_position, -- mimic's streamline's logic to add tx_position
    v.value:result AS full_traces,
    SYSDATE() AS _inserted_timestamp
FROM flattened s,
LATERAL FLATTEN(input => result) v
{% endmacro %}

{% macro evm_fact_blocks(schema, blockchain, network) %}
    {%- set evm__fact_blocks = get_rendered_model('livequery_models', 'evm__fact_blocks', schema, blockchain, network) -%}
    {{ evm__fact_blocks }}
{% endmacro %}

{% macro evm_fact_transactions(schema, blockchain, network) %}
    {%- set evm__fact_transactions = get_rendered_model('livequery_models', 'evm__fact_transactions', schema, blockchain, network) -%}
    {{ evm__fact_transactions }}
{% endmacro %}
