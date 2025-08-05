{% macro config_covalent_udfs(schema_name = "covalent", utils_schema_name="covalent_utils") -%}
{#
    This macro is used to generate the Covalent Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Covalent API. [Covalent docs here](https://www.covalenthq.com/docs/unified-api/).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.covalenthq.com', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'Authorization': 'Bearer {API_KEY}'},
        {},
        '_FSC_SYS/COVALENT'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Covalent API. [Covalent docs here](https://www.covalenthq.com/docs/unified-api/).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://api.covalenthq.com', PATH),
        {'Authorization': 'Bearer {API_KEY}'},
        BODY,
        '_FSC_SYS/COVALENT'
    ) as response

{% endmacro %}