{% macro config_footprint_utils_udfs(schema_name = "footprint_utils", utils_schema_name="footprint_utils") -%}
{#
    This macro is used to generate the Footprint base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, ARRAY, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Footprint API.$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat(
           'https://api.footprint.network/api', PATH, '?',
            utils.udf_urlencode(QUERY_ARGS, TRUE)
        ),
        {'api-key': '{API_KEY}'},
        {},
        '_FSC_SYS/FOOTPRINT'
    ) as response
- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Footprint API.$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat(
           'https://api.footprint.network/api', PATH, '?',
            utils.udf_urlencode(QUERY_ARGS, TRUE)
        ),
        {'api-key': '{API_KEY}'},
        {},
        '_FSC_SYS/FOOTPRINT'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Footprint API.$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        concat('https://api.footprint.network/api', PATH),
        {'api-key': '{API_KEY}'},
        BODY,
        '_FSC_SYS/FOOTPRINT'
    ) as response


- name: {{ schema_name -}}.rpc
  signature:
    - [METHOD, STRING, The RPC method to call]
    - [PARAMS, ARRAY, The RPC Params arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue an RPC call to Footprint.$$
  sql: |
    SELECT live.udf_api(
      'POST',
      concat('https://api.footprint.network/api'),
      {'api-key': '{API_KEY}'},
      {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': PARAMS},
      '_FSC_SYS/FOOTPRINT') as response

{% endmacro %}