-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_chainstack_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}