{% macro config_slack_utils_udfs(schema_name = "slack_utils", utils_schema_name = "slack_utils") -%}
{#
    This macro is used to generate API calls to Slack API endpoints
 #}
- name: {{ schema_name }}.post_webhook
  signature:
    - [WEBHOOK_SECRET_NAME, STRING, "Name of webhook secret in vault (e.g., 'alerts', 'notifications')"]
    - [PAYLOAD, OBJECT, Complete Slack message payload according to Slack API spec]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$Send a message to Slack via webhook. User provides secret name for webhook URL stored in vault.$$
  sql: |
    SELECT CASE
      WHEN WEBHOOK_SECRET_NAME IS NULL OR WEBHOOK_SECRET_NAME = '' THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'webhook_secret_name is required')
      WHEN PAYLOAD IS NULL THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'payload is required')
      ELSE
        live.udf_api_v2(
          'POST',
          '{WEBHOOK_URL}',
          OBJECT_CONSTRUCT('Content-Type', 'application/json'),
          PAYLOAD,
          IFF(_utils.udf_whoami() <> CURRENT_USER(),
              '_FSC_SYS/SLACK/' || WEBHOOK_SECRET_NAME,
              'Vault/prod/data_platform/slack/' || WEBHOOK_SECRET_NAME),
          TRUE
        )
    END as response

- name: {{ schema_name }}.post_message
  signature:
    - [CHANNEL, STRING, "Slack channel ID (e.g. 'C1234567890')"]
    - [PAYLOAD, OBJECT, Message payload according to Slack chat.postMessage API spec]
    - [BOT_SECRET_NAME, STRING, "Name of bot token secret in vault (optional, default: 'intelligence')"]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$Send a message to Slack via Web API chat.postMessage with custom bot token. User provides complete payload according to Slack API spec.$$
  sql: |
    SELECT CASE
      WHEN CHANNEL IS NULL OR CHANNEL = '' THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'channel is required')
      WHEN PAYLOAD IS NULL THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'payload is required')
      ELSE
        live.udf_api_v2(
          'POST',
          'https://slack.com/api/chat.postMessage',
          OBJECT_CONSTRUCT(
            'Authorization', 'Bearer {BOT_TOKEN}',
            'Content-Type', 'application/json'
          ),
          OBJECT_INSERT(PAYLOAD, 'channel', CHANNEL),
          IFF(_utils.udf_whoami() <> CURRENT_USER(),
              '_FSC_SYS/SLACK/' || COALESCE(BOT_SECRET_NAME, 'intelligence'),
              'Vault/prod/data_platform/slack/' || COALESCE(BOT_SECRET_NAME, 'intelligence')),
          TRUE
        )
    END as response

- name: {{ schema_name }}.post_message
  signature:
    - [CHANNEL, STRING, "Slack channel ID (e.g. 'C1234567890')"]
    - [PAYLOAD, OBJECT, Message payload according to Slack chat.postMessage API spec]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$Send a message to Slack via Web API chat.postMessage. User provides complete payload according to Slack API spec.$$
  sql: |
    SELECT {{ schema_name }}.post_message(
        CHANNEL,
        PAYLOAD,
        'intelligence'
    ) as response

- name: {{ schema_name }}.post_reply
  signature:
    - [CHANNEL, STRING, "Slack channel ID (e.g. 'C1234567890')"]
    - [THREAD_TS, STRING, Parent message timestamp for threading]
    - [PAYLOAD, OBJECT, Message payload according to Slack chat.postMessage API spec]
    - [BOT_SECRET_NAME, STRING, "Name of bot token secret in vault (optional, default: 'intelligence')"]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$Send a threaded reply to Slack via Web API with custom bot token. User provides complete payload according to Slack API spec.$$
  sql: |
    SELECT CASE
      WHEN CHANNEL IS NULL OR CHANNEL = '' THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'channel is required')
      WHEN THREAD_TS IS NULL OR THREAD_TS = '' THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'thread_ts is required')
      WHEN PAYLOAD IS NULL THEN
        OBJECT_CONSTRUCT('ok', false, 'error', 'payload is required')
      ELSE
        live.udf_api_v2(
          'POST',
          'https://slack.com/api/chat.postMessage',
          OBJECT_CONSTRUCT(
            'Authorization', 'Bearer {BOT_TOKEN}',
            'Content-Type', 'application/json'
          ),
          OBJECT_INSERT(
            OBJECT_INSERT(PAYLOAD, 'channel', CHANNEL),
            'thread_ts', THREAD_TS
          ),
          IFF(_utils.udf_whoami() <> CURRENT_USER(),
              '_FSC_SYS/SLACK/' || COALESCE(BOT_SECRET_NAME, 'intelligence'),
              'Vault/prod/data_platform/slack/' || COALESCE(BOT_SECRET_NAME, 'intelligence')),
          TRUE
        )
    END as response

- name: {{ schema_name }}.post_reply
  signature:
    - [CHANNEL, STRING, "Slack channel ID (e.g. 'C1234567890')"]
    - [THREAD_TS, STRING, Parent message timestamp for threading]
    - [PAYLOAD, OBJECT, Message payload according to Slack chat.postMessage API spec]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = $$Send a threaded reply to Slack via Web API. User provides complete payload according to Slack API spec.$$
  sql: |
    SELECT {{ schema_name }}.post_reply(
        CHANNEL,
        THREAD_TS,
        PAYLOAD,
        'intelligence'
    ) as response

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
    - [CHANNEL, STRING, "Channel ID to validate"]
  return_type:
    - "BOOLEAN"
  options: |
    COMMENT = $$Validate if a string is a proper Slack channel ID format (API requires IDs, not names).$$
  sql: |
    SELECT CHANNEL IS NOT NULL
       AND LENGTH(CHANNEL) > 0
       AND (
         STARTSWITH(CHANNEL, 'C') OR  -- Public channel ID
         STARTSWITH(CHANNEL, 'D') OR  -- Direct message ID
         STARTSWITH(CHANNEL, 'G')     -- Private channel/group ID
       )

{% endmacro %}
