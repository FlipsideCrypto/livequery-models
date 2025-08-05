{% macro config_groq_utils_udfs(schema_name = "groq_utils", utils_schema_name = "groq_utils") -%}
{#
    This macro is used to generate API calls to Groq API endpoints
 #}
- name: {{ schema_name -}}.post
  signature:
    - [PATH, STRING, The API endpoint path]
    - [BODY, OBJECT, The request body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Make POST requests to Groq API [API docs: Groq](https://console.groq.com/docs/api-reference)$$
  sql: |
    SELECT live.udf_api(
        'POST',
        CONCAT('https://api.groq.com', PATH),
        {
            'Authorization': 'Bearer {API_KEY}',
            'Content-Type': 'application/json'
        },
        BODY,
        IFF(_utils.udf_whoami() <> CURRENT_USER(), '_FSC_SYS/GROQ', 'Vault/prod/livequery/groq')
    ) as response

- name: {{ schema_name -}}.get
  signature:
    - [PATH, STRING, The API endpoint path]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Make GET requests to Groq API [API docs: Groq](https://console.groq.com/docs/api-reference)$$
  sql: |
    SELECT live.udf_api(
        'GET',
        CONCAT('https://api.groq.com', PATH),
        {
            'Authorization': 'Bearer {API_KEY}',
            'Content-Type': 'application/json'
        },
        NULL,
        IFF(_utils.udf_whoami() <> CURRENT_USER(), '_FSC_SYS/GROQ', 'Vault/prod/livequery/groq')
    ) as response

- name: {{ schema_name -}}.list_models
  signature:
    - []
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$List available models from Groq API$$
  sql: |
    SELECT {{ schema_name }}.get('/openai/v1/models')

- name: {{ schema_name -}}.get_model_info
  signature:
    - [MODEL_ID, STRING, The model ID to get info for]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Get information about a specific model$$
  sql: |
    SELECT {{ schema_name }}.get('/openai/v1/models/' || MODEL_ID)

{% endmacro %}
