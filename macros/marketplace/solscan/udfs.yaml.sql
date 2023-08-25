{% macro config_solscan_udfs(schema_name = "solscan", utils_schema_name="solscan_utils") -%}
{#
    This macro is used to generate the Solscan Base endpoints
 #}

- name: {{ schema_name -}}.pro_api_get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Private Solscan API. [Solscan docs here](https://pro-api.solscan.io/pro-api-docs/v1.0).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://pro-api.solscan.io', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'token': '{API_KEY}'},
        {},
        '_FSC_SYS/SOLSCAN'
    ) as response

- name: {{ schema_name -}}.pro_api_post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Private Solscan API. [Solscan docs here](https://pro-api.solscan.io/pro-api-docs/v1.0).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://pro-api.solscan.io', PATH),
        {'token': '{API_KEY}'},
        BODY,
        '_FSC_SYS/SOLSCAN'
    ) as response

- name: {{ schema_name -}}.public_api_get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Public Solscan API. [Solscan docs here](https://public-api.solscan.io/docs/#/).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://public-api.solscan.io', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'token': '{API_KEY}'},
        {},
        '_FSC_SYS/SOLSCAN'
    ) as response

- name: {{ schema_name -}}.public_api_post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Public Solscan API. [Solscan docs here](https://public-api.solscan.io/docs/#/).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://public-api.solscan.io', PATH),
        {'token': '{API_KEY}'},
        BODY,
        '_FSC_SYS/SOLSCAN'
    ) as response


{% endmacro %}