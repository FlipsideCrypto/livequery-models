{%- set blockchain = this.schema -%}

SELECT * FROM {{ blockchain.upper() }}.CORE.DIM_CONTRACTS
