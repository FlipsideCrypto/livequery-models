-- depends_on: {{ ref('live__') }}
{%- set configs = [
    config_footprint_tokens_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
-- depends_on: {{ ref('footprint_utils__footprint_utils') }}
