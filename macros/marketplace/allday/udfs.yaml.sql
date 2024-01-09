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
        CONCAT('https://nflallday.com/consumer/graphql?query=', QUERY),
        '_FSC_SYS/ALLDAY'
    ) as response

{% endmacro %}