{% macro config_coingecko_udfs(schema_name = "coingecko", utils_schema_name="coingecko_utils") -%}
{#
    This macro is used to generate the Coingecko Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, ARRAY, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the CoinGecko API. [CoinGecko docs here](https://apiguide.coingecko.com/getting-started/introduction).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://pro-api.coingecko.com', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'x-cg-pro-api-key': '{API_KEY}'},
        {},
        '_FSC_SYS/COINGECKO'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path after '/api' starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the CoinGecko API. [CoinGecko docs here](https://apiguide.coingecko.com/getting-started/introduction).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://pro-api.coingecko.com', PATH),
        {'x-cg-pro-api-key': '{API_KEY}'},
        BODY,
        '_FSC_SYS/COINGECKO'
    ) as response

{% endmacro %}