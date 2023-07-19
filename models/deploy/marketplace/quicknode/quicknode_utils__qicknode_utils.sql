-- depends_on: {{ ref('live__') }}
{%- set configs = [
    config_quicknode_util_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
