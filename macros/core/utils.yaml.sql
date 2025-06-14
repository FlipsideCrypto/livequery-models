{% macro config_core_utils(schema="utils") %}


- name: {{ schema }}.udf_register_secret
  signature:
    - [request_id, STRING]
    - [key, STRING]
  func_type: SECURE
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    SELECT
      _utils.UDF_REGISTER_SECRET(REQUEST_ID, _utils.UDF_WHOAMI(), KEY)

- name: {{ schema }}.udf_hex_to_int
  signature:
    - [hex, STRING]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE PYTHON
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    RUNTIME_VERSION = '3.10'
    HANDLER = 'hex_to_int'
  sql: |
    {{ python_hex_to_int() | indent(4) }}
- name: {{ schema }}.udf_hex_to_int
  signature:
    - [encoding, STRING]
    - [hex, STRING]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE PYTHON
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    RUNTIME_VERSION = '3.10'
    HANDLER = 'hex_to_int'
  sql: |
    {{ python_udf_hex_to_int_with_encoding() | indent(4) }}
- name: {{ schema }}.udf_evm_text_signature
  signature:
    - [abi, VARIANT]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.10'
    HANDLER = 'get_simplified_signature'
  sql: |
    {{ create_udf_evm_text_signature() | indent(4) }}
- name: {{ schema }}.udf_keccak256
  signature:
    - [event_name, VARCHAR(255)]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.10'
    PACKAGES = ('pycryptodome==3.15.0')
    HANDLER = 'udf_encode'
  sql: |
    {{ create_udf_keccak256() | indent(4) }}
- name: {{ schema }}.udf_hex_to_string
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
- name: {{ schema }}.udf_int_to_hex
  signature:
    - [int, INTEGER]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE SQL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    select CONCAT('0x', TRIM(TO_CHAR(int, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')))

- name: {{ schema }}.udf_json_rpc_call
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
- name: {{ schema }}.udf_json_rpc_call
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
- name: {{ schema }}.udf_json_rpc_call
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
- name: {{ schema }}.udf_json_rpc_call
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

- name: {{ schema }}.udf_urlencode
  signature:
    - [query, OBJECT]
    - [doseq, BOOLEAN]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE PYTHON
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    RUNTIME_VERSION = '3.10'
    COMMENT=$$Pthon (function)[https://docs.python.org/3/library/urllib.parse.html#urllib.parse.urlencode] to convert an object to a URL query string.$$
    HANDLER = 'object_to_url_query_string'
  sql: |
    {{ python_object_to_url_query_string() | indent(4) }}
- name: {{ schema }}.udf_urlencode
  signature:
    - [query, ARRAY]
    - [doseq, BOOLEAN]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE PYTHON
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    RUNTIME_VERSION = '3.10'
    COMMENT=$$Pthon (function)[https://docs.python.org/3/library/urllib.parse.html#urllib.parse.urlencode] to convert an array to a URL query string.$$
    HANDLER = 'object_to_url_query_string'
  sql: |
    {{ python_object_to_url_query_string() | indent(4) }}
- name: {{ schema }}.udf_urlencode
  signature:
    - [query, ARRAY]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE SQL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    SELECT {{ schema }}.udf_urlencode(query, FALSE)
- name: {{ schema }}.udf_urlencode
  signature:
    - [query, OBJECT]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE SQL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    SELECT {{ schema }}.udf_urlencode(query, FALSE)
- name: {{ schema }}.udf_object_to_url_query_string
  signature:
    - [object, OBJECT]
  return_type: TEXT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: SELECT utils.udf_urlencode(object, FALSE)

- name: {{ schema }}.udf_evm_transform_log
  signature:
    - [decoded, VARIANT]
  return_type: VARIANT
  options: |
    NULL
    LANGUAGE PYTHON
    IMMUTABLE
    RUNTIME_VERSION = '3.10'
    HANDLER = 'transform'
  sql: |
    {{ python_udf_evm_transform_log() | indent(4) }}

- name: {{ schema }}.udf_evm_decode_log
  signature:
    - [abi, ARRAY]
    - [data, OBJECT]
  return_type: ARRAY
  func_type: EXTERNAL
  api_integration: '{{ var("API_INTEGRATION") }}'
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
  sql: evm/decode/log
- name: {{ schema }}.udf_evm_decode_log
  signature:
    - [abi, OBJECT]
    - [data, OBJECT]
  return_type: ARRAY
  func_type: EXTERNAL
  api_integration: '{{ var("API_INTEGRATION") }}'
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
  sql: evm/decode/log

- name: {{ schema }}.udf_evm_decode_trace
  signature:
    - [abi, OBJECT]
    - [data, OBJECT]
  return_type: ARRAY
  func_type: EXTERNAL
  api_integration: '{{ var("API_INTEGRATION") }}'
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
  sql: evm/decode/trace

- name: {{ schema }}.udf_base58_to_hex
  signature:
    - [base58, STRING]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.10'
    HANDLER = 'transform_base58_to_hex'
  sql: |
    {{ create_udf_base58_to_hex() | indent(4) }}

- name: {{ schema }}.udf_hex_to_base58
  signature:
    - [hex, STRING]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.10'
    HANDLER = 'transform_hex_to_base58'
  sql: |
    {{ create_udf_hex_to_base58() | indent(4) }}

- name: {{ schema }}.udf_hex_to_bech32
  signature:
    - [hex, STRING]
    - [hrp, STRING]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.10'
    HANDLER = 'transform_hex_to_bech32'
  sql: |
    {{ create_udf_hex_to_bech32() | indent(4) }}

- name: {{ schema }}.udf_int_to_binary
  signature:
    - [num, STRING]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.10'
    HANDLER = 'int_to_binary'
  sql: |
    {{ create_udf_int_to_binary() | indent(4) }}

- name: {{ schema }}.udf_binary_to_int
  signature:
    - [binary, STRING]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.10'
    HANDLER = 'binary_to_int'
  sql: |
    {{ create_udf_binary_to_int() | indent(4) }}

{% endmacro %}
