{% macro config_cmc_udfs(schema_name = "cmc", utils_schema_name="cmc_utils") -%}
{#
    This macro is used to generate the CoinmarketCap Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, ARRAY, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the CoinmarketCap API. [CoinmarketCap docs here](https://coinmarketcap.com/api/documentation/v1/).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://pro-api.coinmarketcap.com', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'X-CMC_PRO_API_KEY': '{API_KEY}'},
        {},
        '_FSC_SYS/CMC'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the CoinmarketCap API. [CoinmarketCap docs here](https://coinmarketcap.com/api/documentation/v1/).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://pro-api.coinmarketcap.com', PATH),
        {'X-CMC_PRO_API_KEY': '{API_KEY}'},
        BODY,
        '_FSC_SYS/CMC'
    ) as response

{% endmacro %}