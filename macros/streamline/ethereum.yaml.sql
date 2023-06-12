{% macro etheruem_udfs_config(network) %}
{#
    High level udfs for interacting with the Ethereum Virtual Machine (EVM) via JSON-RPC.

 #}


- name: etheruem_{{ network }}.udf_get_latest_account_balance
  comment: |
    Returns the current balance of the account of given address.
  signature:
    - [address, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
  sql: |
    SELECT
        etheruem.rpc_eth_get_balance(address, 'latest', '{{ network }}')
- name: etheruem_{{ network }}.udf_get_latest_account_balance
  comment: |
    Returns the balance of the account of given address at the given block.
  signature:
    - [address, STRING]
    - [block_or_tag, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
  sql: |
    SELECT
        {# add check for valid block hex or valid tag  #}
        etheruem.rpc_eth_get_balance(address, block_or_tag, '{{ network }}')
