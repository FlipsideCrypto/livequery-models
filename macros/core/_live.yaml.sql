{% macro config_core__live(schema="_live") %}
{%- set api_integration_options = fromjson(var("API_INTEGRATION_OPTIONS")) -%}
{%- set udf_api = schema ~ ".udf_api" -%}

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
  api_integration_options : '{{ api_integration_options[udf_api] if udf_api in api_integration_options else none }}'
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
  sql: udf_api
{% endmacro %}