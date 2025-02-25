
{%- set configs = [
    config_zapper_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}