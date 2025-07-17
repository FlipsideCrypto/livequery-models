{% macro config_core_live(schema="live") %}

- name: {{ schema }}.udf_api_batched
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [data, VARIANT]
    - [secret_name, STRING]
  return_type: VARIANT
  options: |
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
    - [secret_name, STRING]
  return_type: VARIANT
  options: |
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
    VOLATILE
  sql: |
    SELECT
      _live.UDF_API(
          'GET',
          url,
          {},
          NULL,
          _utils.UDF_WHOAMI(),
          ''
      )
- name: {{ schema }}.udf_api
  signature:
    - [url, STRING]
    - [secret_name, STRING]
  return_type: VARIANT
  options: |
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
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns a list of allowed domains.$$
  sql: allowed

- name: {{ schema }}.udf_api_v2
  signature:
    - [url, STRING]
    - [headers, OBJECT]
    - [secret_name, STRING]
  return_type: VARIANT
  options: |
    VOLATILE
    COMMENT = $$Executes an LiveQuery Sync or Async Externall Function.$$
  sql: |
    SELECT
        utils.udf_redirect_s3_presigned_url(
            _live.udf_api_async('GET', url, headers, {}, _utils.UDF_WHOAMI(), secret_name)
            :s3_presigned_url::STRING
        ):data[0][1] as result
    WHERE LOWER(COALESCE(
        headers:"fsc-quantum-execution-mode"::STRING,
        headers:"Fsc-Quantum-Execution-Mode"::STRING,
        headers:"FSC-QUANTUM-EXECUTION-MODE"::STRING
    )) = 'async'

    UNION ALL

    SELECT
        _live.udf_api_sync('GET', url, headers, {}, _utils.UDF_WHOAMI(), secret_name) as result
    WHERE LOWER(COALESCE(
        headers:"fsc-quantum-execution-mode"::STRING,
        headers:"Fsc-Quantum-Execution-Mode"::STRING,
        headers:"FSC-QUANTUM-EXECUTION-MODE"::STRING,
        'sync'
    )) != 'async'

- name: {{ schema }}.udf_api_v2
  signature:
    - [url, STRING]
    - [headers, OBJECT]
    - [secret_name, STRING]
    - [is_async, BOOLEAN]
  return_type: VARIANT
  options: |
    VOLATILE
    COMMENT = $$Executes an LiveQuery Sync or Async Externall Function.$$
  sql: |
    SELECT
        utils.udf_redirect_s3_presigned_url(
            _live.udf_api_async('GET', url, headers, {}, _utils.UDF_WHOAMI(), secret_name)
            :s3_presigned_url::STRING
        ):data[0][1] as result
    WHERE LOWER(COALESCE(
        headers:"fsc-quantum-execution-mode"::STRING,
        headers:"Fsc-Quantum-Execution-Mode"::STRING,
        headers:"FSC-QUANTUM-EXECUTION-MODE"::STRING
    )) = 'async'

    UNION ALL

    SELECT
        _live.udf_api_sync('GET', url, headers, {}, _utils.UDF_WHOAMI(), secret_name) as result
    WHERE LOWER(COALESCE(
        headers:"fsc-quantum-execution-mode"::STRING,
        headers:"Fsc-Quantum-Execution-Mode"::STRING,
        headers:"FSC-QUANTUM-EXECUTION-MODE"::STRING,
        'sync'
    )) != 'async'

- name: {{ schema }}.udf_api_v2
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [data, VARIANT]
    - [secret_name, STRING]
  return_type: VARIANT
  options: |
    VOLATILE
    COMMENT = $$Executes an LiveQuery Sync or Async Externall Function.$$
  sql: |
    SELECT
        utils.udf_redirect_s3_presigned_url(
            _live.udf_api_async(method, url, headers, data, _utils.UDF_WHOAMI(), secret_name)
            :s3_presigned_url::STRING
        ):data[0][1] as result
    WHERE LOWER(COALESCE(
        headers:"fsc-quantum-execution-mode"::STRING,
        headers:"Fsc-Quantum-Execution-Mode"::STRING,
        headers:"FSC-QUANTUM-EXECUTION-MODE"::STRING
    )) = 'async'

    UNION ALL

    SELECT
        _live.udf_api_sync(method, url, headers, data, _utils.UDF_WHOAMI(), secret_name) as result
    WHERE LOWER(COALESCE(
        headers:"fsc-quantum-execution-mode"::STRING,
        headers:"Fsc-Quantum-Execution-Mode"::STRING,
        headers:"FSC-QUANTUM-EXECUTION-MODE"::STRING,
        'sync'
    )) != 'async'

