{% macro config_quicknode_polygon_token_udfs(schema_name = "quicknode_polygon_tokens", utils_schema_name = "quicknode_utils") -%}
{#
    This macro is used to generate the QuickNode Polygon Token endpoints
 #}

- name: {{ schema_name -}}.get_token_metadata_by_contract_address
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns token details for specified contract.  [QuickNode docs here](https://www.quicknode.com/docs/polygon/qn_getTokenMetadataByContractAddress_v2).$$
  sql: {{ quicknode_polygon_mainnet_rpc_call(utils_schema_name, 'qn_getTokenMetadataByContractAddress') | trim }}

- name: {{ schema_name -}}.get_token_metadata_by_symbol
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns token details for specified token symbol.  [QuickNode docs here](https://www.quicknode.com/docs/polygon/qn_getTokenMetadataBySymbol_v2).$$
  sql: {{ quicknode_polygon_mainnet_rpc_call(utils_schema_name, 'qn_getTokenMetadataBySymbol') | trim }}

- name: {{ schema_name -}}.get_transactions_by_address
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns transactions within a specified wallet address. [QuickNode docs here](https://www.quicknode.com/docs/polygon/qn_getTransactionsByAddress_v2).$$
  sql: {{ quicknode_polygon_mainnet_rpc_call(utils_schema_name, 'qn_getTransactionsByAddress') | trim }}

- name: {{ schema_name -}}.get_wallet_token_balance
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns ERC-20 tokens and token balances within a wallet. [QuickNode docs here](https://www.quicknode.com/docs/polygon/qn_getWalletTokenBalance_v2).$$
  sql: {{ quicknode_polygon_mainnet_rpc_call(utils_schema_name, 'qn_getWalletTokenBalance') | trim }}

- name: {{ schema_name -}}.get_wallet_token_transactions
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns transfers of a specified token within a specified wallet address. [QuickNode docs here](https://www.quicknode.com/docs/polygon/qn_getWalletTokenTransactions_v2).$$
  sql: {{ quicknode_polygon_mainnet_rpc_call(utils_schema_name, 'qn_getWalletTokenTransactions') | trim }}
{% endmacro %}