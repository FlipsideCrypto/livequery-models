{% macro config_opensea_udfs(schema_name = "opensea", utils_schema_name="opensea_utils") -%}
{#
    This macro is used to generate the OpenSea Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the OpenSea API. [OpenSea docs here](https://docs.opensea.io/reference/api-overview).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.opensea.io', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'X-API-KEY': '{API_KEY}'},
        {},
        '_FSC_SYS/OPENSEA'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the OpenSea API. [OpenSea docs here](https://docs.opensea.io/reference/api-overview).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        concat('https://api.opensea.io', PATH),
        {'X-API-KEY': '{API_KEY}'},
        BODY,
        '_FSC_SYS/OPENSEA'
    ) as response

{% endmacro %}