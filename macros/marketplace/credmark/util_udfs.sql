{% macro config_credmark_utils_udfs(schema_name = "credmark_utils", utils_schema_name="credmark_utils") -%}
{#
    This macro is used to generate the Credmark base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Credmark API.$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat(
           'https://gateway.credmark.com', PATH, '?',
            utils.udf_object_to_url_query_string(QUERY_ARGS)
        ),
        {'Authorization': 'Bearer {API_KEY}'},
        {},
        '_FSC_SYS/CREDMARK'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Credmark API.$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        concat('https://gateway.credmark.com', PATH),
        {'Authorization': 'Bearer {API_KEY}'},
        BODY,
        '_FSC_SYS/CREDMARK'
    ) as response

{% endmacro %}