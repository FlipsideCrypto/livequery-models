{% macro config_core_udfs() %}

{#
  UTILITY SCHEMA
#}
- name: _utils.udf_introspect
  signature:
    - [echo, STRING]
  func_type: SECURE EXTERNAL
  return_type: TEXT
  api_integration: '{{ var("API_INTEGRATION") }}'
  sql: introspect


- name: _utils.udf_user_tier
  signature: []
  func_type: SECURE
  return_type: TEXT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    MEMOIZABLE
  sql: |
    SELECT
      COALESCE(PARSE_JSON(GETVARIABLE('LIVEQUERY_CONTEXT')):userTier::STRING, 'community')

- name: _utils.udf_provider
  signature: []
  func_type: SECURE
  return_type: TEXT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    MEMOIZABLE
  sql: |
    SELECT
      COALESCE(PARSE_JSON(GETVARIABLE('LIVEQUERY_CONTEXT')):provider::STRING, 'quicknode')

- name: _utils.udf_whoami
  signature: []
  func_type: SECURE
  return_type: TEXT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    MEMOIZABLE
  sql: |
    SELECT
      COALESCE(PARSE_JSON(GETVARIABLE('LIVEQUERY_CONTEXT')):userId::STRING, CURRENT_USER())

- name: _utils.udf_register_secret
  signature:
    - [request_id, STRING]
    - [user_id, STRING]
    - [key, STRING]
  return_type: TEXT
  func_type: SECURE EXTERNAL
  api_integration: '{{ var("API_INTEGRATION") }}'
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
  sql: secret/register
- name: utils.udf_register_secret
  signature:
    - [request_id, STRING]
    - [key, STRING]
  func_type: SECURE
  return_type: TEXT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    SELECT
      _utils.UDF_REGISTER_SECRET(REQUEST_ID, _utils.UDF_WHOAMI(), KEY)

- name: utils.udf_hex_to_int
  signature:
    - [hex, STRING]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE PYTHON
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    RUNTIME_VERSION = '3.8'
    HANDLER = 'hex_to_int'
  sql: |
    {{ python_hex_to_int() | indent(4) }}
- name: utils.udf_hex_to_int
  signature:
    - [encoding, STRING]
    - [hex, STRING]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE PYTHON
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    RUNTIME_VERSION = '3.8'
    HANDLER = 'hex_to_int'
  sql: |
    {{ python_udf_hex_to_int_with_encoding() | indent(4) }}
- name: utils.udf_evm_text_signature
  signature:
    - [abi, VARIANT]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.8'
    HANDLER = 'get_simplified_signature'
  sql: |
    {{ create_udf_evm_text_signature() | indent(4) }}
- name: utils.udf_keccak256
  signature:
    - [event_name, VARCHAR(255)]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.8'
    PACKAGES = ('pycryptodome==3.15.0')
    HANDLER = 'udf_encode'
  sql: |
    {{ create_udf_keccak256() | indent(4) }}
- name: utils.udf_hex_to_string
  signature:
    - [hex, STRING]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE SQL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    SELECT
      LTRIM(regexp_replace(
        try_hex_decode_string(hex),
          '[\x00-\x1F\x7F-\x9F\xAD]', '', 1))

- name: utils.udf_json_rpc_call
  signature:
    - [method, STRING]
    - [params, ARRAY]
  return_type: OBJECT
  options: |
    NULL
    LANGUAGE SQL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    {{ sql_udf_json_rpc_call() }}
- name: utils.udf_json_rpc_call
  signature:
    - [method, STRING]
    - [params, OBJECT]
  return_type: OBJECT
  options: |
    NULL
    LANGUAGE SQL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    {{ sql_udf_json_rpc_call() }}
- name: utils.udf_json_rpc_call
  signature:
    - [method, STRING]
    - [params, OBJECT]
    - [id, STRING]
  return_type: OBJECT
  options: |
    NULL
    LANGUAGE SQL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    {{ sql_udf_json_rpc_call(False) }}
- name: utils.udf_json_rpc_call
  signature:
    - [method, STRING]
    - [params, ARRAY]
    - [id, STRING]
  return_type: OBJECT
  options: |
    NULL
    LANGUAGE SQL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    {{ sql_udf_json_rpc_call(False) }}

- name: utils.udf_object_to_url_query_string
  signature:
    - [object, OBJECT]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE PYTHON
    IMMUTABLE
    RUNTIME_VERSION = '3.8'
    HANDLER = 'object_to_url_query_string'
  sql: |
    {{ python_object_to_url_query_string() | indent(4) }}
- name: utils.udf_evm_transform_log
  signature:
    - [decoded, VARIANT]
  return_type: VARIANT
  options: |
    NULL
    LANGUAGE PYTHON
    IMMUTABLE
    RUNTIME_VERSION = '3.8'
    HANDLER = 'transform'
  sql: |
    {{ python_udf_evm_transform_log() | indent(4) }}

{#
  LIVE SCHEMA
#}
- name: _live.udf_api
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [DATA, OBJECT]
    - [user_id, STRING]
    - [SECRET, STRING]
  return_type: VARIANT
  func_type: EXTERNAL
  api_integration: '{{ var("API_INTEGRATION") }}'
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
  sql: udf_api
- name: live.udf_api
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [data, OBJECT]
    - [secret_name, STRING]
  return_type: VARIANT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
  sql: |
    SELECT
      _live.UDF_API(
          method,
          url,
          headers,
          data,
          _utils.UDF_WHOAMI(),
          secret_name
      )
- name: live.udf_api
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [data, OBJECT]
  return_type: VARIANT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
  sql: |
    SELECT
      _live.UDF_API(
          method,
          url,
          headers,
          data,
          _utils.UDF_WHOAMI(),
          ''
      )
- name: live.udf_api
  signature:
    - [url, STRING]
    - [data, OBJECT]
  return_type: VARIANT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
  sql: |
    SELECT
      _live.UDF_API(
          'POST',
          url,
          {'Content-Type': 'application/json'},
          data,
          _utils.UDF_WHOAMI(),
          ''
      )
- name: live.udf_api
  signature:
    - [url, STRING]
    - [data, OBJECT]
    - [secret_name, STRING]
  return_type: VARIANT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
  sql: |
    SELECT
      _live.UDF_API(
          'POST',
          url,
          {'Content-Type': 'application/json'},
          data,
          _utils.UDF_WHOAMI(),
          secret_name
      )
- name: live.udf_api
  signature:
    - [url, STRING]
  return_type: VARIANT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
  sql: |
    SELECT
      _live.UDF_API(
          'GET',
          url,
          {},
          {},
          _utils.UDF_WHOAMI(),
          ''
      )
- name: live.udf_api
  signature:
    - [url, STRING]
    - [secret_name, STRING]
  return_type: VARIANT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
  sql: |
    SELECT
      _live.UDF_API(
          'GET',
          url,
          {},
          {},
          _utils.UDF_WHOAMI(),
          secret_name
      )

- name: live.udf_rpc
  signature:
    - [blockchain, STRING]
    - [network, STRING]
    - [method, STRING]
    - [parameters, VARIANT]
  return_type: VARIANT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Executes an JSON RPC call on a blockchain.$$
  sql: |
    {{ sql_live_rpc_call("method", "parameters", "blockchain", "network") | indent(4) -}}

{% endmacro %}