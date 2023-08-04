{% macro config_zettablock_udfs(schema_name = "zettablock", utils_schema_name="zettablock_utils") -%}
{#
    This macro is used to generate the Zettablock Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, ARRAY, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Zettablock API. [Zettablock docs here](https://docs.zettablock.com/reference/api-intro).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.zettablock.com', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'Authorization': 'Bearer {API_KEY}'},
        {},
        '_FSC_SYS/ZETTABLOCK'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Zettablock API. [Zettablock docs here](https://docs.zettablock.com/reference/api-intro).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://api.zettablock.com', PATH),
        {'Authorization': 'Bearer {API_KEY}'},
        BODY,
        '_FSC_SYS/ZETTABLOCK'
    ) as response

{% endmacro %}