-- depends_on: {{ ref('live__') }}
{%- set configs = [
    config_alchemy_nfts_udfs,
    ] -%}
{{- ephemeral_deploy(configs) -}}
-- depends_on: {{ ref('alchemy_utils__') }}
