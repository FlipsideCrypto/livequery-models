{% macro config_alchemy_utils_udfs(schema_name = "alchemy_utils", utils_schema_name="alchemy_utils") -%}
{#
    This macro is used to generate the alchemy base endpoints
 #}

- name: {{ schema_name }}.nfts_get
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Alchemy NFT API.$$
  sql: |
    SELECT
    {% set v2_exists = is_udf_api_v2_compatible() %}
    {% if v2_exists -%}
      live.udf_api_v2(
        'GET',
        concat(
            'https://', NETWORK,'.g.alchemy.com/nft/v2/{',NETWORK,'}', PATH, '?',
            utils.udf_object_to_url_query_string(QUERY_ARGS)
        ),
        {'fsc-quantum-execution-mode': 'async'},
        {},
        '_FSC_SYS/ALCHEMY',
        TRUE
      )
    {%- else -%}
      live.udf_api(
        'GET',
        concat(
            'https://', NETWORK,'.g.alchemy.com/nft/v2/{',NETWORK,'}', PATH, '?',
            utils.udf_object_to_url_query_string(QUERY_ARGS)
        ),
        {},
        {},
        '_FSC_SYS/ALCHEMY'
      )
    {%- endif %}
    as response

- name: {{ schema_name }}.nfts_get
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [VERSION, STRING, The version of the API to use]
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Alchemy NFT API.$$
  sql: |
    SELECT
    {% set v2_exists = is_udf_api_v2_compatible() %}
    {% if v2_exists -%}
      live.udf_api_v2(
        'GET',
        concat(
            'https://', NETWORK,'.g.alchemy.com/nft/', VERSION, '/{',NETWORK,'}', PATH, '?',
            utils.udf_object_to_url_query_string(QUERY_ARGS)
        ),
        {'fsc-quantum-execution-mode': 'async'},
        {},
        '_FSC_SYS/ALCHEMY',
        TRUE
      )
    {%- else -%}
      live.udf_api(
        'GET',
        concat(
            'https://', NETWORK,'.g.alchemy.com/nft/', VERSION, '/{',NETWORK,'}', PATH, '?',
            utils.udf_object_to_url_query_string(QUERY_ARGS)
        ),
        {},
        {},
        '_FSC_SYS/ALCHEMY'
      )
    {%- endif %}
    as response

- name: {{ schema_name }}.nfts_post
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Alchemy NFT API.$$
  sql: |
    SELECT
    {% set v2_exists = is_udf_api_v2_compatible() %}
    {% if v2_exists -%}
      live.udf_api_v2(
        'POST',
        concat('https://', NETWORK,'.g.alchemy.com/nft/v2/{',NETWORK,'}', PATH),
        {'fsc-quantum-execution-mode': 'async'},
        BODY,
        '_FSC_SYS/ALCHEMY',
        TRUE
      )
    {%- else -%}
      live.udf_api(
        'POST',
        concat('https://', NETWORK,'.g.alchemy.com/nft/v2/{',NETWORK,'}', PATH),
        {},
        BODY,
        '_FSC_SYS/ALCHEMY'
      )
    {%- endif %}
    as response

- name: {{ schema_name }}.rpc
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [METHOD, STRING, The RPC method to call]
    - [PARAMS, ARRAY, The RPC Params arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue an RPC call to Alchemy.$$
  sql: |
    SELECT
    {% set v2_exists = is_udf_api_v2_compatible() %}
    {% if v2_exists -%}
      live.udf_api_v2(
        'POST',
        concat('https://', NETWORK,'.g.alchemy.com/v2/{',NETWORK,'}'),
        {'fsc-quantum-execution-mode': 'async'},
        {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': PARAMS},
        '_FSC_SYS/ALCHEMY',
        TRUE
      )
    {%- else -%}
      live.udf_api(
        'POST',
        concat('https://', NETWORK,'.g.alchemy.com/v2/{',NETWORK,'}'),
        {},
        {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': PARAMS},
        '_FSC_SYS/ALCHEMY'
      )
    {%- endif %}
    as response
{% endmacro %}
