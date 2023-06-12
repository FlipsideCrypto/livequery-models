{% macro config_evm_rpc_primitives(schema, blockchain) %}
{#
    Generates a set of UDFs that call the Ethereum JSON RPC API

    - eth_getBlockTransactionCountByHash
    - eth_getBlockTransactionCountByNumber
    - eth_getUncleCountByBlockHash
    - eth_getUncleCountByBlockNumber
    - eth_getBlockByHash
    - eth_getBlockByNumber
    - eth_getTransactionByHash
    - eth_getTransactionByBlockHashAndIndex
    - eth_getTransactionByBlockNumberAndIndex
    - eth_getTransactionReceipt
    - eth_getUncleByBlockHashAndIndex
    - eth_getUncleByBlockNumberAndIndex
    - eth_call
    -

 #}
- name: {{ schema -}}.rpc_eth_call
  signature:
    - [transaction, OBJECT]
    - [block_or_tag, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Executes a new message call immediately without creating a transaction on the block chain.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,utils.udf_json_rpc_call('eth_call', [transaction, block_or_tag])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'{{ blockchain }}','mainnet')
        )::VARIANT:data::OBJECT
- name: {{ schema -}}.rpc_eth_call
  signature:
    - [transaction, STRING]
    - [block_or_tag, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Executes a new message call immediately without creating a transaction on the block chain.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,utils.udf_json_rpc_call('eth_call', [transaction, block_or_tag])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'{{ blockchain }}',network)
        )::VARIANT:data::OBJECT


- name: {{ schema -}}.rpc_eth_get_logs
  signature:
    - [filter, OBJECT]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns an array of all logs matching filter with given address.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,utils.udf_json_rpc_call('eth_getLogs', [filter])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'{{ blockchain }}','mainnet')
        )::VARIANT:data::OBJECT
- name: {{ schema -}}.rpc_eth_get_logs
  signature:
    - [filter, OBJECT]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns an array of all logs matching filter with given address.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,utils.udf_json_rpc_call('eth_getLogs', [filter])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'{{ blockchain }}',network)
        )::VARIANT:data::OBJECT


- name: {{ schema -}}.rpc_eth_get_balance
  signature:
    - [address, STRING]
    - [block_or_tag, STRING]
  return_type: OBJECT
  options: |

    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the balance of the account of given address.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,utils.udf_json_rpc_call('eth_getBalance', [address, block_or_tag])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'{{ blockchain }}','mainnet')
        )::VARIANT:data::OBJECT
- name: {{ schema -}}.rpc_eth_get_balance
  signature:
    - [address, STRING]
    - [block_or_tag, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the balance of the account of given address.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,utils.udf_json_rpc_call('eth_getBalance', [address, block_or_tag])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'{{ blockchain }}',network)
        )::VARIANT:data::OBJECT
{% endmacro %}
