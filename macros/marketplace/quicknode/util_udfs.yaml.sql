{% macro config_quicknode_util_udfs(schema_name = "quicknode_utils", utils_schema_name="quicknode_utils") -%}
{#
    This macro is used to generate the QuickNode base endpoints/RPC calls
 #}

- name: {{ schema_name -}}.ethereum_mainnet_rpc
  signature:
    - [METHOD, STRING, The RPC method to call]
    - [PARAMS, OBJECT, The RPC Params arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue an Ethereum RPC call to QuickNode.$$
  sql: |
    SELECT live.udf_api(
      'POST',
      '{ethereum-mainnet}',
      {},
      {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': [PARAMS]},
      '_FSC_SYS/QUICKNODE'
    ) as response

- name: {{ schema_name -}}.polygon_mainnet_rpc
  signature:
    - [METHOD, STRING, The RPC method to call]
    - [PARAMS, OBJECT, The RPC Params arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a Polygon RPC call to QuickNode.$$
  sql: |
    SELECT live.udf_api(
      'POST',
      '{polygon-matic}',
      {},
      {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': [PARAMS]},
      '_FSC_SYS/QUICKNODE'
    ) as response

- name: {{ schema_name -}}.solana_mainnet_rpc
  signature:
    - [METHOD, STRING, The RPC method to call]
    - [PARAMS, OBJECT, The RPC Params arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a Solana RPC call to QuickNode.$$
  sql: |
    SELECT live.udf_api(
      'POST',
      '{solana-mainnet}',
      {},
      {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': PARAMS},
      '_FSC_SYS/QUICKNODE'
    ) as response

{% endmacro %}