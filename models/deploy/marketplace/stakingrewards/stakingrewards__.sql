-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_stakingrewards_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}