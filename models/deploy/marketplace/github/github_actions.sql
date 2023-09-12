-- depends_on: {{ ref('live') }}
-- depends_on: {{ ref('github_utils') }}
{%- set configs = [
    config_github_actions_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
