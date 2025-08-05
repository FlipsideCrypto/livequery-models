-- depends_on: {{ ref('live') }}
-- depends_on: {{ ref('groq_utils__groq_utils') }}
{%- set configs = [
    config_groq_chat_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
