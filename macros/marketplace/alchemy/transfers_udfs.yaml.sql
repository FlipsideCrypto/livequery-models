{% macro config_alchemy_transfers_udfs(schema_name = "alchemy_transfers", utils_schema_name = "alchemy_utils") -%}
{#
    This macro is used to generate the alchemy transfers endpoints
 #}

- name: {{ schema_name -}}.get_asset_transfers
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [PARAMS, ARRAY, Array of JSON param objects for RPC request]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$The Transfers API allows you to easily fetch historical transactions for any address across Ethereum and supported L2s including Polygon, Arbitrum, and Optimism. [Alchemy docs here](https://docs.alchemy.com/reference/alchemy-getassettransfers).$$
  sql: {{alchemy_rpc_call(utils_schema_name, "alchemy_getAssetTransfers") | trim}}

{% endmacro %}