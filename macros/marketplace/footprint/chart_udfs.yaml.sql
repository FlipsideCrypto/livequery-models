{% macro config_footprint_chart_udfs(schema_name = "footprint_charts", utils_schema_name = "footprint_utils") -%}
{#
    This macro is used to generate the Footprint Chart endpoints
 #}

- name: {{ schema_name -}}.get_chart_results
  signature:
    - [CHART_ID, VARCHAR, The chart ID]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns your Footprint chart data by a chart ID. [Footprint docs here](https://docs.footprint.network/reference/post_dataapi-card-chart-id-query).$$
  sql: |
    SELECT 
      livequery.live.udf_api(
        'POST',
        concat(
           'https://footprint.network/api/v1/dataApi/card/', CHART_ID, '/query'
        ),
        {'api-key': '{API_KEY}'},
        {},
        '_FSC_SYS/FOOTPRINT'
    ) as response

{% endmacro %}