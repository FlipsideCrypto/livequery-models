-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_deepnftvalue_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}