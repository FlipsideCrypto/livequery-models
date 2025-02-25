
{%- set configs = [
    config_bitquery_udfs
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}