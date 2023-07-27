{% macro config_bitquery_udfs(schema_name = "bitquery", utils_schema_name = "bitquery_utils") -%}
{#
    This macro is used to generate the BitQuery calls
 #}

- name: {{ schema_name -}}.graphql
  signature:
    - [QUERY, OBJECT, The GraphQL query]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Run a graphql query on BitQuery [BitQuery docs here](https://docs.bitquery.io/docs/start/first-query/).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        'https://graphql.bitquery.io',
        {'X-API-KEY': '{API_KEY}'},
        QUERY,
        '_FSC_SYS/BITQUERY'
    ) as response

{% endmacro %}