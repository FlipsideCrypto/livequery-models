{% macro config_core_live(schema="live") %}

- name: {{ schema }}.udf_api
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [data, VARIANT]
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
- name: {{ schema }}.udf_api
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [data, VARIANT]
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
- name: {{ schema }}.udf_api
  signature:
    - [url, STRING]
    - [data, VARIANT]
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
- name: {{ schema }}.udf_api
  signature:
    - [url, STRING]
    - [data, VARIANT]
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
- name: {{ schema }}.udf_api
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
- name: {{ schema }}.udf_api
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

- name: {{ schema }}.udf_rpc
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

- name: {{ schema }}.udf_allow_list
  signature: []
  return_type: ARRAY
  func_type: EXTERNAL
  api_integration: '{{ var("API_INTEGRATION") }}'
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns a list of allowed domains.$$
  sql: allowed
{% endmacro %}