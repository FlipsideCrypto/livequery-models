{% macro config_core__live(schema="_live") %}

- name: {{ schema }}.udf_api_batched
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
  max_batch_rows: '{{ var("MAX_BATCH_ROWS") }}'
  options: |
    NOT NULL
  sql: udf_api

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
  options: |
    NOT NULL
  sql: udf_api

{% endmacro %}