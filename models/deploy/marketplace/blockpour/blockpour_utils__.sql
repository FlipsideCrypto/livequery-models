-- depends_on: {{ ref('live__') }}
{%- set configs = [
    config_blockpour_utils_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
