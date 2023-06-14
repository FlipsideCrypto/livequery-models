{%- macro config_evm_rpc_primitives(schema, blockchain) -%}
{#-
    Generates a set of UDFs that call the Ethereum JSON RPC API

    - eth_call
    - eth_getLogs
    - eth_getBalance

 -#}
- name: {{ schema -}}.rpc
  signature:
    - [method, STRING, RPC method to call]
    - [parameters, VARIANT, Parameters to pass to the RPC method]
  return_type: [VARIANT, The return value of the RPC method]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Executes a new message call immediately without creating a transaction on the block chain.$$
  sql: |
    {{ sql_live_rpc_call("method", "parameters", blockchain, "'mainnet'") | indent(4) -}}
- name: {{ schema -}}.rpc
  signature:
    - [method, STRING, RPC method to call]
    - [parameters, VARIANT, Parameters to pass to the RPC method]
    - [network, STRING, The network to execute the call on]
  return_type: [VARIANT, The return value of the RPC method]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Executes a new message call immediately without creating a transaction on the block chain.$$
  sql: |
    {{ sql_live_rpc_call("method", "parameters", blockchain, "network") | indent(4) -}}

- name: {{ schema -}}.rpc_eth_call
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
    SELECT {{ schema -}}.rpc('eth_call', [transaction, block_or_tag])
- name: {{ schema -}}.rpc_eth_call
  signature:
    - [transaction, OBJECT, The transaction object]
    - [block_or_tag, STRING, The block number or tag to execute the call on]
    - [network, STRING, The network to execute the call on]
  return_type: [VARIANT, The return value of the executed contract code]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Executes a new message call immediately without creating a transaction on the block chain.$$
  sql: |
    SELECT {{ schema -}}.rpc('eth_call', [transaction, block_or_tag], network)

- name: {{ schema -}}.rpc_eth_get_logs
  signature:
    - [filter, OBJECT, The filter object]
  return_type: [VARIANT, An array of all logs matching filter with given address]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns an array of all logs matching filter with given address.$$
  sql: |
    SELECT {{ schema -}}.rpc('eth_getLogs', [filter])
- name: {{ schema -}}.rpc_eth_get_logs
  signature:
    - [filter, OBJECT, The filter object]
    - [network, STRING, The network to execute the call on]
  return_type: [VARIANT, An array of all logs matching filter with given address]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns an array of all logs matching filter with given address.$$
  sql: |
    SELECT {{ schema -}}.rpc('eth_getLogs', [filter], network)

- name: {{ schema -}}.rpc_eth_get_balance
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
    SELECT {{ schema -}}.rpc('eth_getBalance', [address, block_or_tag])
- name: {{ schema -}}.rpc_eth_get_balance
  signature:
    - [address, STRING, The address to get the balance of]
    - [block_or_tag, STRING, The block number or tag to execute the call on]
    - [network, STRING, The network to execute the call on]
  return_type: [VARIANT, The balance of the account of given address]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the balance of the account of given address.$$
  sql: |
    SELECT {{ schema -}}.rpc('eth_getBalance', [address, block_or_tag], network)

{%- endmacro -%}
