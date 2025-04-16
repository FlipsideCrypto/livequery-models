-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_covalent_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}