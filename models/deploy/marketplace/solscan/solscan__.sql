
{%- set configs = [
    config_solscan_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}