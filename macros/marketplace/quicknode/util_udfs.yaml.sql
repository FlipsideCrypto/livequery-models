{% macro config_quicknode_util_udfs(schema = "quicknode_utils", utils_schema_name="quicknode_utils") -%}
{#
    This macro is used to generate the QuickNode base endpoints
 #}
]
- name: {{ schema -}}.rpc
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [METHOD, STRING, The RPC method to call]
    - [PARAMS, ARRAY, The RPC Params arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue an RPC call to Quicknode.$$
  sql: |
    SELECT livequery.live.udf_api(
      'POST',
      concat('https://{',NETWORK,'}'),
      {},
      {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': PARAMS},
      '_FSC_SYS/QUICKNODE') as response

- name: {{ schema -}}.rpc
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [METHOD, STRING, The RPC method to call]
    - [PARAMS, OBJECT, The RPC Params arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue an RPC call to Quicknode.$$
  sql: |
    SELECT livequery.live.udf_api(
      'POST',
      concat('https://{',NETWORK,'}'),
      {},
      {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': PARAMS},
      '_FSC_SYS/QUICKNODE') as response

{% endmacro %}