-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_footprint_utils_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
