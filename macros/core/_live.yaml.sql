{% macro config_core__live(schema="_live") %}
{%- if var("API_INTEGRATION_OPTIONS") -%}
    {%- set api_integration_options = fromjson(var("API_INTEGRATION_OPTIONS")) -%}
{%- else -%}
    {%- set api_integration_options = none -%}
{%- endif -%}
{%- set udf_api_opts = schema ~ ".udf_api" -%}

- name: {{ schema }}.udf_api
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [DATA, VARIANT]
    - [user_id, STRING]
    - [SECRET, STRING]
  return_type: VARIANT
  func_type: EXTERNAL
  api_integration: '{{ var("API_INTEGRATION") }}'
  api_integration_options : '{{ api_integration_options[udf_api_opts] }}'
  options: |
    NOT NULL
  sql: udf_api
{% endmacro %}


