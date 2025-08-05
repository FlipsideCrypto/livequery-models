-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_subquery_udfs
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
