{% macro config_nftscan_udfs(schema_name = "nftscan", utils_schema_name="nftscan_utils") -%}
{#
    This macro is used to generate the NFTScan Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [URL, STRING, The full url including the path]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the NFTScan API. [NFTScan docs here](https://docs.nftscan.com/guides/Overview/1).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat(URL, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'X-API-KEY': '{API_KEY}'},
        {},
        '_FSC_SYS/NFTSCAN'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [URL, STRING, The full url]
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the NFTScan API. [NFTScan docs here](https://docs.nftscan.com/guides/Overview/1).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        URL,
        {'X-API-KEY': '{API_KEY}'},
        BODY,
        '_FSC_SYS/NFTSCAN'
    ) as response

{% endmacro %}