{%- set configs = [
    config_near_rpc_primitives,
    config_near_high_level_abstractions
    ] -%}
{{- ephemeral_deploy(configs) -}}
