{% macro config_subquery_udfs(schema_name = "subquery", utils_schema_name = "subquery_utils") -%}
{#
    This macro is used to generate the Subquery Calls
 #}
- name: {{ schema_name -}}.graphql
  signature:
    - [PROJECT, STRING, The sub-query project name]
    - [QUERY, OBJECT, The graphql query]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Query a SubQuery Project [SubQuery docs here](https://explorer.subquery.network/subquery/subquery/kepler-network).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        concat('https://api.subquery.network/sq/subquery/', PROJECT),
        {},
        QUERY
    ) as response

{% endmacro %}
