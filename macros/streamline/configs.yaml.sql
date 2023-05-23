{% macro udf_configs(schema) %}

{#
  UTILITY SCHEMA
#}

- name: {{ schema }}.udf_hex_to_int
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
    {{ fsc_utils.python_hex_to_int() | indent(4) }}
- name: {{ schema }}.udf_hex_to_int
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
    {{ fsc_utils.python_udf_hex_to_int_with_encoding() | indent(4) }}

- name: {{ schema }}.udf_hex_to_string
  signature:
    - [hex, STRING]
  return_type: TEXT
  options: |
    NULL
    LANGUAGE SQL 
    STRICT IMMUTABLE
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
    {{ fsc_utils.sql_udf_json_rpc_call() }}
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
    {{ fsc_utils.sql_udf_json_rpc_call() }}
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
    {{ fsc_utils.sql_udf_json_rpc_call(False) }}
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
    {{ fsc_utils.sql_udf_json_rpc_call(False) }}

- name: {{ schema }}.udf_simple_event_name
  signature:
    - [abi, VARIANT]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.8'
    HANDLER = 'get_simplified_signature'
  sql: |
    {{ fsc_utils.create_udf_simple_event_names() | indent(4) }}

- name: {{ schema }}.udf_keccak
  signature:
    - [event_name, VARCHAR(255)]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.8'
    PACKAGES = ('pycryptodome==3.15.0')
    HANDLER = 'udf_encode'
  sql: |
    {{ fsc_utils.create_udf_keccak() | indent(4) }}  

{% endmacro %}

