{% macro config_slack_utils_udfs(schema_name = "slack_utils", utils_schema_name = "slack_utils") -%}
{#
    This macro is used to generate API calls to Slack API endpoints
#}

- name: {{ schema_name }}.post_webhook
  signature:
    - [WEBHOOK_URL, STRING, Slack webhook URL]
    - [PAYLOAD, OBJECT, Complete Slack message payload according to Slack API spec]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$Send a message to Slack via webhook. User provides complete payload according to Slack webhook API spec.$$
  sql: |
    SELECT CASE 
      WHEN WEBHOOK_URL IS NULL OR WEBHOOK_URL = '' THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'webhook_url is required')
      WHEN NOT STARTSWITH(WEBHOOK_URL, 'https://hooks.slack.com/') THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'Invalid webhook URL format')
      WHEN PAYLOAD IS NULL THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'payload is required')
      ELSE
        live.udf_api(
          'POST',
          WEBHOOK_URL,
          OBJECT_CONSTRUCT('Content-Type', 'application/json'),
          PAYLOAD
        )
    END as response

- name: {{ schema_name }}.post_message
  signature:
    - [BOT_TOKEN, STRING, Slack bot token (xoxb-...)]
    - [CHANNEL, STRING, Slack channel ID or name]
    - [PAYLOAD, OBJECT, Message payload according to Slack chat.postMessage API spec]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$Send a message to Slack via Web API chat.postMessage. User provides complete payload according to Slack API spec.$$
  sql: |
    SELECT CASE 
      WHEN BOT_TOKEN IS NULL OR BOT_TOKEN = '' THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'bot_token is required')
      WHEN NOT STARTSWITH(BOT_TOKEN, 'xoxb-') THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'Invalid bot token format')
      WHEN CHANNEL IS NULL OR CHANNEL = '' THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'channel is required')
      WHEN PAYLOAD IS NULL THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'payload is required')
      ELSE
        live.udf_api(
          'POST',
          'https://slack.com/api/chat.postMessage',
          OBJECT_CONSTRUCT(
            'Authorization', 'Bearer ' || BOT_TOKEN,
            'Content-Type', 'application/json'
          ),
          OBJECT_INSERT(PAYLOAD, 'channel', CHANNEL)
        )
    END as response

- name: {{ schema_name }}.post_reply  
  signature:
    - [BOT_TOKEN, STRING, Slack bot token (xoxb-...)]
    - [CHANNEL, STRING, Slack channel ID or name]
    - [THREAD_TS, STRING, Parent message timestamp for threading]
    - [PAYLOAD, OBJECT, Message payload according to Slack chat.postMessage API spec]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$Send a threaded reply to Slack via Web API. User provides complete payload according to Slack API spec.$$
  sql: |
    SELECT CASE 
      WHEN BOT_TOKEN IS NULL OR BOT_TOKEN = '' THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'bot_token is required')
      WHEN NOT STARTSWITH(BOT_TOKEN, 'xoxb-') THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'Invalid bot token format')
      WHEN CHANNEL IS NULL OR CHANNEL = '' THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'channel is required')
      WHEN THREAD_TS IS NULL OR THREAD_TS = '' THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'thread_ts is required')
      WHEN PAYLOAD IS NULL THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'payload is required')
      ELSE
        live.udf_api(
          'POST',
          'https://slack.com/api/chat.postMessage',
          OBJECT_CONSTRUCT(
            'Authorization', 'Bearer ' || BOT_TOKEN,
            'Content-Type', 'application/json'
          ),
          OBJECT_INSERT(
            OBJECT_INSERT(PAYLOAD, 'channel', CHANNEL),
            'thread_ts', THREAD_TS
          )
        )
    END as response

- name: {{ schema_name }}.validate_webhook_url
  signature:
    - [WEBHOOK_URL, STRING, Webhook URL to validate]
  return_type:
    - "BOOLEAN"
  options: |
    COMMENT = $$Validate if a string is a proper Slack webhook URL format.$$
  sql: |
    SELECT WEBHOOK_URL IS NOT NULL 
       AND STARTSWITH(WEBHOOK_URL, 'https://hooks.slack.com/services/')
       AND LENGTH(WEBHOOK_URL) > 50

- name: {{ schema_name }}.validate_bot_token  
  signature:
    - [BOT_TOKEN, STRING, Bot token to validate]
  return_type:
    - "BOOLEAN"
  options: |
    COMMENT = $$Validate if a string is a proper Slack bot token format.$$
  sql: |
    SELECT BOT_TOKEN IS NOT NULL 
       AND STARTSWITH(BOT_TOKEN, 'xoxb-')
       AND LENGTH(BOT_TOKEN) > 20

- name: {{ schema_name }}.validate_channel
  signature:
    - [CHANNEL, STRING, Channel ID or name to validate]  
  return_type:
    - "BOOLEAN"
  options: |
    COMMENT = $$Validate if a string is a proper Slack channel ID or name format.$$
  sql: |
    SELECT CHANNEL IS NOT NULL 
       AND LENGTH(CHANNEL) > 0
       AND (
         STARTSWITH(CHANNEL, 'C') OR  -- Channel ID
         STARTSWITH(CHANNEL, 'D') OR  -- DM ID
         STARTSWITH(CHANNEL, 'G') OR  -- Group/Private channel ID
         STARTSWITH(CHANNEL, '#')     -- Channel name
       )

{% endmacro %}