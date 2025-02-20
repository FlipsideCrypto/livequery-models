{% macro config_claude_udfs(schema_name = "claude", utils_schema_name = "claude_utils") -%}
{#
    This macro is used to generate API calls to Claude API endpoints
 #}
- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The API endpoint path]
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Make calls to Claude API [API docs: Claude](https://docs.anthropic.com/claude/reference/getting-started-with-the-api)$$
  sql: |
    SELECT live.udf_api(
        'POST',
        CONCAT('https://api.anthropic.com', PATH),
        {
            'anthropic-version': '2023-06-01',
            'x-api-key': '{API_KEY}',
            'content-type': 'application/json'
        },
        BODY,
        '_FSC_SYS/CLAUDE'
    ) as response

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The API endpoint path]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Make GET requests to Claude API [API docs: Get](https://docs.anthropic.com/claude/reference/get)$$
  sql: |
    SELECT live.udf_api(
        'GET',
        CONCAT('https://api.anthropic.com', PATH),
        {
            'anthropic-version': '2023-06-01',
            'x-api-key': '{API_KEY}',
            'content-type': 'application/json'
        },
        NULL,
        '_FSC_SYS/CLAUDE'
    ) as response

- name: {{ schema_name -}}.delete_method
  signature:
    - [PATH, STRING, The API endpoint path]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Make DELETE requests to Claude API [API docs: Delete](https://docs.anthropic.com/claude/reference/delete)$$
  sql: |
    SELECT live.udf_api(
        'DELETE',
        CONCAT('https://api.anthropic.com', PATH),
        {
            'anthropic-version': '2023-06-01',
            'x-api-key': '{API_KEY}',
            'content-type': 'application/json'
        },
        NULL,
        '_FSC_SYS/CLAUDE'
    ) as response

{# Claude API Messages #}
- name: {{ schema_name -}}.post_messages
  signature:
    - [MESSAGES, OBJECT, Object of array of message objects]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Send a message to Claude and get a response [API docs: Messages](https://docs.anthropic.com/claude/reference/messages_post)$$
  sql: |
    SELECT {{ schema_name }}.post(
        '/v1/messages',
        {
            'model': 'claude-3-5-sonnet-20241022',
            'messages': MESSAGES,
            'max_tokens': 4096
        }
    ) as response

- name: {{ schema_name -}}.post_messages
  signature:
    - [MODEL, STRING, The model to use (e.g. 'claude-3-opus-20240229')]
    - [MESSAGES, OBJECT, Object of array of message objects]
    - [MAX_TOKENS, INTEGER, Maximum number of tokens to generate]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Send a message to Claude and get a response [API docs: Messages](https://docs.anthropic.com/claude/reference/messages_post)$$
  sql: |
    SELECT {{ schema_name }}.post(
        '/v1/messages',
        {
            'model': COALESCE(MODEL, 'claude-3-5-sonnet-20241022'),
            'messages': MESSAGES,
            'max_tokens': COALESCE(MAX_TOKENS, 1024)
        }
    ) as response

- name: {{ schema_name -}}.post_messages
  signature:
    - [MODEL, STRING, The model to use (e.g. 'claude-3-opus-20240229')]
    - [MESSAGES, OBJECT, Object of array of message objects]
    - [MAX_TOKENS, INTEGER, Maximum number of tokens to generate]
    - [TEMPERATURE, FLOAT, Temperature for sampling (0-1)]
    - [TOP_K, INTEGER, Top K for sampling]
    - [TOP_P, FLOAT, Top P for sampling]
    - [SYSTEM, STRING, System prompt to use]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Send a message to Claude and get a response [API docs: Messages](https://docs.anthropic.com/claude/reference/messages_post)$$
  sql: |
    SELECT {{ schema_name }}.post(
        '/v1/messages',
        {
            'model': MODEL,
            'messages': MESSAGES,
            'max_tokens': MAX_TOKENS,
            'temperature': TEMPERATURE,
            'top_k': TOP_K,
            'top_p': TOP_P,
            'system': SYSTEM
        }
    ) as response

- name: {{ schema_name -}}.count_message_tokens
  signature:
    - [MODEL, STRING, The model to use (e.g. 'claude-3-5-sonnet-20241022')]
    - [MESSAGES, OBJECT, Object of array of message objects]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Count tokens in a message array before sending to Claude [API docs: Count Tokens](https://docs.anthropic.com/claude/reference/counting-tokens)$$
  sql: |
    SELECT {{ schema_name }}.post(
        '/v1/messages/count_tokens',
        {
            'model': COALESCE(MODEL, 'claude-3-5-sonnet-20241022'),
            'messages': MESSAGES
        }
    ) as response


{# Claude API Models #}
- name: {{ schema_name -}}.list_models
  signature: []
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List available Claude models [API docs: List Models](https://docs.anthropic.com/claude/reference/models_get)$$
  sql: |
    SELECT {{ schema_name }}.get(
        '/v1/models'
    ) as response

- name: {{ schema_name -}}.get_model
  signature:
    - [MODEL, STRING, The model name to get details for (e.g. 'claude-3-opus-20240229')]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Get details for a specific Claude model [API docs: Get Model](https://docs.anthropic.com/claude/reference/models_retrieve)$$
  sql: |
    SELECT {{ schema_name }}.get(
        CONCAT('/v1/models/', MODEL)
    ) as response


{# Claude API Messages Batch #}
- name: {{ schema_name -}}.post_messages_batch
  signature:
    - [MESSAGES, OBJECT, Object of array of message objects]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Send a batch of messages to Claude and get responses [API docs: Messages Batch](https://docs.anthropic.com/en/api/creating-message-batches)$$
  sql: |
    SELECT {{ schema_name }}.post(
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
    SELECT {{ schema_name }}.get(
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
    SELECT {{ schema_name }}.get(
        CONCAT('/v1/messages/batches/', MESSAGE_BATCH_ID, '/results')
    ) as response

- name: {{ schema_name -}}.list_message_batches
  signature: []
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List all Message Batches [API docs: List Message Batches](https://docs.anthropic.com/en/api/retrieving-message-batches)$$
  sql: |
    SELECT {{ schema_name }}.get(
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
    SELECT {{ schema_name }}.get(
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
    SELECT {{ schema_name }}.get(
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
    SELECT {{ schema_name }}.post(
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
    SELECT {{ schema_name }}.delete_method(
        CONCAT('/v1/messages/batches/', MESSAGE_BATCH_ID)
    ) as response

{% endmacro %}
