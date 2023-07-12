{% macro config_footprint_chain_udfs(schema_name = "footprint_chains", utils_schema_name = "footprint_utils") -%}
{#
    This macro is used to generate the Footprint token endpoints
 #}

- name: {{ schema_name -}}.get_chain_transactions
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the transactions of the chain. [Footprint docs here](https://docs.footprint.network/reference/get_chain-transactions).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/chain/transactions") | trim}}

- name: {{ schema_name -}}.get_chains
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the basic information of all chains. [Footprint docs here](https://docs.footprint.network/reference/get_chain-info).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/chain/info") | trim}}

{% endmacro %}