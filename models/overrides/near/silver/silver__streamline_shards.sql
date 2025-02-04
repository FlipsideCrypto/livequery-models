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
block_data AS (
    SELECT 
        s.partition_num,
        s.block_height,
        PARSE_JSON(near_mainnet.udf_get_block_data(
            BUILD_SCOPED_FILE_URL(
                '@streamline.bronze.near_lake_data_mainnet', 
                CONCAT(LPAD(TO_VARCHAR(s.block_height), 12, '0'), '/block.json')
            )
        )) as block_data
    FROM spine s
),
raw_shards AS (
    WITH shard_urls AS (
        SELECT 
            b.partition_num,
            b.block_height,
            s.index as shard_id,
            BUILD_SCOPED_FILE_URL(
                '@streamline.bronze.near_lake_data_mainnet', 
                CONCAT(
                    LPAD(TO_VARCHAR(b.block_height), 12, '0'),
                    '/shard_', 
                    TO_VARCHAR(s.index), 
                    '.json'
                )
            ) as url
        FROM block_data b,
        LATERAL FLATTEN(input => block_data:chunks) s
    )
    SELECT 
        partition_num,
        block_height,
        shard_id,
        url,
        PARSE_JSON(near_mainnet.udf_get_block_data(url::STRING)) as shard_data
    FROM shard_urls
)
SELECT
    block_height,
    concat_ws('-', block_height::STRING, shard_id::STRING) AS shard_id,
    shard_data:chunk::variant AS chunk,
    shard_data:receipt_execution_outcomes::variant AS receipt_execution_outcomes,
    shard_id AS shard_number,
    shard_data:state_changes::variant AS state_changes,
    partition_num AS _partition_by_block_number,
    SYSDATE() AS _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(['shard_id']) }} AS streamline_shards_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    'override' AS _invocation_id
FROM raw_shards
WHERE shard_data IS NOT NULL