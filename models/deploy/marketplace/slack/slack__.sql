-- depends_on: {{ ref('live') }}
-- depends_on: {{ ref('slack_utils__slack_utils') }}
{%- set configs = [
    config_slack_messaging_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
