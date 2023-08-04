{% macro config_chainstack_udfs(schema_name = "chainstack", utils_schema_name="chainstack_utils") -%}
{#
    This macro is used to generate the Chainstack Base api endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, ARRAY, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Chainstack API. [Chainstack docs here](https://docs.chainstack.com/reference/blockchain-apis).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.chainstack.com', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'authorization': 'Bearer {API_KEY}'},
        {},
        '_FSC_SYS/CHAINSTACK'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Chainstack API. [Chainstack docs here](https://docs.chainstack.com/reference/blockchain-apis).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT('https://api.chainstack.com', PATH),
        {'authorization': 'Bearer {API_KEY}'},
        BODY,
        '_FSC_SYS/CHAINSTACK'
    ) as response

{% endmacro %}