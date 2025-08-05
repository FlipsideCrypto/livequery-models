{% macro config_apilayer_udfs(schema_name = "apilayer", utils_schema_name="apilayer_utils") -%}
{#
    This macro is used to generate the ApiLayer Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the ApiLayer API. [ApiLayer docs here](https://apilayer.com/docs/article/getting-started).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.apilayer.com', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'apikey': '{API_KEY}'},
        NULL,
        '_FSC_SYS/APILAYER'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the ApiLayer API. [ApiLayer docs here](https://apilayer.com/docs/article/getting-started).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://api.apilayer.com', PATH),
        {'apikey': '{API_KEY}'},
        BODY,
        '_FSC_SYS/APILAYER'
    ) as response

{% endmacro %}
