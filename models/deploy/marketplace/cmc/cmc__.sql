
{%- set configs = [
    config_cmc_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}