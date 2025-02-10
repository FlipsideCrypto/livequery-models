{%- set blockchain = this.schema -%}
{%- set network = this.identifier -%}
{%- set schema = blockchain ~ "_" ~ network -%}

WITH spine AS (
    {{ evm_live_view_target_blocks(schema, blockchain, network, 10) | indent(4) -}}
),

raw_receipts AS (
    {{ evm_live_view_bronze_receipts(schema, blockchain, network, 'spine') | indent(4) -}}
)

SELECT * FROM raw_receipts
