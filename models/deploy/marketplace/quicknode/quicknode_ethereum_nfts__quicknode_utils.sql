-- depends_on: {{ ref('live__') }}
{%- set configs = [
    config_quicknode_ethereum_nft_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
-- depends_on: {{ ref('quicknode_utils__qicknode_utils') }}
