{% macro config_allday_udfs(schema_name = "allday", utils_schema_name = "allday_utils") -%}
{#
    This macro is used to generate the AllDay calls
 #}

- name: {{ schema_name -}}.graphql
  signature:
    - [QUERY, OBJECT, The GraphQL query]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Run a graphql query on AllDay.$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        CONCAT('https://nflallday.com/consumer/graphql?query=', utils.udf_object_to_url_query_string(QUERY)),
        {'User-Agent': 'Flipside_Flow_metadata/0.1','Accept-Encoding': 'gzip', 'Content-Type': 'application/json', 'Accept': 'application/json','Connection': 'keep-alive'},
        {},
        '_FSC_SYS/ALLDAY'
    ) as response

{% endmacro %}