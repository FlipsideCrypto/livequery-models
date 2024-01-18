{% macro config_topshot_udfs(schema_name = "topshot", utils_schema_name = "topshot_utils") -%}
{#
    This macro is used to generate the Topshot calls
 #}

- name: {{ schema_name -}}.graphql
  signature:
    - [QUERY, OBJECT, The GraphQL query]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Run a graphql query on TopShot.$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        'https://public-api.nbatopshot.com/graphql',
        {'User-Agent': 'Flipside_LQ/0.1','Accept-Encoding': 'gzip', 'Content-Type': 'application/json', 'Accept': 'application/json','Connection': 'keep-alive'},
        QUERY,
        '_FSC_SYS/TOPSHOT'
    ) as response

{% endmacro %}