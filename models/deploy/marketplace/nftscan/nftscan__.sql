
{%- set configs = [
    config_nftscan_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}