{% macro failed_gha_slack_alert() %}

  {# Get parameters from vars #}
  {%- set owner = var('owner') -%}
  {%- set repo = var('repo') -%}
  {%- set run_id = var('run_id') -%}
  {%- set slack_channel = var('slack_channel', none) -%}
  {%- set enable_ai_analysis = var('enable_ai_analysis', true) -%}
  {%- set ai_provider = var('ai_provider', 'cortex') -%}
  {%- set model_name = var('model_name', 'mistral-large') -%}
  {%- set ai_prompt = var('ai_prompt', '') -%}
  {%- set enable_auto_threading = var('enable_auto_threading', false) -%}
  {%- set bot_secret_name = var('bot_secret_name', 'intelligence') -%}
  {%- set webhook_secret_name = var('webhook_secret_name', none) -%}
  {%- set username = var('username', 'GitHub Actions Bot') -%}
  {%- set icon_emoji = var('icon_emoji', ':github:') -%}
  {%- set icon_url = var('icon_url', none) -%}

  {%- set webhook_url = env_var('SLACK_WEBHOOK_URL', '') -%}
  {%- set use_webhook = webhook_url != '' and webhook_secret_name -%}


  {# Check if we have a valid slack channel #}
  {%- if slack_channel -%}
    {{ log("Using bot token method with channel: " ~ slack_channel, true) }}
    {%- set use_webhook = false -%}
  {%- elif not use_webhook -%}
    {{ log("Error: Either SLACK_WEBHOOK_URL with webhook_secret_name or slack_channel must be provided", true) }}
    {{ return("") }}
  {%- endif -%}

  {%- if enable_ai_analysis -%}
    {# Get failure data with AI analysis #}
    {% set failure_query %}
      SELECT
        run_id,
        ai_analysis,
        total_failures,
        failure_metadata
      FROM TABLE(github_actions.tf_failure_analysis_with_ai('{{ owner }}', '{{ repo }}', '{{ run_id }}', '{{ ai_provider }}', '{{ model_name }}', '{{ ai_prompt }}'))
    {% endset %}

    {%- set failure_results = run_query(failure_query) -%}
    {%- set failure_data = failure_results.rows[0] if failure_results.rows else [] -%}

    {%- if failure_data -%}
      {%- set total_failures = failure_data[2] -%}
      {%- set ai_analysis = failure_data[1] -%}
      {%- set failure_metadata = fromjson(failure_data[3]) if failure_data[3] else [] -%}
    {%- else -%}
      {%- set total_failures = 0 -%}
      {%- set ai_analysis = none -%}
      {%- set failure_metadata = [] -%}
    {%- endif -%}
  {%- else -%}
    {# Get basic failure data without AI #}
    {% set basic_query %}
      SELECT
        COUNT(*) as total_failures,
        MAX(workflow_name) as workflow_name,
        ARRAY_AGG(OBJECT_CONSTRUCT(
          'workflow_name', workflow_name,
          'job_name', job_name,
          'job_id', job_id,
          'job_url', job_url,
          'logs_preview', ARRAY_TO_STRING(failed_step_logs, '\n')
        )) as failure_metadata
      FROM TABLE(github_actions.tf_failed_jobs_with_logs('{{ owner }}', '{{ repo }}', '{{ run_id }}'))
    {% endset %}

    {%- set basic_results = run_query(basic_query) -%}
    {%- set basic_data = basic_results.rows[0] if basic_results.rows else [] -%}

    {%- if basic_data -%}
      {%- set total_failures = basic_data[0] -%}
      {%- set ai_analysis = none -%}
      {%- set failure_metadata = fromjson(basic_data[2]) if basic_data[2] else [] -%}
    {%- else -%}
      {%- set total_failures = 0 -%}
      {%- set ai_analysis = none -%}
      {%- set failure_metadata = [] -%}
    {%- endif -%}
  {%- endif -%}

  {# Extract workflow name #}
  {%- set workflow_name = failure_metadata[0].workflow_name if failure_metadata else repo -%}

  {# Build Slack message #}
  {%- if total_failures == 0 -%}
    {# Success message #}
    {%- set message_blocks = [
      {
        'type': 'header',
        'text': {'type': 'plain_text', 'text': '✅ ' ~ workflow_name ~ ' - Success'}
      },
      {
        'type': 'section',
        'fields': [
          {'type': 'mrkdwn', 'text': '*Run ID:* ' ~ run_id},
          {'type': 'mrkdwn', 'text': '*Workflow:* ' ~ workflow_name},
          {'type': 'mrkdwn', 'text': '*Status:* Success'}
        ]
      },
      {
        'type': 'actions',
        'elements': [{
          'type': 'button',
          'text': {'type': 'plain_text', 'text': 'View Workflow'},
          'url': 'https://github.com/' ~ owner ~ '/' ~ repo ~ '/actions/runs/' ~ run_id,
          'style': 'primary'
        }]
      }
    ] -%}

    {%- set message_payload = {
      'text': '✅ GitHub Actions Success: ' ~ repo,
      'attachments': [{
        'color': '#36a64f',
        'blocks': message_blocks
      }]
    } -%}

    {# Add customization for success messages at root level #}
    {%- if username and username != 'none' -%}
      {%- do message_payload.update({'username': username}) -%}
    {%- endif -%}
    {%- if icon_url and icon_url != 'none' and icon_url != '' -%}
      {%- do message_payload.update({'icon_url': icon_url}) -%}
    {%- elif icon_emoji and icon_emoji != 'none' -%}
      {%- do message_payload.update({'icon_emoji': icon_emoji}) -%}
    {%- endif -%}
  {%- else -%}
    {# Failure message #}
    {%- set message_blocks = [
      {
        'type': 'header',
        'text': {'type': 'plain_text', 'text': ':red_circle: ' ~ workflow_name ~ ' - Failed'}
      },
      {
        'type': 'section',
        'fields': [
          {'type': 'mrkdwn', 'text': '*Run ID:* ' ~ run_id},
          {'type': 'mrkdwn', 'text': '*Workflow:* ' ~ workflow_name},
          {'type': 'mrkdwn', 'text': '*Failed Jobs:* ' ~ total_failures}
        ]
      }
    ] -%}

    {# Add AI analysis if available #}
    {%- if enable_ai_analysis and ai_analysis -%}
      {%- do message_blocks.append({
        'type': 'section',
        'text': {
          'type': 'mrkdwn',
          'text': '*🤖 AI Analysis:*\n' ~ ai_analysis[:2900]
        }
      }) -%}
    {%- endif -%}

    {# Add action button #}
    {%- do message_blocks.append({
      'type': 'actions',
      'elements': [{
        'type': 'button',
        'text': {'type': 'plain_text', 'text': 'View Workflow'},
        'url': 'https://github.com/' ~ owner ~ '/' ~ repo ~ '/actions/runs/' ~ run_id,
        'style': 'danger'
      }]
    }) -%}

    {%- set message_payload = {
      'text': '❌ GitHub Actions Failed: ' ~ repo,
      'attachments': [{
        'color': '#d63638',
        'blocks': message_blocks
      }]
    } -%}

    {# Add customization for failure messages at root level #}
    {%- if username and username != 'none' -%}
      {%- do message_payload.update({'username': username}) -%}
    {%- endif -%}
    {%- if icon_url and icon_url != 'none' and icon_url != '' -%}
      {%- do message_payload.update({'icon_url': icon_url}) -%}
    {%- elif icon_emoji and icon_emoji != 'none' -%}
      {%- do message_payload.update({'icon_emoji': icon_emoji}) -%}
    {%- endif -%}
  {%- endif -%}

  {# Send message #}
  {%- if use_webhook -%}
    {% set send_query %}
      SELECT slack_utils.post_webhook('{{ webhook_secret_name }}', PARSE_JSON($${{ message_payload | tojson }}$$)) as result
    {% endset %}
  {%- else -%}
    {% set send_query %}
      SELECT slack.post_message('{{ slack_channel }}', PARSE_JSON($${{ message_payload | tojson }}$$), '{{ bot_secret_name }}') as result
    {% endset %}
  {%- endif -%}

  {%- set result = run_query(send_query) -%}
  {{ log("Main message sent successfully", true) }}

  {# Handle threading for failures #}
  {%- if enable_auto_threading and total_failures > 0 and not use_webhook and slack_channel -%}
    {%- set main_response = fromjson(result.rows[0][0]) -%}
    {%- set main_thread_ts = main_response.data.ts -%}

    {{ log("Starting threading with " ~ failure_metadata|length ~ " jobs", true) }}

    {%- for job_meta in failure_metadata -%}
      {%- set job_name = job_meta.job_name -%}
      {%- set job_url = job_meta.job_url -%}
      {%- set logs_preview = job_meta.logs_preview -%}

      {# Post job summary in thread #}
      {%- set job_summary = {
        'text': 'Job Details: ' ~ job_name,
        'attachments': [{
          'color': '#d63638',
          'blocks': [
            {
              'type': 'section',
              'fields': [
                {'type': 'mrkdwn', 'text': '*Job:* ' ~ job_name},
                {'type': 'mrkdwn', 'text': '*Status:* failure'}
              ]
            },
            {
              'type': 'actions',
              'elements': [{
                'type': 'button',
                'text': {'type': 'plain_text', 'text': 'View Job'},
                'url': job_url,
                'style': 'danger'
              }]
            }
          ]
        }]
      } -%}

      {# Add customization to thread messages #}
      {%- if username and username != 'none' -%}
        {%- do job_summary.update({'username': username}) -%}
      {%- endif -%}
      {%- if icon_url and icon_url != 'none' and icon_url != '' -%}
        {%- do job_summary.update({'icon_url': icon_url}) -%}
      {%- elif icon_emoji and icon_emoji != 'none' -%}
        {%- do job_summary.update({'icon_emoji': icon_emoji}) -%}
      {%- endif -%}

      {% set job_thread_query %}
        SELECT slack.post_reply('{{ slack_channel }}', '{{ main_thread_ts }}', PARSE_JSON($${{ job_summary | tojson }}$$), '{{ bot_secret_name }}') as result
      {% endset %}

      {%- set job_result = run_query(job_thread_query) -%}

      {# Post logs as additional thread replies if available - split long logs #}
      {%- if logs_preview and logs_preview != '' -%}
        {%- set max_chunk_size = 2900 -%}
        {%- set log_chunks = [] -%}
        
        {# Split logs into chunks #}
        {%- for i in range(0, logs_preview|length, max_chunk_size) -%}
          {%- set chunk = logs_preview[i:i+max_chunk_size] -%}
          {%- do log_chunks.append(chunk) -%}
        {%- endfor -%}
        
        {# Send each chunk as a separate thread message #}
        {%- for chunk_idx in range(log_chunks|length) -%}
          {%- set chunk = log_chunks[chunk_idx] -%}
          {%- set chunk_header = '' -%}
          
          {# Add chunk header if multiple chunks #}
          {%- if log_chunks|length > 1 -%}
            {%- set chunk_header = '📋 Logs (' ~ (chunk_idx + 1) ~ '/' ~ log_chunks|length ~ '):\n' -%}
          {%- else -%}
            {%- set chunk_header = '📋 Logs:\n' -%}
          {%- endif -%}
          
          {%- set log_message = {'text': chunk_header ~ '```\n' ~ chunk ~ '\n```'} -%}

          {# Add customization to log thread messages #}
          {%- if username and username != 'none' -%}
            {%- do log_message.update({'username': username}) -%}
          {%- endif -%}
          {%- if icon_url and icon_url != 'none' and icon_url != '' -%}
            {%- do log_message.update({'icon_url': icon_url}) -%}
          {%- elif icon_emoji and icon_emoji != 'none' -%}
            {%- do log_message.update({'icon_emoji': icon_emoji}) -%}
          {%- endif -%}

          {% set log_thread_query %}
            SELECT slack.post_reply('{{ slack_channel }}', '{{ main_thread_ts }}', PARSE_JSON($${{ log_message | tojson }}$$), '{{ bot_secret_name }}') as result
          {% endset %}

          {%- set log_result = run_query(log_thread_query) -%}
        {%- endfor -%}
      {%- endif -%}

      {{ log("Posted thread for job: " ~ job_name, true) }}
    {%- endfor -%}

    {{ log("Threading completed for " ~ failure_metadata|length ~ " jobs", true) }}
  {%- else -%}
    {{ log("Message sent: " ~ result.rows[0][0] if result.rows else "No response", true) }}
  {%- endif -%}

{% endmacro %}
