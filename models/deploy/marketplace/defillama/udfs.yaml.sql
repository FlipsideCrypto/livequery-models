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
        {'Accept': '*/*', 'User-Agent': 'livequery/1.0 (Snowflake)', 'Host':'api.llama.fi', 'Connection': 'keep-alive'},
        NULL,
        IFF(ARRAY_CONTAINS('api_key'::VARIANT, OBJECT_KEYS(QUERY_ARGS)), '_FSC_SYS/DEFILLAMA', '')
    ) as response

{% endmacro %}
