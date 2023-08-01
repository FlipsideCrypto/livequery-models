-- depends_on: {{ ref('footprint_utils__') }}
{%- set configs = [
    config_footprint_address_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
