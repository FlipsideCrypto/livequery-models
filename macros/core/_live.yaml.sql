{% macro config_core__live(schema="_live") %}

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
  api_integration_options : '{{ var("API_INTEGRATION_OPTIONS") }}'
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
  sql: udf_api
{% endmacro %}