{% macro config_core_utils(schema="utils") %}

- name: {{ schema }}.udf_hex_to_int
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
    RUNTIME_VERSION = '3.8'
    HANDLER = 'hex_to_int'
  sql: |
    {{ python_udf_hex_to_int_with_encoding() | indent(4) }}
- name: {{ schema }}.udf_evm_text_signature
  signature:
    - [abi, VARIANT]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.8'
    HANDLER = 'get_simplified_signature'
  sql: |
    {{ create_udf_evm_text_signature() | indent(4) }}
- name: {{ schema }}.udf_keccak256
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

- name: {{ schema }}.udf_object_to_url_query_string
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
- name: {{ schema }}.udf_evm_transform_log
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

{% endmacro %}