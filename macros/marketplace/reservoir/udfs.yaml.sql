{% macro config_reservoir_udfs(schema_name = "reservoir", utils_schema_name="reservoir_utils") -%}
{#
    This macro is used to generate the Reservoir Base endpoints
 #}

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The path starting with '/']
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'GET' request to the Reservoir NFT Data API. [Reservoir docs here](https://docs.reservoir.tools/reference/nft-data-overview).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        concat('https://api.reservoir.tools', PATH, '?', utils.udf_object_to_url_query_string(QUERY_ARGS)),
        {'x-api-key': '{API_KEY}'},
        NULL,
        '_FSC_SYS/RESERVOIR'
    ) as response

- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The path starting with '/']
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a 'POST' request to the Reservoir NFT Data API. [Reservoir docs here](https://docs.reservoir.tools/reference/nft-data-overview).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        concat('https://api.reservoir.tools', PATH),
        {'x-api-key': '{API_KEY}'},
        BODY,
        '_FSC_SYS/RESERVOIR'
    ) as response

{% endmacro %}
