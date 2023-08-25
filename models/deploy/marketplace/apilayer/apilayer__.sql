-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_apilayer_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}