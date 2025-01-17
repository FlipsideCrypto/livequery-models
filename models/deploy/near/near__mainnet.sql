-- depends_on: {{ ref('near_models','core__fact_blocks') }}
-- depends_on: {{ ref('silver__streamline_blocks') }}

{%- set configs = [
    config_near_high_level_abstractions
    ] -%}

{{- ephemeral_deploy(configs) -}}
