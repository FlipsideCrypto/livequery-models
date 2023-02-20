{% macro udf_configs() %}
streamline.introspect:
  name: streamline.udf_introspect
  signature:
    - [echo, STRING]
  func_type: SECURE EXTERNAL
  return_type: TEXT
  api_integration: AWS_LIVE_QUERY_DEV
  sql: introspect

beta.udf_register_secret:
  name: beta.udf_register_secret
  signature:
    - [request_id, string]
    - [key, string]
  func_type: SECURE
  return_type: TEXT
  options: NOT NULL STRICT IMMUTABLE
  sql: |
    SELECT
      STREAMLINE.UDF_REGISTER_SECRET(REQUEST_ID, STREAMLINE.UDF_WHOAMI(), KEY)

beta.udf_api:
  name: beta.udf_api
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
      STREAMLINE.UDF_API(
          method,
          url,
          headers,
          data,
          STREAMLINE.UDF_WHOAMI(),
          secret_name
      )

streamline.udf_api:
  name: streamline.udf_api
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

streamline.udf_register_secret:
  name: streamline.udf_register_secret
  signature:
    - [request_id, string]
    - [user_id, string]
    - [key, string]
  return_type: TEXT
  func_type: SECURE EXTERNAL
  api_integration: AWS_LIVE_QUERY_DEV
  options: NOT NULL STRICT
  sql: secret/register

streamline.whoami:
  name: streamline.udf_whoami
  signature: []
  func_type: SECURE
  return_type: TEXT
  options: NOT NULL STRICT IMMUTABLE MEMOIZABLE
  sql: |
    SELECT
      COALESCE(SPLIT_PART(GETVARIABLE('QUERY_TAG_SESSION'), ',',2), CURRENT_USER())
{% endmacro %}
