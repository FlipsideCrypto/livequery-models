{% macro udf_configs() %}

{#
  UTILITY SCHEMA
#}
- name: _utils.udf_introspect
  signature:
    - [echo, STRING]
  func_type: SECURE EXTERNAL
  return_type: TEXT
  api_integration: AWS_LIVE_QUERY_DEV
  sql: introspect


- name: _utils.udf_whoami
  signature: []
  func_type: SECURE
  return_type: TEXT
  options: NOT NULL STRICT IMMUTABLE MEMOIZABLE
  sql: |
    SELECT
      COALESCE(SPLIT_PART(GETVARIABLE('QUERY_TAG_SESSION'), ',',2), CURRENT_USER())

- name: _utils.udf_register_secret
  signature:
    - [request_id, STRING]
    - [user_id, STRING]
    - [key, STRING]
  return_type: TEXT
  func_type: SECURE EXTERNAL
  api_integration: AWS_LIVE_QUERY_DEV
  options: NOT NULL STRICT
  sql: secret/register
- name: utils.udf_register_secret
  signature:
    - [request_id, STRING]
    - [key, STRING]
  func_type: SECURE
  return_type: TEXT
  options: NOT NULL STRICT IMMUTABLE
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
    STRICT IMMUTABLE
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
    STRICT IMMUTABLE
    RUNTIME_VERSION = '3.8'
    HANDLER = 'hex_to_int'
  sql: |
    {{ python_udf_hex_to_int_with_encoding() | indent(4) }}

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
  func_type: SECURE EXTERNAL
  api_integration: AWS_LIVE_QUERY_DEV
  options: NOT NULL STRICT
  sql: udf_api
- name: live.udf_api
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [data, OBJECT]
    - [secret_name, STRING]
  return_type: VARIANT
  func_type: SECURE
  options: NOT NULL STRICT VOLATILE
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


{% endmacro %}

