{{ config(
    materialized = 'ephemeral',
    tags = ['near_models','bronze','override']
) }}

{%- set blockchain = this.schema -%}
{%- set network = this.identifier -%}
{%- set schema = blockchain ~ "_" ~ network -%}

WITH spine AS (
    {{ near_live_table_target_blocks() | indent(4) -}}
),
raw_blocks AS (
    {{ near_live_table_get_raw_block_data('spine') | indent(4) -}}
)

SELECT *, 
    value as data,
    round(block_height,-3) as partition_key,
    CURRENT_TIMESTAMP() as _inserted_timestamp
FROM raw_blocks