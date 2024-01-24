-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_topshot_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}