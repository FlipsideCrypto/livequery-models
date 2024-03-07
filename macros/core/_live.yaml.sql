{% macro config_core__live(schema="_live") %}

- name: {{ schema }}._udf_api
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

- name: {{ schema }}.udf_rest_api_args_only
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [DATA, VARIANT]
    - [SECRET_NAME, STRING]
  return_type: OBJECT
  func_type: SECURE
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
  sql: |
    {
      'method': method,
      'url': url,
      'headers': headers,
      'data': data,
      'secret_name': SECRET_NAME
    }

- name: {{ schema }}.udf_api
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
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
  sql: |
    SELECT
      CASE
        WHEN user_id ilike 'AWS_%'
        THEN {{ schema }}.udf_rest_api_args_only(method, url, headers, DATA, SECRET)
        ELSE {{ schema }}.udf_api(method, url, headers, DATA, user_id, SECRET)
      END


{% endmacro %}