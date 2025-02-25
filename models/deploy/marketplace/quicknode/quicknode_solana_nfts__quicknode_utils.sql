
{%- set configs = [
    config_quicknode_solana_nfts_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
-- depends_on: {{ ref('quicknode_utils__quicknode_utils') }}
