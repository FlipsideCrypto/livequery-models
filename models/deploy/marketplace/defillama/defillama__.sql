
{%- set configs = [
    config_defillama_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}