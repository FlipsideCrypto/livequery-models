
{%- set configs = [
    config_opensea_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}