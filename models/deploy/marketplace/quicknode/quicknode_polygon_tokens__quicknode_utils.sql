
{%- set configs = [
    config_quicknode_polygon_tokens_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
-- depends_on: {{ ref('quicknode_utils__quicknode_utils') }}
