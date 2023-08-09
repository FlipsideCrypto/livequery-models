-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_cmc_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}