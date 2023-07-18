-- depends_on: {{ ref('live__') }}
{%- set configs = [
    config_footprint_balances_udfs,
    ] -%}
{{- ephemeral_deploy(configs) -}}
-- depends_on: {{ ref('footprint_utils__') }}
