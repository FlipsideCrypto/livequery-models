{% macro config_evm_abstractions(blockchain, network) %}
{#
    High level udfs for interacting with the Ethereum Virtual Machine (EVM) via JSON-RPC.

 #}
{%- set schema = blockchain ~ "_" ~ network -%}

- name: {{ schema }}.udf_get_latest_account_balance
  signature:
    - [address, STRING, foo bar]
  return_type: [STRING, foo bar]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the current balance of the account of given address.$$
  sql: |
    SELECT
        ethereum.rpc_eth_get_balance(address, 'latest', '{{- network -}}')
- name: {{ schema }}.udf_get_latest_account_balance
  signature:
    - [address, STRING]
    - [block_or_tag, STRING]
  return_type: [STRING, object with balance and block number]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the balance of the account of given address at the given block.$$
  sql: |
    SELECT
        {# add check for valid block hex or valid tag  #}
        ethereum.rpc_eth_get_balance(address, block_or_tag, '{{- network -}}')

{% endmacro %}