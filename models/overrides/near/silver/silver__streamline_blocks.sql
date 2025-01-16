-- models/silver/silver__streamline_blocks.sql
{{ config(
    materialized = 'ephemeral',
    tags = ['near_models','core','override']
) }}

{%- set blockchain = this.schema -%}
{%- set network = this.identifier -%}
{%- set schema = blockchain ~ "_" ~ network -%}


WITH heights AS (
    {{ near_live_view_latest_block_height() | indent(4) -}}
),

spine AS (
    {{ near_live_view_get_spine('heights') | indent(4) -}}
),

raw_blocks AS (
    {{ near_live_view_get_raw_block_data('spine', schema ) | indent(4) -}}
)

SELECT * FROM raw_blocks



{# WITH context AS (
    SELECT
        CURRENT_SESSION() as session_id,
        CURRENT_STATEMENT() as stmt,
        -- Extract block_id
        TRY_CAST(REGEXP_SUBSTR(stmt, '\\w+\\((\\d+),', 1, 1, 'e', 1) AS NUMBER) as stmt_block_id,
        -- Extract to_latest with improved regex
        CASE
            WHEN REGEXP_SUBSTR(stmt, '\\w+\\((\\d+),\\s*(TRUE|FALSE)\\)', 1, 1, 'i', 2) = 'TRUE' THEN TRUE
            WHEN REGEXP_SUBSTR(stmt, '\\w+\\((\\d+),\\s*(TRUE|FALSE)\\)', 1, 1, 'i', 2) = 'FALSE' THEN FALSE
            ELSE FALSE
        END as to_latest,
        CURRENT_USER() as user_name,
        CURRENT_ROLE() as role_name,
        CURRENT_TRANSACTION() as transaction_id
),
heights AS (
    SELECT
        live.udf_api(
            'https://rpc.mainnet.near.org',
            utils.udf_json_rpc_call(
                'block',
                {'finality': 'final'}
            )
        ):data AS result,
        result:result:header:height::integer as latest_block_height,
        latest_block_height as min_height,  -- Fixed min_height reference
        latest_block_height as max_height,  -- Fixed max_height reference
        context.*  -- Include context in output for testing
    FROM context
),
spine AS (
    SELECT
        block_height,
        ROW_NUMBER() OVER (ORDER BY block_height) - 1 as partition_num
    FROM
        (
            SELECT
                row_number() over (order by seq4()) - 1 + h.min_height as block_height,
                h.min_height,
                h.max_height
            FROM
                table(generator(ROWCOUNT => 1000)),
                heights h
            QUALIFY block_height BETWEEN h.min_height AND h.max_height
        )
),
raw_blocks AS (
    WITH block_urls AS (
        SELECT
            partition_num,
            BUILD_SCOPED_FILE_URL(
                '@streamline.bronze.near_lake_data_mainnet',
                CONCAT(LPAD(TO_VARCHAR(block_height), 12, '0'), '/block.json')
            ) as url
        FROM spine
    )
    SELECT
        partition_num,
        url,
        PARSE_JSON(near_mainnet.udf_get_block_data(url::STRING)) as block_data
    FROM block_urls
)
SELECT
    block_data:header:height::NUMBER as block_id,
    TO_TIMESTAMP_NTZ(block_data:header:timestamp::STRING) as block_timestamp,
    block_data:header:hash::STRING as block_hash,
    ARRAY_SIZE(block_data:chunks)::STRING as tx_count,
    block_data:author::STRING as block_author,
    block_data:chunks as chunks,
    block_data:header:epoch_id::STRING as epoch_id,
    block_data:header:events as events,
    block_data:header:gas_price::NUMBER as gas_price,
    block_data:header:latest_protocol_version::NUMBER as latest_protocol_version,
    block_data:header:next_epoch_id::STRING as next_epoch_id,
    block_data:header:prev_hash::STRING as prev_hash,
    block_data:header:total_supply::NUMBER as total_supply,
    block_data:header:validator_proposals as validator_proposals,
    block_data:header:validator_reward::NUMBER as validator_reward,
    block_data:header as header,
    partition_num as _partition_by_block_number,
    SYSDATE() as _modified_timestamp,
    SYSDATE() as _inserted_timestamp,
    md5(cast(coalesce(cast(block_data:header:height::NUMBER as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as streamline_blocks_id,
    SYSDATE() as inserted_timestamp,
    SYSDATE() as modified_timestamp,
    'override' as _invocation_id
FROM raw_blocks r #}
