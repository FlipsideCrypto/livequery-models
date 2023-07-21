{% macro config_playgrounds_subgraphs_udfs(schema_name = "playgrounds_subgraphs", utils_schema_name = "playgrounds_utils") -%}
{#
    This macro is used to generate the Playgrounds Subgraph Call
 #}

- name: {{ schema_name -}}.query
  signature:
    - [SUBGRAPH_ID, STRING, The ID of the Subgraph]
    - [QUERY, OBJECT, The GraphQL query]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Query a subgraph via the Playgrounds Proxy [Playgrounds docs here](https://docs.playgrounds.network/api/subgraph-proxy/).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        concat('https://api.playgrounds.network/v1/proxy/subgraphs/id/', SUBGRAPH_ID),
        {'Playgrounds-Api-Key': '{API_KEY}', 'Content-Type': 'application/json'},
        QUERY,
        '_FSC_SYS/PLAYGROUNDS'
    ) as response

{% endmacro %}