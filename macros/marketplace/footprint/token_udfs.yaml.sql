{% macro config_footprint_tokens_udfs(schema_name = "footprint_tokens", utils_schema_name = "footprint_utils") -%}
{#
    This macro is used to generate the Footprint token endpoints
 #}

- name: {{ schema_name -}}.get_token_transfers
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the transfers record of the token. [Footprint docs here](https://docs.footprint.network/reference/get_token-transfers).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/token/transfers") | trim}}

{% endmacro %}