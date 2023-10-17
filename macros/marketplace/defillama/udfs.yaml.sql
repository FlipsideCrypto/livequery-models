{% macro config_defillama_udfs(schema_name = "defillama", utils_schema_name="defillama_utils") -%}
{#
    This macro is used to generate the Defillama endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Defillama API. [Defillama docs here](https://defillama.com/docs/api).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.llama.fi', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'Accept': '*/*', 'User-Agent': 'curl/8.1.2', 'Host':'api.llama.fi'},
        {}
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Defillama API. [Defillama docs here](https://defillama.com/docs/api).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://api.llama.fi', PATH),
        {'Accept': '*/*', 'User-Agent': 'curl/8.1.2', 'Host':'api.llama.fi'},
        BODY
    ) as response

{% endmacro %}