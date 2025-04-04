
{%- set configs = [
    config_claude_messages_udfs,
    config_claude_models_udfs,
    config_claude_messages_batch_udfs
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}
