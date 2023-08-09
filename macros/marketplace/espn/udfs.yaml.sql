{% macro config_espn_udfs(schema_name = "espn", utils_schema_name="espn_utils") -%}
{#
    This macro is used to generate the ESPN Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [URL, STRING, The full url including the path]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the ESPN API. [ESPN docs here](https://gist.github.com/akeaswaran/b48b02f1c94f873c6655e7129910fc3b#file-espn-api-docs-md).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat(URL, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {},
        {}
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [URL, STRING, The full url]
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the ESPN API. [ESPN docs here](https://gist.github.com/akeaswaran/b48b02f1c94f873c6655e7129910fc3b#file-espn-api-docs-md).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        URL,
        {},
        BODY
    ) as response
{% endmacro %}