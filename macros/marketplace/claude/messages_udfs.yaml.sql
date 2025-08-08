{% macro config_claude_messages_udfs(schema_name = "claude", utils_schema_name = "claude_utils") -%}
{#
    This macro is used to generate API calls to Claude API endpoints
 #}

{# Claude API Messages #}
- name: {{ schema_name -}}.post_messages
  signature:
    - [MESSAGES, ARRAY, Array of message objects]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Send a message to Claude and get a response [API docs: Messages](https://docs.anthropic.com/claude/reference/messages_post)$$
  sql: |
    SELECT claude_utils.post_api(
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
    - [MESSAGES, ARRAY, Array of message objects]
    - [MAX_TOKENS, INTEGER, Maximum number of tokens to generate]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Send a message to Claude and get a response [API docs: Messages](https://docs.anthropic.com/claude/reference/messages_post)$$
  sql: |
    SELECT claude_utils.post_api(
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
    - [MESSAGES, ARRAY, Array of message objects]
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
    SELECT claude_utils.post_api(
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
    - [MESSAGES, ARRAY, Array of message objects]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Count tokens in a message array before sending to Claude [API docs: Count Tokens](https://docs.anthropic.com/claude/reference/counting-tokens)$$
  sql: |
    SELECT claude_utils.post_api(
        '/v1/messages/count_tokens',
        {
            'model': COALESCE(MODEL, 'claude-3-5-sonnet-20241022'),
            'messages': MESSAGES
        }
    ) as response

{% endmacro %}