- name: {{ schema }}.udf_api_v2
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [data, VARIANT]
    - [secret_name, STRING]
    - [is_async, BOOLEAN]
  return_type: VARIANT
  options: |
    VOLATILE
    COMMENT = $$Executes an LiveQuery Sync or Async Externall Function.$$
  sql: |
    SELECT
    CASE is_async
        WHEN TRUE
        THEN
            utils.udf_redirect_s3_presigned_url(
                _live.udf_api_async(
                    METHOD, URL, HEADERS, DATA, _utils.UDF_WHOAMI(), SECRET_NAME
                ):s3_presigned_url :: STRING
            ):data[0][1]
        ELSE
            _live.udf_api_sync(
                METHOD, URL, HEADERS, DATA, _utils.UDF_WHOAMI(), SECRET_NAME
            )
    END

- name: {{ schema }}.udf_api_v2
  signature:
    - [method, STRING]
    - [url, STRING]
    - [headers, OBJECT]
    - [data, VARIANT]
  return_type: VARIANT
  options: |
    VOLATILE
    COMMENT = $$Executes an LiveQuery Sync or Async Externall Function.$$
  sql: |
    SELECT
        utils.udf_redirect_s3_presigned_url(
            _live.udf_api_async(method, url, headers, data, _utils.UDF_WHOAMI(), '')
            :s3_presigned_url::STRING
        ):data[0][1] as result
    WHERE LOWER(COALESCE(
        headers:"fsc-quantum-execution-mode"::STRING,
        headers:"Fsc-Quantum-Execution-Mode"::STRING,
        headers:"FSC-QUANTUM-EXECUTION-MODE"::STRING
    )) = 'async'

    UNION ALL

    SELECT
        _live.udf_api_sync(method, url, headers, data, _utils.UDF_WHOAMI(), '') as result
    WHERE LOWER(COALESCE(
        headers:"fsc-quantum-execution-mode"::STRING,
        headers:"Fsc-Quantum-Execution-Mode"::STRING,
        headers:"FSC-QUANTUM-EXECUTION-MODE"::STRING,
        'sync'
    )) != 'async'

- name: {{ schema }}.udf_api_v2
  signature:
    - [url, STRING]
    - [data, VARIANT]
  return_type: VARIANT
  options: |
    VOLATILE
    COMMENT = $$Executes an LiveQuery Sync or Async Externall Function.$$
  sql: |
    SELECT
        _live.udf_api_sync(
          'POST',
          url,
          {'Content-Type': 'application/json'},
          data,
          _utils.UDF_WHOAMI(),
          ''
        )

- name: {{ schema }}.udf_api_v2
  signature:
    - [url, STRING]
    - [data, VARIANT]
    - [secret_name, STRING]
  return_type: VARIANT
  options: |
    VOLATILE
    COMMENT = $$Executes an LiveQuery Sync or Async Externall Function.$$
  sql: |
    SELECT
        _live.udf_api_sync(
          'POST',
          url,
          {'Content-Type': 'application/json'},
          data,
          _utils.UDF_WHOAMI(),
          secret_name
        )

- name: {{ schema }}.udf_api_v2
  signature:
    - [url, STRING]
  return_type: VARIANT
  options: |
    VOLATILE
    COMMENT = $$Executes an LiveQuery Sync or Async Externall Function.$$
  sql: |
    SELECT
        _live.udf_api_sync(
          'GET',
          url,
          {},
          NULL,
          _utils.UDF_WHOAMI(),
          ''
        )

- name: {{ schema }}.udf_api_v2
  signature:
    - [url, STRING]
    - [secret_name, STRING]
  return_type: VARIANT
  options: |
    VOLATILE
    COMMENT = $$Executes an LiveQuery Sync or Async Externall Function.$$
  sql: |
    SELECT
        _live.udf_api_sync(
          'GET',
          url,
          {},
          {},
          _utils.UDF_WHOAMI(),
          secret_name
        )
{% endmacro %}
