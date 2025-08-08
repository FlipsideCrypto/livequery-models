{% macro config_claude_messages_batch_udfs(schema_name = "claude", utils_schema_name = "claude_utils") -%}
{#
    This macro is used to generate API calls to Claude API endpoints
 #}

{# Claude API Messages Batch #}
- name: {{ schema_name -}}.post_messages_batch
  signature:
    - [MESSAGES, OBJECT, Object of array of message objects]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Send a batch of messages to Claude and get responses [API docs: Messages Batch](https://docs.anthropic.com/en/api/creating-message-batches)$$
  sql: |
    SELECT claude_utils.post_api(
        '/v1/messages/batches',
        MESSAGES
    ) as response

{# Claude API Messages Batch Operations #}
- name: {{ schema_name -}}.get_message_batch
  signature:
    - [MESSAGE_BATCH_ID, STRING, ID of the Message Batch to retrieve]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Retrieve details of a specific Message Batch [API docs: Retrieve Message Batch](https://docs.anthropic.com/en/api/retrieving-message-batches)$$
  sql: |
    SELECT claude_utils.get_api(
        CONCAT('/v1/messages/batches/', MESSAGE_BATCH_ID)
    ) as response

- name: {{ schema_name -}}.get_message_batch_results
  signature:
    - [MESSAGE_BATCH_ID, STRING, ID of the Message Batch to retrieve results for]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Retrieve results of a Message Batch [API docs: Retrieve Message Batch Results](https://docs.anthropic.com/en/api/retrieving-message-batches)$$
  sql: |
    SELECT claude_utils.get_api(
        CONCAT('/v1/messages/batches/', MESSAGE_BATCH_ID, '/results')
    ) as response

- name: {{ schema_name -}}.list_message_batches
  signature: []
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List all Message Batches [API docs: List Message Batches](https://docs.anthropic.com/en/api/retrieving-message-batches)$$
  sql: |
    SELECT claude_utils.get_api(
        '/v1/messages/batches'
    ) as response

- name: {{ schema_name -}}.list_message_batches_with_before
  signature:
    - [BEFORE_ID, STRING, ID of the Message Batch to start listing from]
    - [LIMIT, INTEGER, Maximum number of Message Batches to return]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List all Message Batches [API docs: List Message Batches](https://docs.anthropic.com/en/api/retrieving-message-batches)$$
  sql: |
    SELECT claude_utils.get_api(
        CONCAT('/v1/messages/batches',
            '?before_id=', COALESCE(BEFORE_ID, ''),
            '&limit=', COALESCE(LIMIT::STRING, '')
        )
    ) as response

- name: {{ schema_name -}}.list_message_batches_with_after
  signature:
    - [AFTER_ID, STRING, ID of the Message Batch to start listing from]
    - [LIMIT, INTEGER, Maximum number of Message Batches to return]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List all Message Batches [API docs: List Message Batches](https://docs.anthropic.com/en/api/retrieving-message-batches)$$
  sql: |
    SELECT claude_utils.get_api(
        CONCAT('/v1/messages/batches',
            '?after_id=', COALESCE(AFTER_ID, ''),
            '&limit=', COALESCE(LIMIT::STRING, '')
        )
    ) as response
- name: {{ schema_name -}}.cancel_message_batch
  signature:
    - [MESSAGE_BATCH_ID, STRING, ID of the Message Batch to cancel]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Cancel a Message Batch [API docs: Cancel Message Batch](https://docs.anthropic.com/en/api/retrieving-message-batches)$$
  sql: |
    SELECT claude_utils.post_api(
        CONCAT('/v1/messages/batches/', MESSAGE_BATCH_ID, '/cancel'),
        {}
    ) as response

- name: {{ schema_name -}}.delete_message_batch
  signature:
    - [MESSAGE_BATCH_ID, STRING, ID of the Message Batch to delete]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Delete a Message Batch [API docs: Delete Message Batch](https://docs.anthropic.com/en/api/retrieving-message-batches)$$
  sql: |
    SELECT claude_utils.delete_method(
        CONCAT('/v1/messages/batches/', MESSAGE_BATCH_ID)
    ) as response

{% endmacro %}
