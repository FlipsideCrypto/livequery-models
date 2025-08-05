-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_transpose_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}