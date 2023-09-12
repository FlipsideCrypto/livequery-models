{% macro config_github_actions_udfs(schema_name = "github_actions", utils_schema_name = "github_utils") -%}
{#
    This macro is used to generate the Github API Calls
 #}
- name: {{ schema_name -}}.workflows
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$[List repository workflows](https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#list-repository-workflows).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.GET(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/workflows'),
        {}
    ):data::OBJECT

- name: {{ schema_name -}}.runs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [query, "OBJECT"]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$Lists all workflow runs for a repository. You can use query parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#list-repository-workflows).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.GET(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/runs'),
        query
    ):data::OBJECT

- name: {{ schema_name -}}.workflow_runs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [workflow_id, "TEXT"]
    - [query, "OBJECT"]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$List all workflow runs for a workflow. You can replace workflow_id with the workflow file name. You can use query parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-workflow).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.GET(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/workflows', workflow_id, 'runs'),
        query
    ):data::OBJECT

- name: {{ schema_name -}}.workflow_dispatches
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [workflow_id, "TEXT"]
    - [body, "OBJECT"]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$You can use this endpoint to manually trigger a GitHub Actions workflow run. You can replace workflow_id with the workflow file name. For example, you could use main.yaml. [Docs](https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#create-a-workflow-dispatch-event).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.POST(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/workflows', workflow_id, 'dispatches'),
        COALESCE(body, {'ref': 'main'})::OBJECT
    )::OBJECT
{% endmacro %}