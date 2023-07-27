-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_dapplooker_udfs
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}