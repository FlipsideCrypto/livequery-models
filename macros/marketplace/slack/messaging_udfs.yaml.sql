{% macro config_slack_messaging_udfs(schema_name = "slack", utils_schema_name = "slack_utils") -%}
{#
    This macro is used to generate API calls to Slack API endpoints
#}

{# Slack Webhook Messages #}
- name: {{ schema_name }}.webhook_send
  signature:
    - [WEBHOOK_SECRET_NAME, STRING, "Name of webhook secret in vault (e.g., 'alerts', 'notifications')"]
    - [PAYLOAD, OBJECT, Complete Slack message payload according to Slack API spec]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = 'Send a message to Slack via webhook [API docs: Webhooks](https://api.slack.com/messaging/webhooks)'
  sql: |
    SELECT {{ utils_schema_name }}.post_webhook(
        WEBHOOK_SECRET_NAME,
        PAYLOAD
    ) as response

{# Slack Web API Messages #}
- name: {{ schema_name }}.post_message
  signature:
    - [CHANNEL, STRING, Slack channel ID or name]
    - [PAYLOAD, OBJECT, Message payload according to Slack chat.postMessage API spec]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = 'Send a message to Slack via Web API [API docs: chat.postMessage](https://api.slack.com/methods/chat.postMessage)'
  sql: |
    SELECT {{ utils_schema_name }}.post_message(
        CHANNEL,
        PAYLOAD
    ) as response


- name: {{ schema_name }}.post_reply
  signature:
    - [CHANNEL, STRING, Slack channel ID or name]
    - [THREAD_TS, STRING, Parent message timestamp for threading]
    - [PAYLOAD, OBJECT, Message payload according to Slack chat.postMessage API spec]
  return_type:
    - "OBJECT"
  options: |
    COMMENT = 'Send a threaded reply to Slack via Web API [API docs: chat.postMessage](https://api.slack.com/methods/chat.postMessage)'
  sql: |
    SELECT {{ utils_schema_name }}.post_reply(
        CHANNEL,
        THREAD_TS,
        PAYLOAD
    ) as response


{% endmacro %}
