{%- set blockchain = this.schema -%}
{%- set network = this.identifier -%}
{%- set schema = blockchain ~ "_" ~ network -%}

WITH spine AS (
    {{ evm_target_blocks(schema, blockchain, network, 10) | indent(4) -}}
),

raw_block_txs AS (
    {{ evm_bronze_blocks(schema, blockchain, network, 'spine') | indent(4) -}}
),

raw_transactions AS (
    {{ evm_bronze_transactions('raw_block_txs') | indent(4) -}}
)

SELECT * FROM raw_transactions
