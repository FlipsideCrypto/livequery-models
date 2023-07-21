{% macro config_dapplooker_udfs(schema_name = "dapplooker", utils_schema_name = "dapplooker_utils") -%}
{#
    This macro is used to generate the DappLooker endpoints
 #}

- name: {{ schema_name -}}.get_chart
  signature:
    - [CHART_ID, STRING, The UUID of the chart]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the chart data. [DappLooker docs here](https://github.com/dapplooker/dapplooker-sdk).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.dapplooker.com/charts/', CHART_ID, '?api_key={API_KEY}&format=json'),
        {},
        {},
        '_FSC_SYS/DAPPLOOKER'
    ) as response

{% endmacro %}