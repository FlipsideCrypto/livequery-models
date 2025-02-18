{% macro config_alchemy_utils_udfs(schema_name = "alchemy_utils", utils_schema_name="alchemy_utils") -%}
{#
    This macro is used to generate the alchemy base endpoints
 #}

- name: {{ schema -}}.nfts_get
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
      live.udf_api(
        concat(
            'https://', NETWORK,'.g.alchemy.com/nft/v2/{',NETWORK,'}', PATH, '?',
            utils.udf_object_to_url_query_string(QUERY_ARGS)
        ),
        '_FSC_SYS/ALCHEMY'
    ) as response

- name: {{ schema -}}.nfts_get
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
      live.udf_api(
        concat(
            'https://', NETWORK,'.g.alchemy.com/nft/', VERSION, '/{',NETWORK,'}', PATH, '?',
            utils.udf_object_to_url_query_string(QUERY_ARGS)
        ),
        '_FSC_SYS/ALCHEMY'
    ) as response

- name: {{ schema -}}.nfts_post
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
      live.udf_api(
        'POST',
        concat('https://', NETWORK,'.g.alchemy.com/nft/v2/{',NETWORK,'}', PATH),
        {},
        BODY,
        '_FSC_SYS/ALCHEMY'
    ) as response

- name: {{ schema -}}.rpc
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [METHOD, STRING, The RPC method to call]
    - [PARAMS, ARRAY, The RPC Params arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue an RPC call to Alchemy.$$
  sql: |
    SELECT live.udf_api(
      'POST',
      concat('https://', NETWORK,'.g.alchemy.com/v2/{',NETWORK,'}'),
      {},
      {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': PARAMS},
      '_FSC_SYS/ALCHEMY') as response
{% endmacro %}
