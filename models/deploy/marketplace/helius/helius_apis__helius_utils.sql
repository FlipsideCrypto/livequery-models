
{%- set configs = [
    config_helius_apis_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
-- depends_on: {{ ref('helius_utils__helius_utils') }}
