-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_helius_util_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}