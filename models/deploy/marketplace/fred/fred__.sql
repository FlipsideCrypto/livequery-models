
{%- set configs = [
    config_fred_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
