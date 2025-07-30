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
    RUNTIME_VERSION = '3.9'
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
    RUNTIME_VERSION = '3.9'
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
  exclude_from_datashare: true
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
  exclude_from_datashare: true
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
  exclude_from_datashare: true
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
  exclude_from_datashare: true

- name: {{ schema }}.udf_evm_text_signature
  signature:
    - [abi, VARIANT]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.9'
    HANDLER = 'get_simplified_signature'
  sql: |
    {{ fsc_utils.create_udf_evm_text_signature() | indent(4) }}

- name: {{ schema }}.udf_keccak256
  signature:
    - [event_name, VARCHAR(255)]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.9'
    PACKAGES = ('pycryptodome==3.15.0')
    HANDLER = 'udf_encode'
  sql: |
    {{ fsc_utils.create_udf_keccak256() | indent(4) }}

- name: {{ schema }}.udf_decimal_adjust
  signature:
    - [input, string]
    - [adjustment, int]
  return_type: VARCHAR
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.9'
    HANDLER = 'custom_divide'
  sql: |
    {{ fsc_utils.create_udf_decimal_adjust() | indent(4) }}

- name: {{ schema }}.udf_cron_to_prior_timestamps
  signature:
    - [workflow_name, STRING]
    - [workflow_schedule, STRING]
  return_type: TABLE(workflow_name STRING, workflow_schedule STRING, timestamp TIMESTAMP_NTZ)
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.9'
    PACKAGES = ('croniter')
    HANDLER = 'TimestampGenerator'
  sql: |
    {{ fsc_utils.create_udf_cron_to_prior_timestamps() | indent(4) }}

- name: {{ schema }}.udf_transform_logs
  signature:
    - [decoded, VARIANT]
  return_type: VARIANT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.9'
    HANDLER = 'transform'
  sql: |
    {{ fsc_utils.create_udf_transform_logs() | indent(4) }}

- name: {{ schema }}.udf_base58_to_hex
  signature:
    - [base58, STRING]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.9'
    HANDLER = 'transform_base58_to_hex'
  sql: |
    {{ fsc_utils.create_udf_base58_to_hex() | indent(4) }}

- name: {{ schema }}.udf_hex_to_base58
  signature:
    - [input, STRING]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.9'
    HANDLER = 'transform_hex_to_base58'
  sql: |
    {{ fsc_utils.create_udf_hex_to_base58() | indent(4) }}

- name: {{ schema }}.udf_hex_to_bech32
  signature:
    - [input, STRING]
    - [hrp, STRING]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.9'
    HANDLER = 'transform_hex_to_bech32'
  sql: |
    {{ fsc_utils.create_udf_hex_to_bech32() | indent(4) }}

- name: {{ schema }}.udf_hex_to_algorand
  signature:
    - [input, STRING]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.9'
    HANDLER = 'transform_hex_to_algorand'
  sql: |
    {{ fsc_utils.create_udf_hex_to_algorand() | indent(4) }}

- name: {{ schema }}.udf_hex_to_tezos
  signature:
    - [input, STRING]
    - [prefix, STRING]
  return_type: TEXT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.9'
    HANDLER = 'transform_hex_to_tezos'
  sql: |
    {{ fsc_utils.create_udf_hex_to_tezos() | indent(4) }}

- name: {{ schema }}.udf_detect_overflowed_responses
  signature:
    - [file_url, STRING]
    - [index_cols, ARRAY]
  return_type: ARRAY
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.11'
    COMMENT = 'Detect overflowed responses larger than 16MB'
    PACKAGES = ('snowflake-snowpark-python', 'pandas')
    HANDLER = 'main'
  sql: |
    {{ fsc_utils.create_udf_detect_overflowed_responses() | indent(4) }}

- name: {{ schema }}.udtf_flatten_overflowed_responses
  signature:
    - [file_url, STRING]
    - [index_cols, ARRAY]
    - [index_vals, ARRAY]
  return_type: |
    table(
          index_vals ARRAY,
          block_number NUMBER,
          metadata OBJECT,
          seq NUMBER,
          key STRING,
          path STRING,
          index NUMBER,
          value_ VARIANT
        )
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.11'
    COMMENT = 'Flatten rows from a JSON file with overflowed responses larger than 16MB'
    PACKAGES = ('snowflake-snowpark-python', 'pandas', 'simplejson', 'numpy')
    HANDLER = 'FlattenRows'
  sql: |
    {{ fsc_utils.create_udtf_flatten_overflowed_responses() | indent(4) }}

- name: {{ schema }}.udf_stablecoin_data_parse
  signature:
    - [peggeddata_content, STRING]
  return_type: |
    TABLE (
        id STRING,
        name STRING,
        address STRING,
        symbol STRING,
        onCoinGecko BOOLEAN,
        gecko_id STRING,
        cmcId STRING,
        pegType STRING,
        pegMechanism STRING,
        priceSource STRING,
        deadFrom STRING,
        delisted BOOLEAN,
        deprecated BOOLEAN,
        doublecounted BOOLEAN
    )
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.10'
    HANDLER = 'udf_stablecoin_data_parse'
  sql: |
    {{ fsc_utils.create_udf_stablecoin_data_parse() | indent(4) }}

{% endmacro %}

