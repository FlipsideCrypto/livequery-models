{% macro config_claude_utils_udfs(schema_name = "claude_utils", utils_schema_name = "claude_utils") -%}
{#
    This macro is used to generate API calls to Claude API endpoints
 #}
- name: {{ schema_name -}}.post_api
  signature:
    - [PATH, STRING, The API endpoint path]
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Make calls to Claude API [API docs: Claude](https://docs.anthropic.com/claude/reference/getting-started-with-the-api)$$
  sql: |
    SELECT
    {% set v2_exists = is_udf_api_v2_compatible() %}
    {% if v2_exists -%}
      live.udf_api_v2(
        'POST',
        CONCAT('https://api.anthropic.com', PATH),
        {
            'anthropic-version': '2023-06-01',
            'x-api-key': '{API_KEY}',
            'content-type': 'application/json'
        },
        BODY,
        IFF(_utils.udf_whoami() <> CURRENT_USER(),
              '_FSC_SYS/CLAUDE',
              'Vault/prod/data_platform/claude'
          ),
          TRUE
      )
    {%- else -%}
      live.udf_api(
        'POST',
        CONCAT('https://api.anthropic.com', PATH),
        {
            'anthropic-version': '2023-06-01',
            'x-api-key': '{API_KEY}',
            'content-type': 'application/json'
        },
        BODY,
        IFF(_utils.udf_whoami() <> CURRENT_USER(),
              '_FSC_SYS/CLAUDE',
              'Vault/prod/data_platform/claude'
        )
      )
    {%- endif %}
    as response

- name: {{ schema_name -}}.get_api
  signature:
    - [PATH, STRING, The API endpoint path]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Make GET requests to Claude API [API docs: Get](https://docs.anthropic.com/claude/reference/get)$$
  sql: |
    SELECT
    {% set v2_exists = is_udf_api_v2_compatible() %}
    {% if v2_exists -%}
      live.udf_api_v2(
        'GET',
        CONCAT('https://api.anthropic.com', PATH),
        {
            'anthropic-version': '2023-06-01',
            'x-api-key': '{API_KEY}',
            'content-type': 'application/json'
        },
        NULL,
        IFF(_utils.udf_whoami() <> CURRENT_USER(),
              '_FSC_SYS/CLAUDE',
              'Vault/prod/data_platform/claude'
        ),
        TRUE
      )
    {%- else -%}
      live.udf_api(
        'GET',
        CONCAT('https://api.anthropic.com', PATH),
        {
            'anthropic-version': '2023-06-01',
            'x-api-key': '{API_KEY}',
            'content-type': 'application/json'
        },
        NULL,
        IFF(_utils.udf_whoami() <> CURRENT_USER(),
              '_FSC_SYS/CLAUDE',
              'Vault/prod/data_platform/claude'
        )
      )
    {%- endif %}
    as response

- name: {{ schema_name -}}.delete_method
  signature:
    - [PATH, STRING, The API endpoint path]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Make DELETE requests to Claude API [API docs: Delete](https://docs.anthropic.com/claude/reference/delete)$$
  sql: |
    SELECT
    {% set v2_exists = is_udf_api_v2_compatible() %}
    {% if v2_exists -%}
      live.udf_api_v2(
        'DELETE',
        CONCAT('https://api.anthropic.com', PATH),
        {
            'anthropic-version': '2023-06-01',
            'x-api-key': '{API_KEY}',
            'content-type': 'application/json'
        },
        NULL,
        IFF(_utils.udf_whoami() <> CURRENT_USER(),
              '_FSC_SYS/CLAUDE',
              'Vault/prod/data_platform/claude'
        ),
        TRUE
      )
    {%- else -%}
      live.udf_api(
        'DELETE',
        CONCAT('https://api.anthropic.com', PATH),
        {
            'anthropic-version': '2023-06-01',
            'x-api-key': '{API_KEY}',
            'content-type': 'application/json'
        },
        NULL,
        IFF(_utils.udf_whoami() <> CURRENT_USER(),
              '_FSC_SYS/CLAUDE',
              'Vault/prod/data_platform/claude'
        )
      )
    {%- endif %}
    as response
{% endmacro %}
