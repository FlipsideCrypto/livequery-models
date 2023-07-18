-- depends_on: {{ ref('live__') }}
{%- set configs = [
    config_chainbase_utils_udfs,
    ] -%}
{{- ephemeral_deploy(configs) -}}
