{% macro config_footprint_balances_udfs(schema_name = "footprint_balances", utils_schema_name = "footprint_utils") -%}
{#
    This macro is used to generate the footprint balance endpoints
 #}

- name: {{ schema_name -}}.get_native_balance_by_address
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the native balance by a wallet address. [Footprint docs here](https://docs.footprint.network/reference/get_address-native-balance).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/address/native/balance") | trim}}

- name: {{ schema_name -}}.get_all_nfts_owned_by_address
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns all NFTs owned by a wallet address. [Footprint docs here](https://docs.footprint.network/reference/get_nft-wallet-balance).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/wallet/balance") | trim}}

- name: {{ schema_name -}}.get_all_erc20_balance_by_address
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns all ERC20 balance by a wallet address. [Footprint docs here](https://docs.footprint.network/reference/get_address-erc20-balance).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/address/erc20/balance") | trim}}

- name: {{ schema_name -}}.get_nft_owned_by_address
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the specified NFT owned by a wallet address. [Footprint docs here](https://docs.footprint.network/reference/get_nft-balance).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/balance") | trim}}

- name: {{ schema_name -}}.get_erc20_balance_by_address
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the specified ERC20 balance by a wallet address. [Footprint docs here](https://docs.footprint.network/reference/get_token-balance).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/token/balance") | trim}}

{% endmacro %}