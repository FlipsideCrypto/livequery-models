-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_fred_series_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}