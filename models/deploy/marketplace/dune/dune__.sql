-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_dune_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}