-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_coingecko_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}