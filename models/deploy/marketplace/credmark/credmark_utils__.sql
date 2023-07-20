-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_credmark_utils_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
