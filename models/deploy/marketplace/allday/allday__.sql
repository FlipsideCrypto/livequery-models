-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_flow_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}