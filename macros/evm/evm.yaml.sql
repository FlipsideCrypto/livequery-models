{% macro config_evm_high_level_abstractions(blockchain, network) -%}
{#
    This macro is used to generate the high level abstractions for an EVM
    blockchain.
 #}
{% set schema = blockchain ~ "_" ~ network %}
- name: {{ schema -}}.tf_latest_native_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the latest block]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `blockchain` - The blockchain
        * `network` - The network
        * `wallet_address` - The wallet address
        * `symbol` - The symbol of the native asset
        * `raw_balance` - The unadjusted native asset balance
        * `balance` - The adjusted native asset balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native asset balance at the latest block for a given address.$$
  sql: |
    {{ evm_latest_native_balance_string(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_native_balance
  signature:
    - [wallets, ARRAY, An array of addresses string to get the balance of at the latest block]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native asset balances at the latest block for given addresses.$$
  sql: |
    {{ evm_latest_native_balance_array(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the latest block]
    - [token, STRING, The address of the token to get the balance of]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, token_address STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balance at the latest block for a given address and token address. Supports ERC20 and ERC721 tokens.$$
  sql: |
    {{ evm_latest_token_balance_ss(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the latest block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, token_address STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balances at the latest block for a given address and multiple token addresses. Supports ERC20 and ERC721 tokens.$$
  sql: |
    {{ evm_latest_token_balance_sa(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_token_balance
  signature:
    - [wallets, ARRAY, An array of addresses string to get the balance of at the latest block]
    - [token, STRING, The address of the token to get the balance of]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, token_address STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balances at the latest block for multiple addresses and a single token address. Supports ERC20 and ERC721 tokens.$$
  sql: |
    {{ evm_latest_token_balance_as(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_token_balance
  signature:
    - [wallets, ARRAY, An array of addresses string to get the balance of at the latest block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, token_address STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balances at the latest block for multiple addresses and multiple token addresses. Supports ERC20 and ERC721 tokens.$$
  sql: |
    {{ evm_latest_token_balance_aa(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_historical_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [token, STRING, The address of the token to get the balance of]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, token_address STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balance for a given address and token address at a specific block. Supports ERC20 and ERC721 tokens.$$
  sql: |
    {{ evm_historical_token_balance_ssi(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_historical_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [token, STRING, The address of the token to get the balance of]
    - [block_numbers, ARRAY, The block numbers to get the balance at]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, token_address STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balances for a given address and token address at multiple specific blocks. Supports ERC20 and ERC721 tokens.$$
  sql: |
    {{ evm_historical_token_balance_ssa(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_historical_token_balance
  signature:
    - [wallets, ARRAY, The addresses to get the balance of at the input block]
    - [token, STRING, The address of the token to get the balance of]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, token_address STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balances for multiple addresses and a given token addresses at a specific block. Supports ERC20 and ERC721 tokens.$$
  sql: |
    {{ evm_historical_token_balance_asi(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_historical_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, token_address STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balances for a given address and multiple token addresses at a specific block. Supports ERC20 and ERC721 tokens.$$
  sql: |
    {{ evm_historical_token_balance_sai(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_historical_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of]
    - [block_numbers, ARRAY, The block numbers to get the balance at]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, token_address STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balances for a given address and multiple token addresses at multiple specific blocks. Supports ERC20 and ERC721 tokens.$$
  sql: |
    {{ evm_historical_token_balance_saa(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_historical_token_balance
  signature:
    - [wallets, ARRAY, An array of address strings to get the balance of at the input block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, token_address STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balances for multiple addresses and multiple token addresses at a specific block. Supports ERC20 and ERC721 tokens.$$
  sql: |
    {{ evm_historical_token_balance_aai(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_historical_token_balance
  signature:
    - [wallets, ARRAY, An array of address strings to get the balance of at the input block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of]
    - [block_numbers, ARRAY, The block numbers to get the balance at]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, token_address STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balances for multiple addresses and multiple token addresses at multiple specific blocks. Supports ERC20 and ERC721 tokens.$$
  sql: |
    {{ evm_historical_token_balance_aaa(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_historical_native_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native asset balance for a given address at a specific block.$$
  sql: |
    {{ evm_historical_native_balance_si(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_historical_native_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [block_numbers, ARRAY, The block numbers to get the balance at]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native asset balances for a given address at multiple specific blocks.$$
  sql: |
    {{ evm_historical_native_balance_sa(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_historical_native_balance
  signature:
    - [wallets, ARRAY, An array of address strings to get the balance of at the input block]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native asset balances for multiple addresses at a specific block.$$
  sql: |
    {{ evm_historical_native_balance_ai(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_historical_native_balance
  signature:
    - [wallets, ARRAY, An array of address strings to get the balance of at the input block]
    - [block_numbers, ARRAY, The block numbers to get the balance at]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, wallet_address STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native asset balances for multiple addresses at multiple specific blocks.$$
  sql: |
    {{ evm_historical_native_balance_aa(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_contract_events
  signature:
    - [address, STRING, The address of the contract to get the events of]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, contract_address STRING, event_topics ARRAY, event_data STRING)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the latest events emitted by a contract in the last 100 blocks.$$
  sql: |
    {{ evm_latest_contract_events_s(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_contract_events
  signature:
    - [address, STRING, The address of the contract to get the events of]
    - [lookback, INTEGER, The number of blocks to look back. Please note there are RPC limitations on this method.]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, contract_address STRING, event_topics ARRAY, event_data STRING)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the latest events emitted by a contract within the last `lookback` blocks. *Please note there are RPC limitations on this method.*$$
  sql: |
    {{ evm_latest_contract_events_si(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_contract_events
  signature:
    - [addresses, ARRAY, The addresses of the contracts to get the events of]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, contract_address STRING, event_topics ARRAY, event_data STRING)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the latest events emitted by multiple contracts in the last 100 blocks.$$
  sql: |
    {{ evm_latest_contract_events_a(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_contract_events
  signature:
    - [addresses, ARRAY, The addresses of the contracts to get the events of]
    - [lookback, INTEGER, The number of blocks to look back. Please note there are RPC limitations on this method.]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, contract_address STRING, event_topics ARRAY, event_data STRING)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the latest events emitted by multiple contracts within the last `lookback` blocks. *Please note there are RPC limitations on this method.*$$
  sql: |
    {{ evm_latest_contract_events_ai(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_contract_events_decoded
  signature:
    - [address, STRING, The address of the contract to get the decoded events of]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, event_name STRING, contract_address STRING, event_topics ARRAY, event_data STRING, decoded_data OBJECT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$RReturns the latest decoded events emitted by a contract in the last 100 blocks. Submit missing ABIs [here](https://science.flipsidecrypto.xyz/abi-requestor/).$$
  sql: |
    {{ evm_latest_contract_events_decoded_s(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_contract_events_decoded
  signature:
    - [addresses, ARRAY, The addresses of the contracts to get the decoded events of]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, event_name STRING, contract_address STRING, event_topics ARRAY, event_data STRING, decoded_data OBJECT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the latest decoded events emitted by multiple contracts in the last 100 blocks. Submit missing ABIs [here](https://science.flipsidecrypto.xyz/abi-requestor/).$$
  sql: |
    {{ evm_latest_contract_events_decoded_a(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_contract_events_decoded
  signature:
    - [address, STRING, The address of the contract to get the decoded events of]
    - [lookback, INTEGER, The number of blocks to look back. Please note there are RPC limitations on this method.]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, event_name STRING, contract_address STRING, event_topics ARRAY, event_data STRING, decoded_data OBJECT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the latest decoded events emitted by a contract within the last `lookback` blocks. Submit missing ABIs [here](https://science.flipsidecrypto.xyz/abi-requestor/). *Please note there are RPC limitations on this method.*$$
  sql: |
    {{ evm_latest_contract_events_decoded_si(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_latest_contract_events_decoded
  signature:
    - [addresses, ARRAY, The addresses of the contracts to get the decoded events of]
    - [lookback, INTEGER, The number of blocks to look back. Please note there are RPC limitations on this method.]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, event_name STRING, contract_address STRING, event_topics ARRAY, event_data STRING, decoded_data OBJECT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the latest decoded events emitted by multiple contracts within the last `lookback` blocks. Submit missing ABIs [here](https://science.flipsidecrypto.xyz/abi-requestor/). *Please note there are RPC limitations on this method.* $$
  sql: |
    {{ evm_latest_contract_events_decoded_ai(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_fact_blocks
  signature:
    - [block_height, INTEGER, The start block height to get the transfers from]
    - [to_latest, BOOLEAN, Whether to continue fetching transfers until the latest block or not]
  return_type:
    - "TABLE(block_number INTEGER, block_timestamp TIMESTAMP_NTZ, network STRING, blockchain STRING, tx_count INTEGER, difficulty INTEGER, total_difficulty INTEGER, extra_data STRING, gas_limit INTEGER, gas_used INTEGER, hash STRING, parent_hash STRING, miner STRING, nonce INTEGER, receipts_root STRING, sha3_uncles STRING, size INTEGER, uncle_blocks VARIANT, block_header_json OBJECT, excess_blob_gas INTEGER, blob_gas_used INTEGER, fact_blocks_id STRING, inserted_timestamp TIMESTAMP_NTZ, modified_timestamp TIMESTAMP_NTZ, withdrawals VARIANT, withdrawals_root STRING)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the block data for a given block height. If to_latest is true, it will continue fetching blocks until the latest block. Otherwise, it will fetch blocks until the block height is reached.$$
  sql: |
    {{ evm_live_view_fact_blocks(schema, blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_fact_event_logs
  signature:
    - [block_height, INTEGER, The start block height to get the logs from]
    - [to_latest, BOOLEAN, Whether to continue fetching logs until the latest block or not]
  return_type:
    - "TABLE(block_number INTEGER, block_timestamp TIMESTAMP_NTZ, tx_hash STRING, origin_function_signature STRING, origin_from_address STRING, origin_to_address STRING, event_index INTEGER, contract_address STRING, topics VARIANT, data STRING, event_removed BOOLEAN, tx_status STRING, _log_id STRING, fact_event_logs_id STRING, inserted_timestamp TIMESTAMP_NTZ, modified_timestamp TIMESTAMP_NTZ)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the logs for a given block height. If to_latest is true, it will continue fetching logs until the latest block. Otherwise, it will fetch logs until the block height is reached.$$
  sql: |
    {{ evm_live_view_fact_event_logs(schema, blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_fact_decoded_event_logs
  signature:
    - [block_height, INTEGER, The start block height to get the logs from]
    - [to_latest, BOOLEAN, Whether to continue fetching logs until the latest block or not]
  return_type:
    - "TABLE(block_number INTEGER, block_timestamp TIMESTAMP_NTZ, tx_hash STRING, event_index INTEGER, contract_address STRING, event_name STRING, decoded_log OBJECT, full_decoded_log VARIANT, fact_decoded_event_logs_id STRING, inserted_timestamp TIMESTAMP_NTZ, modified_timestamp TIMESTAMP_NTZ)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the decoded event logs data for a given block height. If to_latest is true, it will continue fetching blocks until the latest block. Otherwise, it will fetch blocks until the block height is reached.$$
  sql: |
    {{ evm_live_view_fact_decoded_event_logs(schema, blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_fact_traces
  signature:
    - [block_height, INTEGER, The start block height to get the transfers from]
    - [to_latest, BOOLEAN, Whether to continue fetching transfers until the latest block or not]
  return_type:
    - "TABLE(tx_hash STRING, block_number NUMBER, block_timestamp TIMESTAMP_NTZ(9), from_address STRING, to_address STRING, value FLOAT, value_precise_raw STRING, value_precise STRING, gas NUMBER, gas_used NUMBER, input STRING, output STRING, TYPE STRING, identifier STRING, DATA OBJECT, tx_status STRING, sub_traces NUMBER, trace_status STRING, error_reason STRING, trace_index NUMBER, fact_traces_id STRING, inserted_timestamp TIMESTAMP_NTZ(9), modified_timestamp TIMESTAMP_NTZ(9))"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the traces for a given block height. If to_latest is true, it will continue fetching traces until the latest block. Otherwise, it will fetch traces until the block height is reached.$$
  sql: |
    {{ evm_live_view_fact_traces(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_fact_transactions
  signature:
    - [block_height, INTEGER, The start block height to get the transfers from]
    - [to_latest, BOOLEAN, Whether to continue fetching transfers until the latest block or not]
  return_type:
    - "TABLE(block_number NUMBER, block_timestamp TIMESTAMP_NTZ, block_hash STRING, tx_hash STRING, nonce NUMBER, POSITION NUMBER, origin_function_signature STRING, from_address STRING, to_address STRING, VALUE FLOAT, value_precise_raw STRING, value_precise STRING, tx_fee FLOAT, tx_fee_precise STRING, gas_price FLOAT, gas_limit NUMBER, gas_used NUMBER, cumulative_gas_used NUMBER, input_data STRING, status STRING, effective_gas_price FLOAT, max_fee_per_gas FLOAT, max_priority_fee_per_gas FLOAT, r STRING, s STRING, v STRING, tx_type NUMBER, chain_id NUMBER, blob_versioned_hashes ARRAY, max_fee_per_blob_gas NUMBER, blob_gas_used NUMBER, blob_gas_price NUMBER, fact_transactions_id STRING, inserted_timestamp TIMESTAMP_NTZ, modified_timestamp TIMESTAMP_NTZ)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the transactions for a given block height. If to_latest is true, it will continue fetching transactions until the latest block. Otherwise, it will fetch transactions until the block height is reached.$$
  sql: |
    {{ evm_live_view_fact_transactions(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_ez_decoded_event_logs
  signature:
    - [block_height, INTEGER, The start block height to get the logs from]
    - [to_latest, BOOLEAN, Whether to continue fetching logs until the latest block or not]
  return_type:
    - "TABLE(block_number INTEGER, block_timestamp TIMESTAMP_NTZ, tx_hash STRING, event_index INTEGER, contract_address STRING, contract_name STRING, event_name STRING, decoded_log OBJECT, full_decoded_log VARIANT, origin_function_signature STRING, origin_from_address STRING, origin_to_address STRING, topics VARIANT, data STRING, event_removed BOOLEAN, tx_status STRING, ez_decoded_event_logs_id STRING, inserted_timestamp TIMESTAMP_NTZ, modified_timestamp TIMESTAMP_NTZ)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the ez decoded event logs data for a given block height. If to_latest is true, it will continue fetching blocks until the latest block. Otherwise, it will fetch blocks until the block height is reached.$$
  sql: |
    {{ evm_live_view_ez_decoded_event_logs(schema, blockchain, network) | indent(4) -}}


- name: {{ schema -}}.tf_ez_native_transfers
  signature:
    - [block_height, INTEGER, The start block height to get the transfers from]
    - [to_latest, BOOLEAN, Whether to continue fetching transfers until the latest block or not]
  return_type:
        - "TABLE(tx_hash STRING, block_number NUMBER(38,0), block_timestamp TIMESTAMP_NTZ(9), tx_position NUMBER(38,0), trace_index NUMBER(19,0), identifier STRING, origin_from_address STRING, origin_to_address STRING, origin_function_signature STRING, from_address STRING, to_address STRING, amount FLOAT, amount_precise_raw STRING, amount_precise STRING, amount_usd FLOAT, ez_native_transfers_id STRING, inserted_timestamp TIMESTAMP_NTZ(9), modified_timestamp TIMESTAMP_NTZ(9))"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native transfers for a given block height. If to_latest is true, it will continue fetching transfers until the latest block. Otherwise, it will fetch transfers until the block height is reached.$$
  sql: |
    {{ evm_live_view_ez_native_transfers(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_ez_token_transfers
  signature:
    - [block_height, INTEGER, The start block height to get the transfers from]
    - [to_latest, BOOLEAN, Whether to continue fetching transfers until the latest block or not]
  return_type:
    - "TABLE(block_number INTEGER, block_timestamp TIMESTAMP_NTZ, tx_hash STRING, event_index INTEGER, origin_function_signature STRING, origin_from_address STRING, origin_to_address STRING, contract_address STRING, from_address STRING, to_address STRING, raw_amount_precise STRING, raw_amount FLOAT, amount_precise FLOAT, amount FLOAT, amount_usd FLOAT, decimals INTEGER, symbol STRING, token_price FLOAT, has_decimal STRING, has_price STRING, _log_id STRING, ez_token_transfers_id STRING, _inserted_timestamp TIMESTAMP_NTZ, inserted_timestamp TIMESTAMP_NTZ, modified_timestamp TIMESTAMP_NTZ)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token transfers for a given block height. If to_latest is true, it will continue fetching transfers until the latest block. Otherwise, it will fetch transfers until the block height is reached.$$
  sql: |
    {{ evm_live_view_ez_token_transfers(schema,  blockchain, network) | indent(4) -}}

{%- endmacro -%}


{% macro config_eth_high_level_abstractions(blockchain, network) -%}
{#
    This macro is used to generate high level abstractions for Ethereum mainnet only.
#}
{% set schema = blockchain ~ "_" ~ network %}
- name: {{ schema -}}.tf_all_contract_events
  signature:
    - [address, STRING, The address of the contracts to get the events of]
    - [min_block, INTEGER, The minimum block number to get the events from]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, contract_address STRING, event_topics ARRAY, event_data STRING)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the events emitted by a contract from a specific block to the latest block.$$
  sql: |
    {{ evm_contract_events(schema,  blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_all_contract_events_decoded
  signature:
    - [address, STRING, The address of the contracts to get the events of]
    - [min_block, INTEGER, The minimum block number to get the events from]
  return_type:
    - "TABLE(status STRING, blockchain STRING, network STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, event_name STRING, contract_address STRING, event_topics ARRAY, event_data STRING, decoded_data OBJECT)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the decoded events emitted by a contract from a specific block to the latest block. Submit missing ABIs [here](https://science.flipsidecrypto.xyz/abi-requestor/).$$
  sql: |
    {{ evm_contract_events_decoded(schema,  blockchain, network) | indent(4) -}}
{%- endmacro -%}
