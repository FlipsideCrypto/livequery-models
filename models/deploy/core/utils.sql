 -- depends_on: {{ ref('_utils') }}
{% set config = config_core_utils %}
{{ ephemeral_deploy_core(config) }}
