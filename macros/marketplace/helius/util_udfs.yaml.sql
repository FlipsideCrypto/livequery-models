{% macro config_helius_utils_udfs(schema = "helius_utils", utils_schema_name="helius_utils") -%}
{#
    This macro is used to generate the Helius base endpoints
 #}

- name: {{ schema_name }}.get_api
  signature:
    - [NETWORK, STRING, The network 'devnet' or 'mainnet']
    - [PATH, STRING, The API path starting with '/']
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue an HTTP GET request to Helius.$$
  sql: |
    SELECT
    {% set v2_exists = is_udf_api_v2_compatible() %}
    {% if v2_exists -%}
      live.udf_api_v2(
        'GET',
        CASE
            WHEN NETWORK = 'devnet' THEN
                concat('https://api-devnet.helius.xyz', PATH, '?api-key={API_KEY}&', utils.udf_object_to_url_query_string(QUERY_PARAMS))
            ELSE
                concat('https://api.helius.xyz', PATH, '?api-key={API_KEY}&', utils.udf_object_to_url_query_string(QUERY_PARAMS))
        END,
        {'fsc-quantum-execution-mode': 'async'},
        {},
        '_FSC_SYS/HELIUS',
        TRUE
      )
    {%- else -%}
      live.udf_api(
        'GET',
        CASE
            WHEN NETWORK = 'devnet' THEN
                concat('https://api-devnet.helius.xyz', PATH, '?api-key={API_KEY}&', utils.udf_object_to_url_query_string(QUERY_PARAMS))
            ELSE
                concat('https://api.helius.xyz', PATH, '?api-key={API_KEY}&', utils.udf_object_to_url_query_string(QUERY_PARAMS))
        END,
        {},
        {},
        '_FSC_SYS/HELIUS'
      )
    {%- endif %}
    as response

- name: {{ schema_name }}.post_api
  signature:
    - [NETWORK, STRING, The network 'devnet' or 'mainnet']
    - [PATH, STRING, The API path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue an HTTP POST request to Helius.$$
  sql: |
    SELECT
    {% set v2_exists = is_udf_api_v2_compatible() %}
    {% if v2_exists -%}
      live.udf_api_v2(
        'POST',
        CASE
            WHEN NETWORK = 'devnet' THEN
                concat('https://api-devnet.helius.xyz', PATH, '?api-key={API_KEY}')
            ELSE
                concat('https://api.helius.xyz', PATH, '?api-key={API_KEY}')
        END,
        {'fsc-quantum-execution-mode': 'async'},
        BODY,
        '_FSC_SYS/HELIUS',
        TRUE
      )
    {%- else -%}
      live.udf_api(
        'POST',
        CASE
            WHEN NETWORK = 'devnet' THEN
                concat('https://api-devnet.helius.xyz', PATH, '?api-key={API_KEY}')
            ELSE
                concat('https://api.helius.xyz', PATH, '?api-key={API_KEY}')
        END,
        {},
        BODY,
        '_FSC_SYS/HELIUS'
      )
    {%- endif %}
    as response

- name: {{ schema_name }}.rpc
  signature:
    - [NETWORK, STRING, The network 'devnet' or 'mainnet']
    - [METHOD, STRING, The RPC method to call]
    - [PARAMS, OBJECT, The RPC Params arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue an RPC call to Helius.$$
  sql: |
    SELECT
    {% set v2_exists = is_udf_api_v2_compatible() %}
    {% if v2_exists -%}
      live.udf_api_v2(
        'POST',
        CASE
            WHEN NETWORK = 'devnet' THEN
                'https://devnet.helius-rpc.com?api-key={API_KEY}'
            ELSE
                'https://mainnet.helius-rpc.com?api-key={API_KEY}'
        END,
        {'fsc-quantum-execution-mode': 'async'},
        {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': PARAMS},
        '_FSC_SYS/HELIUS',
        TRUE
      )
    {%- else -%}
      live.udf_api(
        'POST',
        CASE
            WHEN NETWORK = 'devnet' THEN
                'https://devnet.helius-rpc.com?api-key={API_KEY}'
            ELSE
                'https://mainnet.helius-rpc.com?api-key={API_KEY}'
        END,
        {},
        {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': PARAMS},
        '_FSC_SYS/HELIUS'
      )
    {%- endif %}
    as response

{% endmacro %}
