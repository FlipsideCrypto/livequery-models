{% macro evm_rpc_primitives(schema) %}
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

 #}

- name: {{ schema }}.rpc_eth_get_balance
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
            ,live.udf_json_rpc_call('eth_getBalance', [address, block_or_tag])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
        )
- name: {{ schema }}.rpc_eth_get_balance
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
            ,live.udf_json_rpc_call('eth_getBalance', [address, block_or_tag])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
        )

- name: eth_getBlockTransactionCountByHash
  signature:
    - [block_hash, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of transactions in a block from a block matching the given block hash.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,live.udf_json_rpc_call('eth_getBlockTransactionCountByHash', [block_hash])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
        )
- name: eth_getBlockTransactionCountByHash
  signature:
    - [block_hash, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of transactions in a block from a block matching the given block hash.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,live.udf_json_rpc_call('eth_getBlockTransactionCountByHash', [block_hash])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
        )

- name: eth_getBlockTransactionCountByNumber
  signature:
    - [block_number, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of transactions in a block matching the given block number.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,live.udf_json_rpc_call('eth_getBlockTransactionCountByNumber', [block_number])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
        )
- name: eth_getBlockTransactionCountByNumber
  signature:
    - [block_number, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of transactions in a block matching the given block number.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,live.udf_json_rpc_call('eth_getBlockTransactionCountByNumber', [block_number])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
        )

- name: eth_getUncleCountByBlockHash
  signature:
    - [block_hash, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of uncles in a block from a block matching the given block hash.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,live.udf_json_rpc_call('eth_getUncleCountByBlockHash', [block_hash])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
        )
- name: eth_getUncleCountByBlockHash
  signature:
    - [block_hash, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of uncles in a block from a block matching the given block hash.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,live.udf_json_rpc_call('eth_getUncleCountByBlockHash', [block_hash])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
        )

- name: eth_getUncleCountByBlockNumber
  signature:
    - [block_number, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of uncles in a block from a block matching the given block number.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,live.udf_json_rpc_call('eth_getUncleCountByBlockNumber', [block_number])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
        )
- name: eth_getUncleCountByBlockNumber
  signature:
    - [block_number, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of uncles in a block from a block matching the given block number.$$
  sql: |
    SELECT
        live.udf_api(
            '{endpoint}'
            ,live.udf_json_rpc_call('eth_getUncleCountByBlockNumber', [block_number])
            ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
        )

- name: eth_getBlockByHash
  signature:
    - [block_hash, STRING]
    - [full_transaction_objects, BOOLEAN]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a block by hash.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getBlockByHash', [block_hash, full_transaction_objects])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
          )
- name: eth_getBlockByHash
  signature:
    - [block_hash, STRING]
    - [full_transaction_objects, BOOLEAN]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a block by hash.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getBlockByHash', [block_hash, full_transaction_objects])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
          )

- name: eth_getBlockByNumber
  signature:
    - [block_number, STRING]
    - [full_transaction_objects, BOOLEAN]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a block by block number.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getBlockByNumber', [block_number, full_transaction_objects])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
          )
- name: eth_getBlockByNumber
  signature:
    - [block_number, STRING]
    - [full_transaction_objects, BOOLEAN]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a block by block number.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getBlockByNumber', [block_number, full_transaction_objects])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
          )

- name: eth_getTransactionByHash
  signature:
    - [transaction_hash, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the information about a transaction requested by transaction hash.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getTransactionByHash', [transaction_hash])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
          )
- name: eth_getTransactionByHash
  signature:
    - [transaction_hash, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the information about a transaction requested by transaction hash.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getTransactionByHash', [transaction_hash])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
          )

- name: eth_getTransactionByBlockHashAndIndex
  signature:
    - [block_hash, STRING]
    - [transaction_index, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a transaction by block hash and transaction index position.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getTransactionByBlockHashAndIndex', [block_hash, transaction_index])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
          )
- name: eth_getTransactionByBlockHashAndIndex
  signature:
    - [block_hash, STRING]
    - [transaction_index, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a transaction by block hash and transaction index position.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getTransactionByBlockHashAndIndex', [block_hash, transaction_index])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
          )

- name: eth_getTransactionByBlockNumberAndIndex
  signature:
    - [block_number, STRING]
    - [transaction_index, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a transaction by block number and transaction index position.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getTransactionByBlockNumberAndIndex', [block_number, transaction_index])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
          )
- name: eth_getTransactionByBlockNumberAndIndex
  signature:
    - [block_number, STRING]
    - [transaction_index, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a transaction by block number and transaction index position.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getTransactionByBlockNumberAndIndex', [block_number, transaction_index])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
          )

- name: eth_getTransactionReceipt
  signature:
    - [transaction_hash, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the receipt of a transaction by transaction hash.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getTransactionReceipt', [transaction_hash])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
          )
- name: eth_getTransactionReceipt
  signature:
    - [transaction_hash, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the receipt of a transaction by transaction hash.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getTransactionReceipt', [transaction_hash])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
          )

- name: eth_getUncleByBlockHashAndIndex
  signature:
    - [block_hash, STRING]
    - [uncle_index, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a uncle of a block by hash and uncle index position.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getUncleByBlockHashAndIndex', [block_hash, uncle_index])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
          )
- name: eth_getUncleByBlockHashAndIndex
  signature:
    - [block_hash, STRING]
    - [uncle_index, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a uncle of a block by hash and uncle index position.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getUncleByBlockHashAndIndex', [block_hash, uncle_index])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
          )

- name: eth_getUncleByBlockNumberAndIndex
  signature:
    - [block_number, STRING]
    - [uncle_index, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a uncle of a block by number and uncle index position.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getUncleByBlockNumberAndIndex', [block_number, uncle_index])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum','mainnet')
          )
- name: eth_getUncleByBlockNumberAndIndex
  signature:
    - [block_number, STRING]
    - [uncle_index, STRING]
    - [network, STRING]
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns information about a uncle of a block by number and uncle index position.$$
  sql: |
      SELECT
          live.udf_api(
              '{endpoint}'
              ,live.udf_json_rpc_call('eth_getUncleByBlockNumberAndIndex', [block_number, uncle_index])
              ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
          )

- name: eth_getUncleCountByBlockHash
  signature:
    - [block_hash, STRING]
  return_type: STRING
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of uncles in a block from a block matching the given block hash.$$
  sql: |
      SELECT
          live.udf_json_rpc_call('eth_getUncleCountByBlockHash', [block_hash])
- name: eth_getUncleCountByBlockHash
  signature:
    - [block_hash, STRING]
    - [network, STRING]
  return_type: STRING
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of uncles in a block from a block matching the given block hash.$$
  sql: |
      SELECT
          live.udf_json_rpc_call('eth_getUncleCountByBlockHash', [block_hash])
          ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
          )

- name: eth_getUncleCountByBlockNumber
  signature:
    - [block_number, STRING]
  return_type: STRING
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of uncles in a block from a block matching the given block number.$$
  sql: |
      SELECT
          live.udf_json_rpc_call('eth_getUncleCountByBlockNumber', [block_number])
- name: eth_getUncleCountByBlockNumber
  signature:
    - [block_number, STRING]
    - [network, STRING]
  return_type: STRING
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the number of uncles in a block from a block matching the given block number.$$
  sql: |
      SELECT
          live.udf_json_rpc_call('eth_getUncleCountByBlockNumber', [block_number])
          ,concat_ws('/', 'integration',_utils.udf_provider(),'ethereum',network
          )

{% endmacro %}
