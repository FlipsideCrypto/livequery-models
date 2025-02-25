{%- set blockchain = this.schema -%}

SELECT * FROM {{ blockchain.upper() }}.PRICE.EZ_PRICES_HOURLY
