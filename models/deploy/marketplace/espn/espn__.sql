-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_espn_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}