-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_solscan_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}