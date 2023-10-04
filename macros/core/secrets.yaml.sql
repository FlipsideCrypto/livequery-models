{% macro config_core_secrets(schema="utils") %}


- name: {{ schema }}.udf_register_secret
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

- name: {{ schema }}.udf_get_secret
  signature:
    - [secret_name, STRING]
  func_type: SECURE
  return_type: VARIANT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    SELECT
      live.udf_api(CONCAT_WS('/', {{ construct_api_route("/secret") }}, _utils.UDF_WHOAMI(), SECRET_NAME))

- name: {{ schema }}.udf_create_secret
  signature:
    - [secret_name, STRING]
    - [secret, OBJECT]
  func_type: SECURE
  return_type: VARIANT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    SELECT
      live.udf_api(
        CONCAT_WS('/', {{ construct_api_route("/secret") }}, _utils.UDF_WHOAMI(), SECRET_NAME),
        SECRET
        )

- name: {{ schema }}.udf_delete_secret
  signature:
    - [secret_name, STRING]
  func_type: SECURE
  return_type: VARIANT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
  sql: |
    SELECT
      live.udf_api(
        'DELETE',
        CONCAT_WS('/', {{ construct_api_route("/secret") }}, _utils.UDF_WHOAMI(), SECRET_NAME)
        )


{% endmacro %}