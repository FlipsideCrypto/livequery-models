-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_binance_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}