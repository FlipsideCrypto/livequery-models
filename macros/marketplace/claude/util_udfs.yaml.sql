{% macro config_claude_utils_udfs(schema_name = "claude_utils", utils_schema_name = "claude_utils") -%}
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
{% endmacro %}
