-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_nftscan_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}