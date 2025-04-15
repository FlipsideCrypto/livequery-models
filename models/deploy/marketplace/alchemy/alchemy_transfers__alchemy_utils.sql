
{%- set configs = [
    config_alchemy_transfers_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
-- depends_on: {{ ref('alchemy_utils__alchemy_utils') }}
-- depends_on: {{ ref('live') }}
