{% macro config_binance_udfs(schema_name = "binance", utils_schema_name="binance_utils") -%}
{#
    This macro is used to generate the Binance Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [URL, STRING, The full url including the path]
    - [QUERY_ARGS, ARRAY, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Binance API. [Binance docs here](https://binance-docs.github.io/apidocs/spot/en/#api-key-setup).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat(URL, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'X-MBX-APIKEY': '{API_KEY}'},
        {},
        '_FSC_SYS/BINANCE'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [URL, STRING, The full url]
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Binance API. [Binance docs here](https://binance-docs.github.io/apidocs/spot/en/#api-key-setup).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        URL,
        {'X-MBX-APIKEY': '{API_KEY}'},
        BODY,
        '_FSC_SYS/BINANCE'
    ) as response

{% endmacro %}