{% macro config_helius_util_udfs(schema = "helius_utils", utils_schema_name="helius_utils") -%}
{#
    This macro is used to generate the Helius base endpoints
 #}

- name: {{ schema -}}.rpc
  signature:
    - [NETWORK, STRING, The network 'devnet' or 'mainnet']
    - [METHOD, STRING, The RPC method to call]
    - [PARAMS, OBJECT, The RPC Params arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue an RPC call to Helius.$$
  sql: |
    SELECT live.udf_api(
      'POST',
      NETWORK,
      {},
      {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': PARAMS},
      '_FSC_SYS/HELIUS'
    ) as response

{% endmacro %}