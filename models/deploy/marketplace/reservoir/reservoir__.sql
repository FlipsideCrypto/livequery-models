-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_reservoir_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}