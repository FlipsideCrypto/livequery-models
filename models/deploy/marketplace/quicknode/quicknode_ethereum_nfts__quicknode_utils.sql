-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_quicknode_ethereum_nft_udfs,
    ] -%}
{{- ephemeral_deploy(configs) -}}
-- depends_on: {{ ref('quicknode_utils__qicknode_utils') }}
