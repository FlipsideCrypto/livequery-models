{% macro config_core_secrets(schema="secrets") %}


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
    COMMENT = $$ Registers a secret with the given request ID and key. $$
  sql: |
    SELECT
      _utils.UDF_REGISTER_SECRET(REQUEST_ID, _utils.UDF_WHOAMI(), KEY)

- name: {{ schema }}.udf_get_secret
  signature:
    - [name, STRING]
  func_type: SECURE
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    COMMENT = $$ Returns the secret value for the given secret name. $$
  sql: |
    SELECT
      live.udf_api(
        CONCAT_WS('/', {{ construct_api_route("secret") }}, _utils.UDF_WHOAMI(), NAME)
        ):data::OBJECT

- name: {{ schema }}.udf_get_secrets
  signature: []
  func_type: SECURE
  return_type: OBJECT
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    COMMENT = $$ Returns all secrets for the current user. $$
  sql: |
    SELECT
      {{ schema }}.udf_get_secret('')

- name: {{ schema }}.udf_create_secret
  signature:
    - [name, STRING]
    - [secret, OBJECT]
  func_type: SECURE
  return_type: INTEGER
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    COMMENT = $$ Creates a new secret with the given name and value. $$
  sql: |
    SELECT
      live.udf_api(
        CONCAT_WS('/', {{ construct_api_route("secret") }}, _utils.UDF_WHOAMI(), NAME),
        SECRET
        ):status_code::INTEGER

- name: {{ schema }}.udf_delete_secret
  signature:
    - [name, STRING]
  func_type: SECURE
  return_type: INTEGER
  options: |
    NULL
    RETURNS NULL ON NULL INPUT
    IMMUTABLE
    COMMENT = $$ Deletes the secret with the given name. $$
  sql: |
    SELECT
      live.udf_api(
        'DELETE',
        CONCAT_WS('/', {{ construct_api_route("secret") }}, _utils.UDF_WHOAMI(), NAME),
        {},
        {},
        ''
        ):status_code::INTEGER


{% endmacro %}