
{%- set configs = [
    config_playgrounds_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}