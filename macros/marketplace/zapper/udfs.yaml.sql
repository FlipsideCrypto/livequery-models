{% macro config_zapper_udfs(schema_name = "zapper", utils_schema_name="zapper_utils") -%}
{#
    This macro is used to generate the Zapper Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Zapper API. [Zapper docs here](https://studio.zapper.xyz/docs/apis/getting-started).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.zapper.xyz', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'Authorization': 'Basic {API_KEY}'},
        {},
        '_FSC_SYS/ZAPPER'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Zapper API. [Zapper docs here](https://studio.zapper.xyz/docs/apis/getting-started).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://api.zapper.xyz', PATH),
        {'Authorization': 'Basic {API_KEY}'},
        BODY,
        '_FSC_SYS/ZAPPER'
    ) as response

{% endmacro %}