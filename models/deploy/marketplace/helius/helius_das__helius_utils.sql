-- depends_on: {{ ref('live__') }}
{%- set configs = [
    config_helius_das_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
-- depends_on: {{ ref('helius_utils__helius_utils') }}