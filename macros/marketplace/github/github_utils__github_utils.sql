-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_github_utils_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
