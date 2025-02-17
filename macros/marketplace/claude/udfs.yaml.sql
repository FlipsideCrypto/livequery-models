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
    WITH base_headers AS (
      SELECT CASE
        WHEN PATH LIKE '/v1/messages%' THEN
          {
            'anthropic-version': '2023-06-01',
            'x-api-key': '{API_KEY}',
            'content-type': 'application/json'
          }
        ELSE
          {
            'content-type': 'application/json'
          }
      END as headers
    )
    SELECT live.udf_api(
        'POST',
        CONCAT('https://api.anthropic.com', PATH),
        (SELECT headers FROM base_headers),
        BODY,
        '_FSC_SYS/CLAUDE'
    ) as response
{% endmacro %}
