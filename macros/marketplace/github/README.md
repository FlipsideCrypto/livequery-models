# GitHub Actions Integration for Livequery

A comprehensive GitHub Actions integration that provides both scalar functions (UDFs) and table functions (UDTFs) for interacting with GitHub's REST API. Monitor workflows, retrieve logs, trigger dispatches, and analyze CI/CD data directly from your data warehouse.

## Prerequisites & Setup

### Authentication Setup

The integration uses GitHub Personal Access Tokens (PAT) or GitHub App tokens for authentication.

#### Option 1: Personal Access Token (Recommended for Development)

1. Go to [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select required scopes:
   - `repo` - Full control of private repositories
   - `actions:read` - Read access to Actions (minimum required)
   - `actions:write` - Write access to Actions (for triggering workflows)
   - `workflow` - Update GitHub Action workflows (for enable/disable)
4. Copy the generated token
5. Store securely in your secrets management system

#### Option 2: GitHub App (Recommended for Production)

1. Create a GitHub App in your organization settings
2. Grant required permissions:
   - **Actions**: Read & Write
   - **Contents**: Read
   - **Metadata**: Read
3. Install the app on repositories you want to access
4. Use the app's installation token

### Environment Setup

The integration automatically handles authentication through Livequery's secrets management:

- **System users**: Uses `_FSC_SYS/GITHUB` secret path
- **Regular users**: Uses `vault/github/api` secret path

## Quick Start

### 1. List Repository Workflows

```sql
-- Get all workflows for a repository
SELECT * FROM TABLE(
    github_actions.tf_workflows('your-org', 'your-repo')
);

-- Or as JSON object
SELECT github_actions.workflows('your-org', 'your-repo') as workflows_data;
```

### 2. Monitor Workflow Runs

```sql
-- Get recent workflow runs with status filtering
SELECT * FROM TABLE(
    github_actions.tf_runs('your-org', 'your-repo', {'status': 'completed', 'per_page': 10})
);

-- Get runs for a specific workflow
SELECT * FROM TABLE(
    github_actions.tf_workflow_runs('your-org', 'your-repo', 'ci.yml')
);
```

### 3. Analyze Failed Jobs

```sql
-- Get failed jobs with complete logs for troubleshooting
SELECT
    job_name,
    job_conclusion,
    job_url,
    logs
FROM TABLE(
    github_actions.tf_failed_jobs_with_logs('your-org', 'your-repo', '12345678')
);
```

### 4. Trigger Workflow Dispatch

```sql
-- Trigger a workflow manually
SELECT github_actions.workflow_dispatches(
    'your-org',
    'your-repo',
    'deploy.yml',
    {
        'ref': 'main',
        'inputs': {
            'environment': 'staging',
            'debug': 'true'
        }
    }
) as dispatch_result;
```

## Function Reference

### Utility Functions (`github_utils` schema)

#### `github_utils.octocat()`
Test GitHub API connectivity and authentication.
```sql
SELECT github_utils.octocat();
-- Returns: GitHub API response with Octocat ASCII art
```

#### `github_utils.headers()`
Get properly formatted GitHub API headers.
```sql
SELECT github_utils.headers();
-- Returns: '{"Authorization": "Bearer {TOKEN}", ...}'
```

#### `github_utils.get_api(route, query)`
Make GET requests to GitHub API.
```sql
SELECT github_utils.get_api('repos/your-org/your-repo', {'per_page': 10});
```

#### `github_utils.post_api(route, data)`
Make POST requests to GitHub API.
```sql
SELECT github_utils.post_api('repos/your-org/your-repo/issues', {
    'title': 'New Issue',
    'body': 'Issue description'
});
```

#### `github_utils.put_api(route, data)`
Make PUT requests to GitHub API.
```sql
SELECT github_utils.put_api('repos/your-org/your-repo/actions/workflows/ci.yml/enable', {});
```

### Workflow Functions (`github_actions` schema)

#### Scalar Functions (Return JSON Objects)

##### `github_actions.workflows(owner, repo[, query])`
List repository workflows.
```sql
-- Basic usage
SELECT github_actions.workflows('FlipsideCrypto', 'admin-models');

-- With query parameters
SELECT github_actions.workflows('FlipsideCrypto', 'admin-models', {'per_page': 50});
```

##### `github_actions.runs(owner, repo[, query])`
List workflow runs for a repository.
```sql
-- Get recent runs
SELECT github_actions.runs('your-org', 'your-repo');

-- Filter by status and branch
SELECT github_actions.runs('your-org', 'your-repo', {
    'status': 'completed',
    'branch': 'main',
    'per_page': 20
});
```

##### `github_actions.workflow_runs(owner, repo, workflow_id[, query])`
List runs for a specific workflow.
```sql
-- Get runs for CI workflow
SELECT github_actions.workflow_runs('your-org', 'your-repo', 'ci.yml');

-- With filtering
SELECT github_actions.workflow_runs('your-org', 'your-repo', 'ci.yml', {
    'status': 'failure',
    'per_page': 10
});
```

##### `github_actions.workflow_dispatches(owner, repo, workflow_id[, body])`
Trigger a workflow dispatch event.
```sql
-- Simple dispatch (uses main branch)
SELECT github_actions.workflow_dispatches('your-org', 'your-repo', 'deploy.yml');

-- With custom inputs
SELECT github_actions.workflow_dispatches('your-org', 'your-repo', 'deploy.yml', {
    'ref': 'develop',
    'inputs': {
        'environment': 'staging',
        'version': '1.2.3'
    }
});
```

##### `github_actions.workflow_enable(owner, repo, workflow_id)`
Enable a workflow.
```sql
SELECT github_actions.workflow_enable('your-org', 'your-repo', 'ci.yml');
```

##### `github_actions.workflow_disable(owner, repo, workflow_id)`
Disable a workflow.
```sql
SELECT github_actions.workflow_disable('your-org', 'your-repo', 'ci.yml');
```

##### `github_actions.workflow_run_logs(owner, repo, run_id)`
Get download URL for workflow run logs.
```sql
SELECT github_actions.workflow_run_logs('your-org', 'your-repo', '12345678');
```

##### `github_actions.job_logs(owner, repo, job_id)`
Get plain text logs for a specific job.
```sql
SELECT github_actions.job_logs('your-org', 'your-repo', '87654321');
```

##### `github_actions.workflow_run_jobs(owner, repo, run_id[, query])`
List jobs for a workflow run.
```sql
-- Get all jobs
SELECT github_actions.workflow_run_jobs('your-org', 'your-repo', '12345678');

-- Filter to latest attempt only
SELECT github_actions.workflow_run_jobs('your-org', 'your-repo', '12345678', {
    'filter': 'latest'
});
```

#### Table Functions (Return Structured Data)

##### `github_actions.tf_workflows(owner, repo[, query])`
List workflows as structured table data.
```sql
SELECT
    id,
    name,
    path,
    state,
    created_at,
    updated_at,
    badge_url,
    html_url
FROM TABLE(github_actions.tf_workflows('your-org', 'your-repo'));
```

##### `github_actions.tf_runs(owner, repo[, query])`
List workflow runs as structured table data.
```sql
SELECT
    id,
    name,
    status,
    conclusion,
    head_branch,
    head_sha,
    run_number,
    event,
    created_at,
    updated_at,
    html_url
FROM TABLE(github_actions.tf_runs('your-org', 'your-repo', {'per_page': 20}));
```

##### `github_actions.tf_workflow_runs(owner, repo, workflow_id[, query])`
List runs for a specific workflow as structured table data.
```sql
SELECT
    id,
    name,
    status,
    conclusion,
    run_number,
    head_branch,
    created_at,
    html_url
FROM TABLE(github_actions.tf_workflow_runs('your-org', 'your-repo', 'ci.yml'));
```

##### `github_actions.tf_workflow_run_jobs(owner, repo, run_id[, query])`
List jobs for a workflow run as structured table data.
```sql
SELECT
    id,
    name,
    status,
    conclusion,
    started_at,
    completed_at,
    runner_name,
    runner_group_name,
    html_url
FROM TABLE(github_actions.tf_workflow_run_jobs('your-org', 'your-repo', '12345678'));
```

##### `github_actions.tf_failed_jobs_with_logs(owner, repo, run_id)`
Get failed jobs with their complete logs for analysis.
```sql
SELECT
    job_id,
    job_name,
    job_status,
    job_conclusion,
    job_url,
    failed_steps,
    logs
FROM TABLE(github_actions.tf_failed_jobs_with_logs('your-org', 'your-repo', '12345678'));
```

## Advanced Usage Examples

### CI/CD Monitoring Dashboard

```sql
-- Recent workflow runs with failure rate
WITH recent_runs AS (
    SELECT
        name,
        status,
        conclusion,
        head_branch,
        created_at,
        html_url
    FROM TABLE(github_actions.tf_runs('your-org', 'your-repo', {'per_page': 100}))
    WHERE created_at >= CURRENT_DATE - 7
)
SELECT
    name,
    COUNT(*) as total_runs,
    COUNT(CASE WHEN conclusion = 'success' THEN 1 END) as successful_runs,
    COUNT(CASE WHEN conclusion = 'failure' THEN 1 END) as failed_runs,
    ROUND(COUNT(CASE WHEN conclusion = 'failure' THEN 1 END) * 100.0 / COUNT(*), 2) as failure_rate_pct
FROM recent_runs
GROUP BY name
ORDER BY failure_rate_pct DESC;
```

### Failed Job Analysis

#### Multi-Run Failure Analysis
```sql
-- Analyze failures across multiple runs
WITH failed_jobs AS (
    SELECT
        r.id as run_id,
        r.name as workflow_name,
        r.head_branch,
        r.created_at as run_created_at,
        j.job_name,
        j.job_conclusion,
        j.logs
    FROM TABLE(github_actions.tf_runs('your-org', 'your-repo', {'status': 'completed'})) r
    CROSS JOIN TABLE(github_actions.tf_failed_jobs_with_logs('your-org', 'your-repo', r.id::TEXT)) j
    WHERE r.conclusion = 'failure'
    AND r.created_at >= CURRENT_DATE - 3
)
SELECT
    workflow_name,
    job_name,
    COUNT(*) as failure_count,
    ARRAY_AGG(DISTINCT head_branch) as affected_branches,
    ARRAY_AGG(logs LIMIT 3) as sample_logs
FROM failed_jobs
GROUP BY workflow_name, job_name
ORDER BY failure_count DESC;
```

#### Specific Job Log Analysis
```sql
-- Get detailed logs for a specific failed job
WITH specific_job AS (
    SELECT
        id as job_id,
        name as job_name,
        status,
        conclusion,
        started_at,
        completed_at,
        html_url,
        steps
    FROM TABLE(github_actions.tf_workflow_run_jobs('your-org', 'your-repo', '12345678'))
    WHERE name = 'Build and Test'  -- Specify the job name you want to analyze
    AND conclusion = 'failure'
)
SELECT
    job_id,
    job_name,
    status,
    conclusion,
    started_at,
    completed_at,
    html_url,
    steps,
    github_actions.job_logs('your-org', 'your-repo', job_id::TEXT) as full_logs
FROM specific_job;
```

#### From Workflow ID to Failed Logs
```sql
-- Complete workflow: Workflow ID → Run ID → Failed Logs
WITH latest_failed_run AS (
    -- Step 1: Get the most recent failed run for your workflow
    SELECT 
        id as run_id,
        name as workflow_name,
        status,
        conclusion,
        head_branch,
        head_sha,
        created_at,
        html_url as run_url
    FROM TABLE(github_actions.tf_workflow_runs('your-org', 'your-repo', 'ci.yml'))  -- Your workflow ID here
    WHERE conclusion = 'failure'
    ORDER BY created_at DESC
    LIMIT 1
),
failed_jobs_with_logs AS (
    -- Step 2: Get all failed jobs and their logs for that run
    SELECT 
        r.run_id,
        r.workflow_name,
        r.head_branch,
        r.head_sha,
        r.created_at,
        r.run_url,
        j.job_id,
        j.job_name,
        j.job_status,
        j.job_conclusion,
        j.job_url,
        j.failed_steps,
        j.logs
    FROM latest_failed_run r
    CROSS JOIN TABLE(github_actions.tf_failed_jobs_with_logs('your-org', 'your-repo', r.run_id::TEXT)) j
)
SELECT 
    run_id,
    workflow_name,
    head_branch,
    created_at,
    run_url,
    job_name,
    job_url,
    -- Extract key error information from logs
    CASE 
        WHEN CONTAINS(logs, 'npm ERR!') THEN 'NPM Error'
        WHEN CONTAINS(logs, 'fatal:') THEN 'Git Error'
        WHEN CONTAINS(logs, 'Error: Process completed with exit code') THEN 'Process Exit Error'
        WHEN CONTAINS(logs, 'timeout') THEN 'Timeout Error'
        ELSE 'Other Error'
    END as error_type,
    -- Get first error line from logs
    REGEXP_SUBSTR(logs, '.*Error[^\\n]*', 1, 1) as first_error_line,
    -- Full logs for detailed analysis
    logs as full_logs
FROM failed_jobs_with_logs
ORDER BY job_name;
```

#### Quick Workflow ID to Run ID Lookup
```sql
-- Simple: Just get run IDs for a specific workflow
SELECT 
    id as run_id,
    status,
    conclusion,
    head_branch,
    created_at,
    html_url
FROM TABLE(github_actions.tf_workflow_runs('your-org', 'your-repo', 'ci.yml'))  -- Replace with your workflow ID
WHERE conclusion = 'failure'
ORDER BY created_at DESC
LIMIT 5;
```

#### Failed Steps Deep Dive
```sql
-- Analyze failed steps within jobs and extract error patterns
WITH job_details AS (
    SELECT
        id as job_id,
        name as job_name,
        conclusion,
        steps,
        github_actions.job_logs('your-org', 'your-repo', id::TEXT) as logs
    FROM TABLE(github_actions.tf_workflow_run_jobs('your-org', 'your-repo', '12345678'))
    WHERE conclusion = 'failure'
),
failed_steps AS (
    SELECT
        job_id,
        job_name,
        step.value:name::STRING as step_name,
        step.value:conclusion::STRING as step_conclusion,
        step.value:number::INTEGER as step_number,
        logs
    FROM job_details,
    LATERAL FLATTEN(input => steps:steps) step
    WHERE step.value:conclusion::STRING = 'failure'
)
SELECT
    job_name,
    step_name,
    step_number,
    step_conclusion,
    -- Extract error messages from logs (first 1000 chars)
    SUBSTR(logs, GREATEST(1, CHARINDEX('Error:', logs) - 50), 1000) as error_context,
    -- Extract common error patterns
    CASE
        WHEN CONTAINS(logs, 'npm ERR!') THEN 'NPM Error'
        WHEN CONTAINS(logs, 'fatal:') THEN 'Git Error'
        WHEN CONTAINS(logs, 'Error: Process completed with exit code') THEN 'Process Exit Error'
        WHEN CONTAINS(logs, 'timeout') THEN 'Timeout Error'
        WHEN CONTAINS(logs, 'permission denied') THEN 'Permission Error'
        ELSE 'Other Error'
    END as error_category
FROM failed_steps
ORDER BY job_name, step_number;
```

### Workflow Performance Metrics

```sql
-- Average workflow duration by branch
SELECT
    head_branch,
    AVG(DATEDIFF(second, run_started_at, updated_at)) as avg_duration_seconds,
    COUNT(*) as run_count,
    COUNT(CASE WHEN conclusion = 'success' THEN 1 END) as success_count
FROM TABLE(github_actions.tf_runs('your-org', 'your-repo', {'per_page': 200}))
WHERE run_started_at IS NOT NULL
    AND updated_at IS NOT NULL
    AND status = 'completed'
    AND created_at >= CURRENT_DATE - 30
GROUP BY head_branch
ORDER BY avg_duration_seconds DESC;
```

### Automated Workflow Management

```sql
-- Conditionally trigger deployment based on main branch success
WITH latest_main_run AS (
    SELECT
        id,
        conclusion,
        head_sha,
        created_at
    FROM TABLE(github_actions.tf_runs('your-org', 'your-repo', {
        'branch': 'main',
        'per_page': 1
    }))
    ORDER BY created_at DESC
    LIMIT 1
)
SELECT
    CASE
        WHEN conclusion = 'success' THEN
            github_actions.workflow_dispatches('your-org', 'your-repo', 'deploy.yml', {
                'ref': 'main',
                'inputs': {'sha': head_sha}
            })
        ELSE
            OBJECT_CONSTRUCT('skipped', true, 'reason', 'main branch tests failed')
    END as deployment_result
FROM latest_main_run;
```

## Error Handling

All functions return structured responses with error information:

```sql
-- Check for API errors
WITH api_response AS (
    SELECT github_actions.workflows('invalid-org', 'invalid-repo') as response
)
SELECT
    response:status_code as status_code,
    response:error as error_message,
    response:data as data
FROM api_response;
```

Common HTTP status codes:
- **200**: Success
- **401**: Unauthorized (check token permissions)
- **403**: Forbidden (check repository access)
- **404**: Not found (check org/repo/workflow names)
- **422**: Validation failed (check input parameters)

## Rate Limiting

GitHub API has rate limits:
- **Personal tokens**: 5,000 requests per hour
- **GitHub App tokens**: 5,000 requests per hour per installation
- **Search API**: 30 requests per minute

The functions automatically handle rate limiting through Livequery's retry mechanisms.

## Security Best Practices

1. **Use minimal permissions**: Only grant necessary scopes to tokens
2. **Rotate tokens regularly**: Set expiration dates and rotate tokens
3. **Use GitHub Apps for production**: More secure than personal access tokens
4. **Monitor usage**: Track API calls to avoid rate limits
5. **Secure storage**: Use proper secrets management for tokens

## Troubleshooting

### Common Issues

**Authentication Errors (401)**
```sql
-- Test authentication
SELECT github_utils.octocat();
-- Should return status_code = 200 if token is valid
```

**Permission Errors (403)**
- Ensure token has required scopes (`actions:read` minimum)
- Check if repository is accessible to the token owner
- For private repos, ensure `repo` scope is granted

**Workflow Not Found (404)**
```sql
-- List available workflows first
SELECT * FROM TABLE(github_actions.tf_workflows('your-org', 'your-repo'));
```

**Rate Limiting (403 with rate limit message)**
- Implement request spacing in your queries
- Use pagination parameters to reduce request frequency
- Monitor your rate limit status

### Performance Tips

1. **Use table functions for analytics**: More efficient for large datasets
2. **Implement pagination**: Use `per_page` parameter to control response size
3. **Cache results**: Store frequently accessed data in tables
4. **Filter at API level**: Use query parameters instead of SQL WHERE clauses
5. **Batch operations**: Combine multiple API calls where possible

## GitHub API Documentation

- [GitHub REST API](https://docs.github.com/en/rest) - Complete API reference
- [Actions API](https://docs.github.com/en/rest/actions) - Actions-specific endpoints
- [Authentication](https://docs.github.com/en/rest/overview/authenticating-to-the-rest-api) - Token setup and permissions
- [Rate Limiting](https://docs.github.com/en/rest/overview/rate-limits-for-the-rest-api) - API limits and best practices

## Function Summary

| Function | Type | Purpose |
|----------|------|---------|
| `github_utils.octocat()` | UDF | Test API connectivity |
| `github_utils.get_api/post_api/put_api()` | UDF | Generic API requests |
| `github_actions.workflows()` | UDF | List workflows (JSON) |
| `github_actions.runs()` | UDF | List runs (JSON) |
| `github_actions.workflow_runs()` | UDF | List workflow runs (JSON) |
| `github_actions.workflow_dispatches()` | UDF | Trigger workflows |
| `github_actions.workflow_enable/disable()` | UDF | Control workflow state |
| `github_actions.*_logs()` | UDF | Retrieve logs |
| `github_actions.tf_*()` | UDTF | Structured table data |
| `github_actions.tf_failed_jobs_with_logs()` | UDTF | Failed job analysis |

Ready to monitor and automate your GitHub Actions workflows directly from your data warehouse!
