-- depends_on: {{ ref('live__') }}
{%- set configs = [
    config_dapplooker_charts_udfs
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}