-- depends_on: {{ ref('_utils') }}
-- depends_on: {{ ref('utils') }}
-- depends_on: {{ ref('_live') }}
{% set config = config_core_udfs %}
{{ ephemeral_deploy_core(config) }}