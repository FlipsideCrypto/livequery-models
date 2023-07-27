{% macro config_footprint_gamefi_udfs(schema_name = "footprint_gamefi", utils_schema_name = "footprint_utils") -%}
{#
    This macro is used to generate the Footprint Gamefi endpoints
 #}

- name: {{ schema_name -}}.get_protocols
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the basic information of the protocol. [Footprint docs here](https://docs.footprint.network/reference/get_protocol-info).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/protocol/info") | trim}}

- name: {{ schema_name -}}.get_protocols_by_contract
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the basic information of the protocol by contract address. [Footprint docs here](https://docs.footprint.network/reference/get_protocol-info-by-contract).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/protocol/info/by-contract") | trim}}

- name: {{ schema_name -}}.get_protocols_by_name
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the basic information of the protocol by name. [Footprint docs here](https://docs.footprint.network/reference/get_protocol-info-by-name).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/protocol/info/by-name") | trim}}

- name: {{ schema_name -}}.get_protocol_active_users
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the active users of the protocol. [Footprint docs here](https://docs.footprint.network/reference/get_protocol-active-user).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/protocol/active-user") | trim}}

- name: {{ schema_name -}}.get_protocol_active_user_stats
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the active user statistics data of the protocol. [Footprint docs here](https://docs.footprint.network/reference/get_protocol-active-user-statistics).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/protocol/active-user/statistics") | trim}}

- name: {{ schema_name -}}.get_protocol_new_user_stats
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the new user statistics data of the protocol. [Footprint docs here](https://docs.footprint.network/reference/get_protocol-new-user-statistics).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/protocol/new-user/statistics") | trim}}

- name: {{ schema_name -}}.get_protocol_stats
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the statistics metrics data of the protocol. [Footprint docs here](https://docs.footprint.network/reference/get_protocol-statistics).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/protocol/statistics") | trim}}

{% endmacro %}