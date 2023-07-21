{% macro config_chainbase_utils_udfs(schema_name = "chainbase_utils", utils_schema_name="chainbase_utils") -%}
{#
    This macro is used to generate the alchemy base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Chainbase API. [Chainbase Docs](https://docs.chainbase.com/reference/supported-chains)$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat(
           'https://api.chainbase.online', PATH, '?',
            utils.udf_object_to_url_query_string(QUERY_ARGS)
        ),
        {'x-api-key': '{API_KEY}'},
        {},
        '_FSC_SYS/CHAINBASE'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Chainbase API. [Chainbase Docs](https://docs.chainbase.com/reference/supported-chains)$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        concat('https://api.chainbase.online', PATH),
        {'x-api-key': '{API_KEY}'},
        BODY,
        '_FSC_SYS/CHAINBASE'
    ) as response

- name: {{ schema_name -}}.rpc
  signature:
    - [METHOD, STRING, The RPC method to call]
    - [PARAMS, ARRAY, The RPC Params arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue an RPC call to Chainbase. [Chainbase Docs](https://docs.chainbase.com/reference/supported-chains)$$
  sql: |
    SELECT live.udf_api(
      'POST',
      concat('https://api.chainbase.online'),
      {'x-api-key': '{API_KEY}'},
      {'id': 1,'jsonrpc': '2.0','method': METHOD,'params': PARAMS},
      '_FSC_SYS/CHAINBASE') as response

{% endmacro %}