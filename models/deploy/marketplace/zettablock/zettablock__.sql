-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_zettablock_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}