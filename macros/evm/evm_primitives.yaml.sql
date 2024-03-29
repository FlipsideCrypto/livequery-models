{%- macro config_evm_rpc_primitives(blockchain, network) -%}
{#-
    Generates a set of UDFs that call the Ethereum JSON RPC API

    - rpc: Executes an RPC call on the {{ blockchain }} blockchain
    - eth_call: Executes a new message call immediately without creating a transaction on the block chain
    - eth_getLogs: Returns an array of all logs matching filter with given address
    - eth_getBalance: Returns the balance of the account of given address

 -#}
{% set schema = blockchain ~ "_" ~ network -%}

- name: {{ schema -}}.udf_rpc
  signature:
    - [method, STRING, RPC method to call]
    - [parameters, VARIANT, Parameters to pass to the RPC method]
  return_type: [VARIANT, The return value of the RPC method]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Executes an RPC call on the {{ blockchain }} blockchain.$$
  sql: |
    SELECT live.udf_rpc('{{ blockchain }}', '{{ network }}', method, parameters)

- name: {{ schema -}}.udf_rpc_eth_call
  signature:
    - [transaction, OBJECT, The transaction object]
    - [block_or_tag, STRING, The block number or tag to execute the call on]
  return_type: [VARIANT, The return value of the executed contract code]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Executes a new message call immediately without creating a transaction on the block chain.$$
  sql: |
    SELECT {{ schema -}}.udf_rpc('eth_call', [transaction, block_or_tag])

- name: {{ schema -}}.udf_rpc_eth_get_logs
  signature:
    - [filter, OBJECT, The filter object]
  return_type: [VARIANT, An array of all logs matching filter with given address]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns an array of all logs matching filter with given address.$$
  sql: |
    SELECT {{ schema -}}.udf_rpc('eth_getLogs', [filter])

- name: {{ schema -}}.udf_rpc_eth_get_balance
  signature:
    - [address, STRING, The address to get the balance of]
    - [block_or_tag, STRING, The block number or tag to execute the call on]
  return_type: [VARIANT, The balance of the account of given address]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the balance of the account of given address.$$
  sql: |
    SELECT {{ schema -}}.udf_rpc('eth_getBalance', [address, block_or_tag])

- name: {{ schema -}}.udf_get_token_balance
  signature:
    - [wallet_address, STRING, The address to get the balance of]
    - [token_address, STRING, The token to get the balance of]
  return_type: [STRING, The balance of the account of given address]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the balance of the wallet of given token address at the latest block.$$
  sql: |
    SELECT utils.udf_hex_to_int({{ schema -}}.udf_rpc_eth_call(object_construct_keep_null('from', null, 'to', token_address, 'data', concat('0x70a08231',LPAD(REPLACE(wallet_address, '0x', ''), 64, 0))),'latest')::string)

- name: {{ schema -}}.udf_get_token_balance
  signature:
    - [wallet_address, STRING, The address to get the balance of]
    - [token_address, STRING, The token to get the balance of]
    - [block_number, INTEGER, The block number to retrieve the balance at]
  return_type: [STRING, The balance of the account of given address]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the balance of the wallet of given token address at the given block.$$
  sql: |
    SELECT utils.udf_hex_to_int({{schema}}.udf_rpc_eth_call(OBJECT_CONSTRUCT_KEEP_NULL('from', NULL, 'to', token_address, 'data', concat('0x70a08231',LPAD(REPLACE(wallet_address, '0x', ''), 64, 0))), CONCAT('0x', TRIM(TO_CHAR(block_number, 'XXXXXXXXXX'))))::STRING)

{%- endmacro -%}
