-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_dappradar_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}