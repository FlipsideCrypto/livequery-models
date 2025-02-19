-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_claude_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
