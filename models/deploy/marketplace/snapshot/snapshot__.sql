
{%- set configs = [
    config_snapshot_udfs,
    ] -%}
{{- ephemeral_deploy_marketplace(configs) -}}