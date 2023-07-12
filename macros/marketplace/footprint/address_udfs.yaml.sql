{% macro config_footprint_address_udfs(schema_name = "footprint_address", utils_schema_name = "footprint_utils") -%}
{#
    This macro is used to generate the footprint address endpoints
 #}

- name: {{ schema_name -}}.get_tx_stats_by_address
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the transactions statistics by a wallet address. [Footprint docs here](https://docs.footprint.network/reference/get_address-transactions-statistics).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/address/transactions/statistics") | trim}}

{% endmacro %}