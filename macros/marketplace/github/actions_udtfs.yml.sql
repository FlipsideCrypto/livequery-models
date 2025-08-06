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

- name: {{ schema_name -}}.tf_workflow_run_jobs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [run_id, "TEXT"]
    - [query, "OBJECT"]
  return_type:
    - "TABLE(id NUMBER, run_id NUMBER, workflow_name STRING, head_branch STRING, run_url STRING, run_attempt NUMBER, node_id STRING, head_sha STRING, url STRING, html_url STRING, status STRING, conclusion STRING, created_at TIMESTAMP, started_at TIMESTAMP, completed_at TIMESTAMP, name STRING, check_run_url STRING, labels VARIANT, runner_id NUMBER, runner_name STRING, runner_group_id NUMBER, runner_group_name STRING, steps VARIANT)"
  options: |
    COMMENT = $$Lists jobs for a workflow run as a table. [Docs](https://docs.github.com/en/rest/actions/workflow-jobs?apiVersion=2022-11-28#list-jobs-for-a-workflow-run).$$
  sql: |
    WITH response AS
    (
    SELECT
        github_actions.workflow_run_jobs(OWNER, REPO, RUN_ID, QUERY) AS response
    )
    SELECT
      value:id::NUMBER AS id
      ,value:run_id::NUMBER AS run_id
      ,value:workflow_name::STRING AS workflow_name
      ,value:head_branch::STRING AS head_branch
      ,value:run_url::STRING AS run_url
      ,value:run_attempt::NUMBER AS run_attempt
      ,value:node_id::STRING AS node_id
      ,value:head_sha::STRING AS head_sha
      ,value:url::STRING AS url
      ,value:html_url::STRING AS html_url
      ,value:status::STRING AS status
      ,value:conclusion::STRING AS conclusion
      ,value:created_at::TIMESTAMP AS created_at
      ,value:started_at::TIMESTAMP AS started_at
      ,value:completed_at::TIMESTAMP AS completed_at
      ,value:name::STRING AS name
      ,value:check_run_url::STRING AS check_run_url
      ,value:labels::VARIANT AS labels
      ,value:runner_id::NUMBER AS runner_id
      ,value:runner_name::STRING AS runner_name
      ,value:runner_group_id::NUMBER AS runner_group_id
      ,value:runner_group_name::STRING AS runner_group_name
      ,value:steps::VARIANT AS steps
    FROM response, LATERAL FLATTEN( input=> response:jobs)

- name: {{ schema_name -}}.tf_workflow_run_jobs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [run_id, "TEXT"]
  return_type:
    - "TABLE(id NUMBER, run_id NUMBER, workflow_name STRING, head_branch STRING, run_url STRING, run_attempt NUMBER, node_id STRING, head_sha STRING, url STRING, html_url STRING, status STRING, conclusion STRING, created_at TIMESTAMP, started_at TIMESTAMP, completed_at TIMESTAMP, name STRING, check_run_url STRING, labels VARIANT, runner_id NUMBER, runner_name STRING, runner_group_id NUMBER, runner_group_name STRING, steps VARIANT)"
  options: |
    COMMENT = $$Lists jobs for a workflow run as a table. [Docs](https://docs.github.com/en/rest/actions/workflow-jobs?apiVersion=2022-11-28#list-jobs-for-a-workflow-run).$$
  sql: |
    SELECT *
    FROM TABLE({{ schema_name -}}.tf_workflow_run_jobs(owner, repo, run_id, {}))

- name: {{ schema_name -}}.tf_failed_jobs_with_logs
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [run_id, "TEXT"]
  return_type:
    - "TABLE(run_id STRING, job_id NUMBER, job_name STRING, job_status STRING, job_conclusion STRING, job_url STRING, failed_steps VARIANT, logs TEXT, failed_step_logs ARRAY)"
  options: |
    COMMENT = $$Gets failed jobs for a workflow run with their complete logs. Combines job info with log content for analysis.$$
  sql: |
    WITH failed_jobs AS (
      SELECT
        run_id::STRING AS run_id,
        id AS job_id,
        name AS job_name,
        status AS job_status,
        conclusion AS job_conclusion,
        html_url AS job_url,
        steps AS failed_steps
      FROM TABLE({{ schema_name -}}.tf_workflow_run_jobs(owner, repo, run_id))
      WHERE conclusion = 'failure'
    ),
    jobs_with_logs AS (
      SELECT
        run_id,
        job_id,
        job_name,
        job_status,
        job_conclusion,
        job_url,
        failed_steps,
        {{ schema_name -}}.job_logs(owner, repo, job_id::TEXT) AS logs
      FROM failed_jobs
    ),
    error_sections AS (
      SELECT
        run_id,
        job_id,
        job_name,
        job_status,
        job_conclusion,
        job_url,
        failed_steps,
        logs,
        ARRAY_AGG(section.value) AS failed_step_logs
      FROM jobs_with_logs,
      LATERAL FLATTEN(INPUT => SPLIT(logs, '##[group]')) section
      WHERE CONTAINS(section.value, '##[error]')
      GROUP BY run_id, job_id, job_name, job_status, job_conclusion, job_url, failed_steps, logs
    )
    SELECT
      run_id,
      job_id,
      job_name,
      job_status,
      job_conclusion,
      job_url,
      failed_steps,
      logs,
      COALESCE(failed_step_logs, ARRAY_CONSTRUCT()) AS failed_step_logs
    FROM jobs_with_logs
    LEFT JOIN error_sections USING (run_id, job_id)

- name: {{ schema_name -}}.tf_failure_analysis_with_ai
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [run_id, "TEXT"]
    - [ai_provider, "TEXT"]
    - [groq_model, "STRING"]
  return_type:
    - "TABLE(run_id STRING, ai_analysis STRING, total_failures NUMBER, failure_metadata ARRAY)"
  options: |
    COMMENT = $$Gets GitHub Actions failure analysis with configurable AI providers (cortex, claude, groq) for Slack notifications.$$
  sql: |
    WITH failure_data AS (
      SELECT
        run_id,
        COUNT(*) as total_failures,
        ARRAY_AGG(OBJECT_CONSTRUCT(
          'run_id', run_id,
          'job_name', job_name,
          'job_id', job_id,
          'job_url', job_url,
          'error_sections', ARRAY_SIZE(failed_step_logs),
          'logs_preview', SUBSTR(ARRAY_TO_STRING(failed_step_logs, '\n'), 1, 500)
        )) as failure_metadata,
        LISTAGG(
          CONCAT(
            'Job: ', job_name, '\n',
            'Job ID: ', job_id, '\n',
            'Run ID: ', run_id, '\n',
            'Error: ', ARRAY_TO_STRING(failed_step_logs, '\n')
          ),
          '\n\n---\n\n'
        ) WITHIN GROUP (ORDER BY job_name) as job_details
      FROM TABLE({{ schema_name -}}.tf_failed_jobs_with_logs(owner, repo, run_id))
      GROUP BY run_id
    )
    SELECT
      run_id::STRING,
      CASE
        WHEN LOWER(COALESCE(ai_provider, 'cortex')) = 'cortex' THEN
          snowflake.cortex.complete(
            'mistral-large',
            CONCAT(
              'Analyze these ', total_failures, ' GitHub Actions failures for run ', run_id, ' and provide:\n',
              '1. Common failure patterns\n',
              '2. Root cause analysis\n',
              '3. Prioritized action items\n\n',
              job_details
            )
          )
        WHEN LOWER(ai_provider) = 'claude' THEN
          (
            SELECT COALESCE(
              response:content[0]:text::STRING,
              response:error:message::STRING,
              'Claude analysis failed'
            )
            FROM (
              SELECT claude.post_messages(
                ARRAY_CONSTRUCT(
                  OBJECT_CONSTRUCT(
                    'role', 'user',
                    'content', CONCAT(
                      'Analyze these ', total_failures, ' GitHub Actions failures for run ', run_id, ' and provide:\n',
                      '1. Common failure patterns\n',
                      '2. Root cause analysis\n',
                      '3. Prioritized action items\n\n',
                      SUBSTR(job_details, 1, 2000)
                    )
                  )
                )
              ) as response
            )
          )
        WHEN LOWER(ai_provider) = 'groq' THEN
          (
            SELECT groq.extract_response_text(
              groq.quick_chat(
                CONCAT(
                  'Analyze these ', total_failures, ' GitHub Actions failures for run ', run_id, ' and provide:\n',
                  '1. Common failure patterns\n',
                  '2. Root cause analysis\n',
                  '3. Prioritized action items\n\n',
                  SUBSTR(job_details, 1, 2000)
                ),
                COALESCE(NULLIF(groq_model, ''), 'llama3-8b-8192')
              )
            )  
          )
        ELSE
          CONCAT('Unsupported AI provider: ', COALESCE(ai_provider, 'null'))
      END as ai_analysis,
      total_failures,
      failure_metadata
    FROM failure_data

- name: {{ schema_name -}}.tf_failure_analysis_with_ai
  signature:
    - [owner, "TEXT"]
    - [repo, "TEXT"]
    - [run_id, "TEXT"]
    - [ai_provider, "TEXT"]
  return_type:
    - "TABLE(run_id STRING, ai_analysis STRING, total_failures NUMBER, failure_metadata ARRAY)"
  options: |
    COMMENT = $$Gets GitHub Actions failure analysis with configurable AI providers (cortex, claude, groq) for Slack notifications. Uses default groq model.$$
  sql: |
    SELECT * FROM TABLE({{ schema_name -}}.tf_failure_analysis_with_ai(owner, repo, run_id, ai_provider, ''))

{% endmacro %}
