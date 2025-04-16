-- depends_on: {{ ref('live') }}
{%- set configs = [
    config_quicknode_ethereum_nfts_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
-- depends_on: {{ ref('quicknode_utils__quicknode_utils') }}
