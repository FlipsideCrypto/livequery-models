{% macro config_stakingrewards_udfs(schema_name = "stakingrewards", utils_schema_name="stakingrewards_utils") -%}
{#
    This macro is used to generate the StakingRewards Base endpoints
 #}

- name: {{ schema_name -}}.query
  signature:
    - [QUERY, OBJECT, The GraphQL query]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a Graphql Query to the StakingRewards API. [StakingRewards docs here](https://api-docs.stakingrewards.com/api-docs/get-started/quick-start-guide).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        'https:/api.stakingrewards.com/public/query',
        {'X-API-KEY': '{API_KEY}'},
        QUERY,
        '_FSC_SYS/STAKINGREWARDS'
    ) as response

{% endmacro %}