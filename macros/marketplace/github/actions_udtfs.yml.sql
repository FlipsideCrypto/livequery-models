{% macro config_github_actions_udtfs(schema_name = "github_actions", utils_schema_name = "github_utils") -%}
{#
    This macro is used to generate the Github API Calls
 #}
- name: {{ schema_name -}}.tf_workflows
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [query, "OBJECT"]
  return_type:
    - "TABLE(id INTEGER, badge_url STRING, created_at TIMESTAMP, html_url STRING, name STRING, node_id STRING, path STRING, state STRING, updated_at TIMESTAMP, url STRING)"
  options: |
    COMMENT = $$[List repository workflows](https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#list-repository-workflows).$$
  sql: |
    WITH workflows AS
    (
    SELECT
        github_actions.workflows(OWNER, REPO, QUERY) AS response
    )
    SELECT
        value:id::INTEGER AS id
        ,value:badge_url::STRING AS badge_url
        ,value:created_at::TIMESTAMP AS created_at
        ,value:html_url::STRING AS html_url
        ,value:name::STRING AS name
        ,value:node_id::STRING AS node_id
        ,value:path::STRING AS path
        ,value:state::STRING AS state
        ,value:updated_at::TIMESTAMP AS updated_at
        ,value:url::STRING AS url
    FROM workflows, LATERAL FLATTEN( input=> response:workflows)
- name: {{ schema_name -}}.tf_workflows
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
  return_type:
    - "TABLE(id INTEGER, badge_url STRING, created_at TIMESTAMP, html_url STRING, name STRING, node_id STRING, path STRING, state STRING, updated_at TIMESTAMP, url STRING)"
  options: |
    COMMENT = $$[List repository workflows](https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#list-repository-workflows).$$
  sql: |
    SELECT *
    FROM TABLE({{ schema_name -}}.tf_workflows(owner, repo, {}))

- name: {{ schema_name -}}.tf_runs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [query, "OBJECT"]
  return_type:
    - "TABLE(id NUMBER, name STRING, node_id STRING, check_suite_id NUMBER, check_suite_node_id STRING, head_branch STRING, head_sha STRING, run_number NUMBER, event STRING, display_title STRING, status STRING, conclusion STRING, workflow_id NUMBER, url STRING, html_url STRING, pull_requests STRING, created_at TIMESTAMP, updated_at TIMESTAMP, actor OBJECT, run_attempt STRING, run_started_at TIMESTAMP, triggering_actor OBJECT, jobs_url STRING, logs_url STRING, check_suite_url STRING, artifacts_url STRING, cancel_url STRING, rerun_url STRING, workflow_url STRING, head_commit OBJECT, repository OBJECT, head_repository OBJECT)"
  options: |
        COMMENT = $$Lists all workflow runs for a repository. You can use query parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-repository).$$

  sql: |
    WITH response AS
    (
    SELECT
        github_actions.runs(OWNER, REPO, QUERY) AS response
    )
    SELECT
      value:id::NUMBER AS id
      ,value:name::STRING AS name
      ,value:node_id::STRING AS node_id
      ,value:check_suite_id::NUMBER AS check_suite_id
      ,value:check_suite_node_id::STRING AS check_suite_node_id
      ,value:head_branch::STRING AS head_branch
      ,value:head_sha::STRING AS head_sha
      ,value:run_number::NUMBER AS run_number
      ,value:event::STRING AS event
      ,value:display_title::STRING AS display_title
      ,value:status::STRING AS status
      ,value:conclusion::STRING AS conclusion
      ,value:workflow_id::NUMBER AS workflow_id
      ,value:url::STRING AS url
      ,value:html_url::STRING AS html_url
      ,value:pull_requests::STRING AS pull_requests
      ,value:created_at::TIMESTAMP AS created_at
      ,value:updated_at::TIMESTAMP AS updated_at
      ,value:actor::OBJECT AS actor
      ,value:run_attempt::STRING AS run_attempt
      ,value:run_started_at::TIMESTAMP AS run_started_at
      ,value:triggering_actor::OBJECT AS triggering_actor
      ,value:jobs_url::STRING AS jobs_url
      ,value:logs_url::STRING AS logs_url
      ,value:check_suite_url::STRING AS check_suite_url
      ,value:artifacts_url::STRING AS artifacts_url
      ,value:cancel_url::STRING AS cancel_url
      ,value:rerun_url::STRING AS rerun_url
      ,value:workflow_url::STRING AS workflow_url
      ,value:head_commit::OBJECT AS head_commit
      ,value:repository::OBJECT AS repository
      ,value:head_repository::OBJECT AS head_repository
    FROM response, LATERAL FLATTEN( input=> response:workflow_runs)
- name: {{ schema_name -}}.tf_runs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
  return_type:
    - "TABLE(id NUMBER, name STRING, node_id STRING, check_suite_id NUMBER, check_suite_node_id STRING, head_branch STRING, head_sha STRING, run_number NUMBER, event STRING, display_title STRING, status STRING, conclusion STRING, workflow_id NUMBER, url STRING, html_url STRING, pull_requests STRING, created_at TIMESTAMP, updated_at TIMESTAMP, actor OBJECT, run_attempt STRING, run_started_at TIMESTAMP, triggering_actor OBJECT, jobs_url STRING, logs_url STRING, check_suite_url STRING, artifacts_url STRING, cancel_url STRING, rerun_url STRING, workflow_url STRING, head_commit OBJECT, repository OBJECT, head_repository OBJECT)"
  options: |
      COMMENT = $$Lists all workflow runs for a repository. You can use query parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-repository).$$
  sql: |
    SELECT *
    FROM TABLE({{ schema_name -}}.tf_runs(owner, repo, {}))

- name: {{ schema_name -}}.tf_workflow_runs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [workflkow_id, "TEXT"]
    - [query, "OBJECT"]
  return_type:
    - "TABLE(id NUMBER, name STRING, node_id STRING, check_suite_id NUMBER, check_suite_node_id STRING, head_branch STRING, head_sha STRING, run_number NUMBER, event STRING, display_title STRING, status STRING, conclusion STRING, workflow_id NUMBER, url STRING, html_url STRING, pull_requests STRING, created_at TIMESTAMP, updated_at TIMESTAMP, actor OBJECT, run_attempt STRING, run_started_at TIMESTAMP, triggering_actor OBJECT, jobs_url STRING, logs_url STRING, check_suite_url STRING, artifacts_url STRING, cancel_url STRING, rerun_url STRING, workflow_url STRING, head_commit OBJECT, repository OBJECT, head_repository OBJECT)"
  options: |
      COMMENT = $$Lists all workflow runs for a repository. You can use query parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-repository).$$
  sql: |
    WITH response AS
    (
    SELECT
        github_actions.workflow_runs(OWNER, REPO, WORKFLKOW_ID, QUERY) AS response
    )
    SELECT
      value:id::NUMBER AS id
      ,value:name::STRING AS name
      ,value:node_id::STRING AS node_id
      ,value:check_suite_id::NUMBER AS check_suite_id
      ,value:check_suite_node_id::STRING AS check_suite_node_id
      ,value:head_branch::STRING AS head_branch
      ,value:head_sha::STRING AS head_sha
      ,value:run_number::NUMBER AS run_number
      ,value:event::STRING AS event
      ,value:display_title::STRING AS display_title
      ,value:status::STRING AS status
      ,value:conclusion::STRING AS conclusion
      ,value:workflow_id::NUMBER AS workflow_id
      ,value:url::STRING AS url
      ,value:html_url::STRING AS html_url
      ,value:pull_requests::STRING AS pull_requests
      ,value:created_at::TIMESTAMP AS created_at
      ,value:updated_at::TIMESTAMP AS updated_at
      ,value:actor::OBJECT AS actor
      ,value:run_attempt::STRING AS run_attempt
      ,value:run_started_at::TIMESTAMP AS run_started_at
      ,value:triggering_actor::OBJECT AS triggering_actor
      ,value:jobs_url::STRING AS jobs_url
      ,value:logs_url::STRING AS logs_url
      ,value:check_suite_url::STRING AS check_suite_url
      ,value:artifacts_url::STRING AS artifacts_url
      ,value:cancel_url::STRING AS cancel_url
      ,value:rerun_url::STRING AS rerun_url
      ,value:workflow_url::STRING AS workflow_url
      ,value:head_commit::OBJECT AS head_commit
      ,value:repository::OBJECT AS repository
      ,value:head_repository::OBJECT AS head_repository
    FROM response, LATERAL FLATTEN( input=> response:workflow_runs)
- name: {{ schema_name -}}.tf_workflow_runs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [workflkow_id, "TEXT"]
  return_type:
    - "TABLE(id NUMBER, name STRING, node_id STRING, check_suite_id NUMBER, check_suite_node_id STRING, head_branch STRING, head_sha STRING, run_number NUMBER, event STRING, display_title STRING, status STRING, conclusion STRING, workflow_id NUMBER, url STRING, html_url STRING, pull_requests STRING, created_at TIMESTAMP, updated_at TIMESTAMP, actor OBJECT, run_attempt STRING, run_started_at TIMESTAMP, triggering_actor OBJECT, jobs_url STRING, logs_url STRING, check_suite_url STRING, artifacts_url STRING, cancel_url STRING, rerun_url STRING, workflow_url STRING, head_commit OBJECT, repository OBJECT, head_repository OBJECT)"
  options: |
        COMMENT = $$Lists all workflow runs for a repository. You can use query parameters to narrow the list of results. [Docs](https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-repository).$$
  sql: |
    SELECT *
    FROM TABLE({{ schema_name -}}.tf_workflow_runs(owner, repo, WORKFLKOW_ID, {}))

{% endmacro %}