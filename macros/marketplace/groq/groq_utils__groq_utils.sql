-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_groq_utils_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
