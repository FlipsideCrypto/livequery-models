{% macro config_github_utils_udfs(schema_name = "github_utils", utils_schema_name = "github_utils") -%}
{#
    This macro is used to generate the Github API Calls
 #}
- name: {{ schema_name -}}.octocat
  signature:
    - []
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Verify token [Authenticating to the REST API](https://docs.github.com/en/rest/overview/authenticating-to-the-rest-api?apiVersion=2022-11-28).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        'https://api.github.com/octocat',
        {'Authorization': 'Bearer {TOKEN}',
        'X-GitHub-Api-Version': '2022-11-28'},
        {},
        'vault/github/api'
    ) as response

- name: {{ schema_name -}}.headers
  signature: []
  return_type:
    - "TEXT"
  options: |
    NOT NULL
    IMMUTABLE
    MEMOIZABLE
  sql: |
    SELECT '{"Authorization": "Bearer {TOKEN}",
            "X-GitHub-Api-Version": "2022-11-28",
            "Accept": "application/vnd.github+json"}'

- name: {{ schema_name -}}.get
  signature:
    - [route, "TEXT"]
    - [query, "OBJECT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List all workflow runs for a workflow. You can replace workflow_id with the workflow file name. You can use parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-workflow).$$
  sql: |
    SELECT
      live.udf_api(
        'GET',
        CONCAT_WS('/', 'https://api.github.com',  route || '?') || utils.udf_urlencode(query),
        PARSE_JSON({{ schema_name -}}.headers()),
        {},
        'vault/github/api'
    )
- name: {{ schema_name -}}.post
  signature:
    - [route, "TEXT"]
    - [data, "OBJECT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List all workflow runs for a workflow. You can replace workflow_id with the workflow file name. You can use parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-workflow).$$
  sql: |
    SELECT
      live.udf_api(
        'POST',
        CONCAT_WS('/', 'https://api.github.com', route),
        PARSE_JSON({{ schema_name -}}.headers()),
        data,
        'vault/github/api'
    )
- name: {{ schema_name -}}.put
  signature:
    - [route, "TEXT"]
    - [data, "OBJECT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List all workflow runs for a workflow. You can replace workflow_id with the workflow file name. You can use parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-workflow).$$
  sql: |
    SELECT
      live.udf_api(
        'PUT',
        CONCAT_WS('/', 'https://api.github.com', route),
        PARSE_JSON({{ schema_name -}}.headers()),
        data,
        'vault/github/api'
    )
{% endmacro %}