-- depends_on: {{ ref('near_models','core__fact_blocks') }}
-- depends_on: {{ ref('near_models','silver__blocks_final') }}
-- depends_on: {{ ref('near_models','silver__blocks_v2') }}
-- depends_on: {{ ref('livequery_models', 'bronze__blocks') }}
-- depends_on: {{ ref('livequery_models', 'bronze__FR_blocks') }}
{%- set configs = [
    config_near_high_level_abstractions
    ] -%}

{{- ephemeral_deploy(configs) -}}
