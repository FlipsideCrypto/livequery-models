{% macro config_snapshot_udfs(schema_name = "snapshot", utils_schema_name="snapshot_utils") -%}
{#
    This macro is used to generate the Snapshot Base endpoints
 #}

- name: {{ schema_name -}}.query
  signature:
    - [QUERY, OBJECT, The GraphQL query]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Used to issue a Graphql Query to the Snapshot API. [Snapshot docs here](https://docs.snapshot.org/tools/api).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        'https://hub.snapshot.org/graphql',
        {},
        QUERY
    ) as response

{% endmacro %}