{% macro config_dappradar_udfs(schema_name = "dappradar", utils_schema_name="dappradar_utils") -%}
{#
    This macro is used to generate the DappRadar Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, ARRAY, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the DappRadar API. [DappRadar docs here](https://api-docs.dappradar.com/#section/Introduction).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.dappradar.com', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'X-BLOBR-KEY': '{API_KEY}'},
        {},
        '_FSC_SYS/DAPPRADAR'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the DappRadar API. [DappRadar docs here](https://api-docs.dappradar.com/#section/Introduction).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://api.dappradar.com', PATH),
        {'X-BLOBR-KEY': '{API_KEY}'},
        BODY,
        '_FSC_SYS/DAPPRADAR'
    ) as response

{% endmacro %}