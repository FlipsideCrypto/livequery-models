{% macro config_blockpour_util_udfs(schema_name = "blockpour_utils", utils_schema_name="blockpour_utils") -%}
{#
    This macro is used to generate the Blockpour base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Blockpour API.$$
  sql: |
    SELECT 
      live.udf_api(
        'GET',
        concat(
           'https://services.blockpour.com/api', PATH, 
            utils.udf_object_to_url_query_string(QUERY_ARGS)
        ),
        {'api-key': '{API_KEY}'},
        {},
        '_FSC_SYS/BLOCKPOUR'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the BlockPour API.$$
  sql: |
    SELECT 
      live.udf_api(
        'POST',
        concat('https://services.blockpour.com/api', PATH),
        {'api-key': '{API_KEY}'},
        BODY,
        '_FSC_SYS/BLOCKPOUR'
    ) as response

{% endmacro %}