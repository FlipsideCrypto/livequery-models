-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_strangelove_udfs
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}