{% macro config_transpose_udfs(schema_name = "transpose", utils_schema_name="transpose_utils") -%}
{#
    This macro is used to generate the Transpose Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Transpose API. [Transpose docs here](https://docs.transpose.io/rest/overview/).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.transpose.io', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'X-API-KEY': '{API_KEY}'},
        {},
        '_FSC_SYS/TRANSPOSE'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Transpose API. [Transpose docs here](https://docs.transpose.io/rest/overview/).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://api.transpose.io', PATH),
        {'X-API-KEY': '{API_KEY}'},
        BODY,
        '_FSC_SYS/TRANSPOSE'
    ) as response

{% endmacro %}