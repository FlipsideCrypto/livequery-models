-- depends_on: {{ ref('live__') }}
{%- set configs = [
    config_alchemy_utils_udfs,
    ] -%}
{{- ephemeral_deploy(configs) -}}
