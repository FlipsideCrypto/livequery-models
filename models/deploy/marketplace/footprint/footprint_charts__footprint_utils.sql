-- depends_on: {{ ref('footprint_utils__') }}
{%- set configs = [
    config_footprint_charts_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
