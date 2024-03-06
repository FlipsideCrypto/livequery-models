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
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
  sql: udf_api
- name: {{ schema }}.udf_streamline
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
    RETURNS NULL ON NULL INPUT
  sql: udf_bulk_rest_api
- name: {{ schema }}.udf_function_selector
  description: |
    This function is used to select the appropriate function to call based on the user_id
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [DATA, VARIANT]
    - [user_id, STRING]
    - [SECRET, STRING]
  return_type: VARIANT
  func_type: SECURE
  api_integration: '{{ var("API_INTEGRATION") }}'
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
  sql: |
    SELECT
      CASE
        WHEN user_id ilike 'AWS_%'
        THEN {{ schema }}.udf_streamline(method, url, headers, DATA, user_id, SECRET)
        ELSE {{ schema }}.udf_api(method, url, headers, DATA, user_id, SECRET)
      END


{% endmacro %}