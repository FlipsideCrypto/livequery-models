{% macro config_groq_chat_udfs(schema_name = "groq", utils_schema_name = "groq_utils") -%}
{#
    This macro is used to generate API calls to Groq chat completion endpoints
 #}

- name: {{ schema_name -}}.chat_completions
  signature:
    - [MESSAGES, ARRAY, Array of message objects]
    - [MODEL, STRING, The model to use (optional, defaults to llama3-8b-8192)]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Send messages to Groq and get a chat completion response with optional model selection [API docs: Chat Completions](https://console.groq.com/docs/api-reference#chat-completions)$$
  sql: |
    SELECT groq_utils.post_api(
        '/openai/v1/chat/completions',
        {
            'model': COALESCE(MODEL, 'llama3-8b-8192'),
            'messages': MESSAGES,
            'max_tokens': 1024,
            'temperature': 0.1
        }
    ) as response

- name: {{ schema_name -}}.quick_chat
  signature:
    - [USER_MESSAGE, STRING, The user message to send]
    - [MODEL, STRING, The model to use (optional, defaults to llama3-8b-8192)]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Quick single message chat with Groq using optional model selection$$
  sql: |
    SELECT {{ schema_name }}.chat_completions(
        ARRAY_CONSTRUCT(
            OBJECT_CONSTRUCT('role', 'user', 'content', USER_MESSAGE)
        ),
        MODEL
    ) as response

- name: {{ schema_name -}}.extract_response_text
  signature:
    - [GROQ_RESPONSE, VARIANT, The response object from Groq API]
  return_type:
    - "STRING"
  options: |
    COMMENT = $$Extract the text content from a Groq chat completion response$$
  sql: |
    SELECT COALESCE(
      GROQ_RESPONSE:choices[0]:message:content::STRING,
      GROQ_RESPONSE:error:message::STRING,
      'No response available'
    )

{% endmacro %}
