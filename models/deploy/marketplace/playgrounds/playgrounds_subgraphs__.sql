-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_playgrounds_subgraphs_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}