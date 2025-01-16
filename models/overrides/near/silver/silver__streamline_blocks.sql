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
FROM raw_blocks