{% macro config_github_actions_udfs(schema_name = "github_actions", utils_schema_name = "github_utils") -%}
{#
    This macro is used to generate the Github API Calls
 #}
- name: {{ schema_name -}}.workflows
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [query, "OBJECT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$[List repository workflows](https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#list-repository-workflows).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.GET(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/workflows'),
        query
    ):data::VARIANT
- name: {{ schema_name -}}.workflows
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$[List repository workflows](https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#list-repository-workflows).$$
  sql: |
    SELECT
      {{ schema_name -}}.workflows(owner, repo, {})

- name: {{ schema_name -}}.runs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [query, "OBJECT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Lists all workflow runs for a repository. You can use query parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-repository).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.GET(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/runs'),
        query
    ):data::VARIANT
- name: {{ schema_name -}}.runs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Lists all workflow runs for a repository. You can use query parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-repository).$$
  sql: |
    SELECT
      {{ schema_name -}}.runs(owner, repo, {})

- name: {{ schema_name -}}.workflow_runs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [workflow_id, "TEXT"]
    - [query, "OBJECT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List all workflow runs for a workflow. You can replace workflow_id with the workflow file name. You can use query parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-workflow).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.GET(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/workflows', workflow_id, 'runs'),
        query
    ):data::VARIANT
- name: {{ schema_name -}}.workflow_runs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [workflow_id, "TEXT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List all workflow runs for a workflow. You can replace workflow_id with the workflow file name. You can use query parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-workflow).$$
  sql: |
    SELECT
      {{ schema_name -}}.workflow_runs(owner, repo, workflow_id, {})

- name: {{ schema_name -}}.workflow_dispatches
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [workflow_id, "TEXT"]
    - [body, "OBJECT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$You can use this endpoint to manually trigger a GitHub Actions workflow run. You can replace workflow_id with the workflow file name. For example, you could use main.yaml. [Docs](https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#create-a-workflow-dispatch-event).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.POST(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/workflows', workflow_id, 'dispatches'),
        COALESCE(body, {'ref': 'main'})::OBJECT
    )::VARIANT

- name: {{ schema_name -}}.workflow_dispatches
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [workflow_id, "TEXT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$You can use this endpoint to manually trigger a GitHub Actions workflow run. You can replace workflow_id with the workflow file name. For example, you could use main.yaml. [Docs](https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#create-a-workflow-dispatch-event).$$
  sql: |
    SELECT
      {{ schema_name -}}.workflow_dispatches(owner, repo, workflow_id, NULL)

- name: {{ schema_name -}}.workflow_enable
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [workflow_id, "TEXT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Enables a workflow. You can replace workflow_id with the workflow file name. For example, you could use main.yaml. [Docs](https://docs.github.com/en/rest/reference/actions#enable-a-workflow).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.PUT(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/workflows', workflow_id, 'enable'),
        {}
    )::VARIANT
- name: {{ schema_name -}}.workflow_disable
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [workflow_id, "TEXT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Disables a workflow. You can replace workflow_id with the workflow file name. For example, you could use main.yaml. [Docs](https://docs.github.com/en/rest/reference/actions#disable-a-workflow).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.PUT(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/workflows', workflow_id, 'disable'),
        {}
    )::VARIANT

- name: {{ schema_name -}}.workflow_run_logs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [run_id, "TEXT"]
  return_type:
    - "TEXT"
  options: |
    COMMENT = $$Download workflow run logs as a ZIP archive. Gets a redirect URL to the actual log archive. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#download-workflow-run-logs).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.GET(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/runs', run_id, 'logs'),
        {}
    ):data::TEXT

- name: {{ schema_name -}}.job_logs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [job_id, "TEXT"]
  return_type:
    - "TEXT"
  options: |
    COMMENT = $$Download job logs. Gets the plain text logs for a specific job. [Docs](https://docs.github.com/en/rest/actions/workflow-jobs?apiVersion=2022-11-28#download-job-logs-for-a-workflow-run).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.GET(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/jobs', job_id, 'logs'),
        {}
    ):data::TEXT

- name: {{ schema_name -}}.workflow_run_jobs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [run_id, "TEXT"]
    - [query, "OBJECT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Lists jobs for a workflow run. [Docs](https://docs.github.com/en/rest/actions/workflow-jobs?apiVersion=2022-11-28#list-jobs-for-a-workflow-run).$$
  sql: |
    SELECT
      {{ utils_schema_name }}.GET(
        CONCAT_WS('/', 'repos', owner, repo, 'actions/runs', run_id, 'jobs'),
        query
    ):data::VARIANT
- name: {{ schema_name -}}.workflow_run_jobs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [run_id, "TEXT"]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Lists jobs for a workflow run. [Docs](https://docs.github.com/en/rest/actions/workflow-jobs?apiVersion=2022-11-28#list-jobs-for-a-workflow-run).$$
  sql: |
    SELECT
      {{ schema_name -}}.workflow_run_jobs(owner, repo, run_id, {})

{% endmacro %}