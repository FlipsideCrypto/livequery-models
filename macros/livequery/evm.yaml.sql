{% macro config_evm_high_level_abstractions(blockchain, network) -%}
{#
    This macro is used to generate the high level abstractions for an EVM
    blockchain.
 #}
{% set schema = blockchain ~ "_" ~ network %}
- name: {{ schema -}}.latest_native_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the latest block]
  return_type:
    - "TABLE(wallet_address STRING, blockchain STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the native asset
        * `raw_balance` - The unadjusted native asset balance
        * `balance` - The adjusted native asset balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native asset balance at the latest block for the address.$$
  sql: |
    {{ evm_latest_native_balance_string(schema,  blockchain) | indent(4) -}}
  
- name: {{ schema -}}.latest_native_balance
  signature:
    - [wallets, ARRAY, An array of addresses string to get the balance of at the latest block]
  return_type:
    - "TABLE(wallet_address STRING, blockchain STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the native asset
        * `raw_balance` - The unadjusted native asset balance
        * `balance` - The adjusted native asset balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native asset balance at the latest block for the address.$$
  sql: |
    {{ evm_latest_native_balance_array(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.latest_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the latest block]
    - [token, STRING, The address of the token to get the balance of] 
  return_type:
    - "TABLE(wallet_address STRING, token_address STRING, blockchain STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `token_address` - The token address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balance at the latest block for the address. Supports ERC20 and ERC721.$$
  sql: |
    {{ evm_latest_token_balance_ss(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.latest_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the latest block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of] 
  return_type:
    - "TABLE(wallet_address STRING, token_address STRING, blockchain STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `token_address` - The token address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balance at the latest block for the address for multiple tokens. Supports ERC20 and ERC721.$$
  sql: |
    {{ evm_latest_token_balance_sa(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.latest_token_balance
  signature:
    - [wallets, ARRAY, An array of addresses string to get the balance of at the latest block]
    - [token, STRING, The address of the token to get the balance of]
  return_type:
    - "TABLE(wallet_address STRING, token_address STRING, blockchain STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `token_address` - The token address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the balance at the latest block for the addresses for a given token. Supports ERC20 and ERC721.$$
  sql: |
    {{ evm_latest_token_balance_as(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.latest_token_balance
  signature:
    - [wallets, ARRAY, An array of addresses string to get the balance of at the latest block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of] 
  return_type:
    - "TABLE(wallet_address STRING, token_address STRING, blockchain STRING, symbol STRING, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `token_address` - The token address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the balance at the latest block for multiple addresses for multiple tokens via cartesian product. Supports ERC20 and ERC721.$$
  sql: |
    {{ evm_latest_token_balance_aa(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.historical_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [token, STRING, The address of the token to get the balance of]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(wallet_address STRING, token_address STRING, blockchain STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `token_address` - The token address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `block_number` - The block number
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balance at the input block for the address. Supports ERC20 and ERC721.$$
  sql: |
    {{ evm_historical_token_balance_ssi(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.historical_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [token, STRING, The address of the token to get the balance of]
    - [block_numbers, ARRAY, The block numbers to get the balance at]
  return_type:
    - "TABLE(wallet_address STRING, token_address STRING, blockchain STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `token_address` - The token address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `block_number` - The block number
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balance at the input blocks for the address. Supports ERC20 and ERC721.$$
  sql: |
    {{ evm_historical_token_balance_ssa(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.historical_token_balance
  signature:
    - [wallets, ARRAY, The addresses to get the balance of at the input block]
    - [token, STRING, The address of the token to get the balance of]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(wallet_address STRING, token_address STRING, blockchain STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `token_address` - The token address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `block_number` - The block number
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balance at the input block for multiple addresses. Supports ERC20 and ERC721.$$
  sql: |
    {{ evm_historical_token_balance_asi(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.historical_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(wallet_address STRING, token_address STRING, blockchain STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `token_address` - The token address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `block_number` - The block number
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balance at the input block for the address for multiple tokens. Supports ERC20 and ERC721.$$
  sql: |
    {{ evm_historical_token_balance_sai(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.historical_token_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of]
    - [block_numbers, ARRAY, The block numbers to get the balance at]
  return_type:
    - "TABLE(wallet_address STRING, token_address STRING, blockchain STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `token_address` - The token address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `block_number` - The block number
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balance at the input blocks for the address for multiple tokens. Supports ERC20 and ERC721.$$
  sql: |
    {{ evm_historical_token_balance_saa(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.historical_token_balance
  signature:
    - [wallets, ARRAY, An array of address strings to get the balance of at the input block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(wallet_address STRING, token_address STRING, blockchain STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `token_address` - The token address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `block_number` - The block number
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balance at the input block for multiple addresses for multiple tokens. Supports ERC20 and ERC721.$$
  sql: |
    {{ evm_historical_token_balance_aai(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.historical_token_balance
  signature:
    - [wallets, ARRAY, An array of address strings to get the balance of at the input block]
    - [tokens, ARRAY, An array of address strings of the tokens to get the balance of]
    - [block_numbers, ARRAY, The block numbers to get the balance at]
  return_type:
    - "TABLE(wallet_address STRING, token_address STRING, blockchain STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `token_address` - The token address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `block_number` - The block number
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the token balance at the input blocks for multiple addresses for multiple tokens. Supports ERC20 and ERC721.$$
  sql: |
    {{ evm_historical_token_balance_aaa(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.historical_native_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(wallet_address STRING, blockchain STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `block_number` - The block number
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native balance at the input block for the address.$$
  sql: |
    {{ evm_historical_native_balance_si(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.historical_native_balance
  signature:
    - [wallet, STRING, The address to get the balance of at the input block]
    - [block_numbers, ARRAY, The block numbers to get the balance at]
  return_type:
    - "TABLE(wallet_address STRING, blockchain STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `block_number` - The block number
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native balance at the input blocks for the address.$$
  sql: |
    {{ evm_historical_native_balance_sa(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.historical_native_balance
  signature:
    - [wallets, ARRAY, An array of address strings to get the balance of at the input block]
    - [block_number, INTEGER, The block number to get the balance at]
  return_type:
    - "TABLE(wallet_address STRING, blockchain STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `block_number` - The block number
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native balance at the input block for multiple addresses.$$
  sql: |
    {{ evm_historical_native_balance_ai(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.historical_native_balance
  signature:
    - [wallets, ARRAY, An array of address strings to get the balance of at the input block]
    - [block_numbers, ARRAY, The block numbers to get the balance at]
  return_type:
    - "TABLE(wallet_address STRING, blockchain STRING, symbol STRING, block_number INTEGER, raw_balance STRING, balance FLOAT)"
    - |
        The table has the following columns:
        * `wallet_address` - The wallet address
        * `blockchain` - The blockchain
        * `symbol` - The symbol of the token
        * `block_number` - The block number
        * `raw_balance` - The unadjusted token balance
        * `balance` - The adjusted token balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native balance at the input blocks for multiple addresses.$$
  sql: |
    {{ evm_historical_native_balance_aa(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.latest_contract_events
  signature:
    - [address, STRING, The address of the contract to get the events of]
  return_type:
    - "TABLE(blockchain STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, contract_address STRING, event_topics ARRAY, event_data STRING)"
    - |
        The table has the following columns:
        * `blockchain` - The blockchain
        * `tx_hash` - The transaction hash
        * `block_number` - The block number
        * `event_index` - The index of the event in the transaction
        * `contract_address` - The address of the contract
        * `event_topics` - The topics of the event
        * `event_data` - The data of the event
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns events in the last 100 blocks for the contract.$$
  sql: |
    {{ evm_latest_contract_events_s(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.latest_contract_events
  signature:
    - [address, STRING, The address of the contract to get the events of]
    - [lookback, INTEGER, The number of blocks to look back. Please note there are RPC limitations on this method.]
  return_type:
    - "TABLE(blockchain STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, contract_address STRING, event_topics ARRAY, event_data STRING)"
    - |
        The table has the following columns:
        * `blockchain` - The blockchain
        * `tx_hash` - The transaction hash
        * `block_number` - The block number
        * `event_index` - The index of the event in the transaction
        * `contract_address` - The address of the contract
        * `event_topics` - The topics of the event
        * `event_data` - The data of the event
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns events in the last `lookback` blocks for the contract.$$
  sql: |
    {{ evm_latest_contract_events_si(schema,  blockchain) | indent(4) -}}
  
- name: {{ schema -}}.latest_contract_events
  signature:
    - [addresses, ARRAY, The addresses of the contracts to get the events of]
  return_type:
    - "TABLE(blockchain STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, contract_address STRING, event_topics ARRAY, event_data STRING)"
    - |
        The table has the following columns:
        * `blockchain` - The blockchain
        * `tx_hash` - The transaction hash
        * `block_number` - The block number
        * `event_index` - The index of the event in the transaction
        * `contract_address` - The address of the contract
        * `event_topics` - The topics of the event
        * `event_data` - The data of the event
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns events in the last 100 blocks for the contracts.$$
  sql: |
    {{ evm_latest_contract_events_a(schema,  blockchain) | indent(4) -}}

- name: {{ schema -}}.latest_contract_events
  signature:
    - [addresses, ARRAY, The addresses of the contracts to get the events of]
    - [lookback, INTEGER, The number of blocks to look back. Please note there are RPC limitations on this method.]
  return_type:
    - "TABLE(blockchain STRING, tx_hash STRING, block_number INTEGER, event_index INTEGER, contract_address STRING, event_topics ARRAY, event_data STRING)"
    - |
        The table has the following columns:
        * `blockchain` - The blockchain
        * `tx_hash` - The transaction hash
        * `block_number` - The block number
        * `event_index` - The index of the event in the transaction
        * `contract_address` - The address of the contract
        * `event_topics` - The topics of the event
        * `event_data` - The data of the event
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns events in the last `lookback` blocks for the contracts.$$
  sql: |
    {{ evm_latest_contract_events_ai(schema,  blockchain) | indent(4) -}}
{%- endmacro -%}


