{% macro config_dune_udfs(schema_name = "dune", utils_schema_name="dune_utils") -%}
{#
    This macro is used to generate the Dune Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, ARRAY, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Dune API. [Dune docs here](https://dune.com/docs/api/api-reference/authentication/).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.dune.com', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'x-dune-api-key': '{API_KEY}'},
        {},
        '_FSC_SYS/DUNE'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Dune API. [Dune docs here](https://dune.com/docs/api/api-reference/authentication/).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://api.dune.com', PATH),
        {'x-dune-api-key': '{API_KEY}'},
        BODY,
        '_FSC_SYS/DUNE'
    ) as response

{% endmacro %}