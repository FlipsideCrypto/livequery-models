 -- depends_on: {{ ref('_utils') }}
{% set config = config_core_udfs %}
{{ ephemeral_deploy_core(config) }}
