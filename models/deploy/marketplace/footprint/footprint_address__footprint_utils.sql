-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_footprint_address_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
-- depends_on: {{ ref('footprint_utils__footprint_utils') }}
