{% macro config_strangelove_udfs(schema_name = "strangelove", utils_schema_name = "strangelove_utils") -%}
{#
    This macro is used to generate the Subquery Calls
 #}

- name: {{ schema_name -}}.get
  signature:
    - [URL, STRING, The url to issue a get request to]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Issue a GET request to a Strangelove Endpoint [Strangelove docs here](https://voyager.strange.love/docs/cosmoshub/mainnet#/).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat(
          URL, '?',
          utils.udf_object_to_url_query_string(QUERY_ARGS)
        ),
        {'x-apikey': '{API_KEY}'},
        {},
        '_FSC_SYS/STRANGELOVE'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [URL, STRING, The url to issue a post request to]
    - [QUERY, OBJECT, The body of the request]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Issue a POST request to a Strangelove Endpoint [Strangelove docs here](https://voyager.strange.love/docs/cosmoshub/mainnet#/).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        URL,
        {'x-apikey': '{API_KEY}'},
        QUERY,
        '_FSC_SYS/STRANGELOVE'
    ) as response

{% endmacro %}