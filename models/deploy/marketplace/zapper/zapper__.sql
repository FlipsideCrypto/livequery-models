-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_zapper_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}