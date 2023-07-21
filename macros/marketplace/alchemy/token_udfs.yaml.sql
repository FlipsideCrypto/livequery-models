{% macro config_alchemy_tokens_udfs(schema_name = "alchemy_tokens", utils_schema_name = "alchemy_utils") -%}
{#
    This macro is used to generate the alchemy token endpoints
 #}

- name: {{ schema_name -}}.get_token_allowance
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [PARAMS, ARRAY, Array of JSON param objects for RPC request]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the amount which the spender is allowed to withdraw from the owner. [Alchemy docs here](https://docs.alchemy.com/reference/alchemy-gettokenallowance).$$
  sql: {{alchemy_rpc_call(utils_schema_name, "alchemy_getTokenAllowance") | trim}}

- name: {{ schema_name -}}.get_token_balances
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [PARAMS, ARRAY, Array of JSON param objects for RPC request]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns ERC20 token balances for all tokens the given address has ever transacted in with. Optionally accepts a list of contracts. [Alchemy docs here](https://docs.alchemy.com/reference/alchemy-gettokenbalances).$$
  sql: {{alchemy_rpc_call(utils_schema_name, "alchemy_getTokenBalances") | trim}}

- name: {{ schema_name -}}.get_token_metadata
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [PARAMS, ARRAY, Array of JSON param objects for RPC request]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns metadata (name, symbol, decimals, logo) for a given token contract address. [Alchemy docs here](https://docs.alchemy.com/reference/alchemy-gettokenmetadata).$$
  sql: {{alchemy_rpc_call(utils_schema_name, "alchemy_getTokenMetadata") | trim}}
{% endmacro %}