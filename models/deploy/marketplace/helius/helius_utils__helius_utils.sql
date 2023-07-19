-- depends_on: {{ ref('live__') }}
{%- set configs = [
    config_helius_util_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}