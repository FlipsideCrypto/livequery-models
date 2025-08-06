{% macro config_claude_models_udfs(schema_name = "claude", utils_schema_name = "claude_utils") -%}
{#
    This macro is used to generate API calls to Claude API endpoints
 #}

{# Claude API Models #}
- name: {{ schema_name -}}.list_models
  signature: []
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List available Claude models [API docs: List Models](https://docs.anthropic.com/claude/reference/models_get)$$
  sql: |
    SELECT claude_utils.get_api(
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
    SELECT claude_utils.get_api(
        CONCAT('/v1/models/', MODEL)
    ) as response

{% endmacro %}
