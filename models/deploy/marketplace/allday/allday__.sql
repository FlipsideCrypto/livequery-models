-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_allday_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}