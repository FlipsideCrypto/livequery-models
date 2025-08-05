{% macro config_deepnftvalue_udfs(schema_name = "deepnftvalue", utils_schema_name="deepnftvalue_utils") -%}
{#
    This macro is used to generate the DeepNftValue Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the DeepNftValue API. [DeepNftValue docs here](https://deepnftvalue.readme.io/reference/getting-started-with-deepnftvalue-api).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.deepnftvalue.com', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'Authorization': 'Token {API_KEY}'},
        {},
        '_FSC_SYS/DEEPNFTVALUE'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the DeepNftValue API. [DeepNftValue docs here](https://deepnftvalue.readme.io/reference/getting-started-with-deepnftvalue-api).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://api.deepnftvalue.com', PATH),
        {'Authorization': 'Token {API_KEY}'},
        BODY,
        '_FSC_SYS/DEEPNFTVALUE'
    ) as response

{% endmacro %}