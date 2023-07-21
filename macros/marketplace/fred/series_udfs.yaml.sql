{% macro config_fred_series_udfs(schema_name = "fred_series", utils_schema_name = "fred_utils") -%}
{#
    This macro is used to generate the Fred Series Calls
 #}
- name: {{ schema_name -}}.get
  signature:
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Get a FRED series [FRED docs here](https://fred.stlouisfed.org/docs/api/fred/series.html).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.stlouisfed.org/fred/series/observations?api_key={API_KEY}&', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {},
        {},
        '_FSC_SYS/FRED'
    ) as response

{% endmacro %}