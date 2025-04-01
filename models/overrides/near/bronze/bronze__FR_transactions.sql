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

SELECT
    OBJECT_INSERT(
        rb.rpc_data_result,          
        'BLOCK_ID',                 
        rb.block_height,             
        TRUE                         
    ) AS value,
    rb.rpc_data_result AS data,
    round(rb.block_height, -3) AS partition_key,
    CURRENT_TIMESTAMP() AS _inserted_timestamp
FROM
    raw_blocks rb