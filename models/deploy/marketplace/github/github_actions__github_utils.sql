-- depends_on: {{ ref('live') }}
-- depends_on: {{ ref('github_utils__github_utils') }}
{%- set configs = [
    config_github_actions_udfs,
    config_github_actions_udtfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
