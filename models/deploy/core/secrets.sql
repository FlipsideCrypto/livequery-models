-- depends_on: {{ ref('_utils') }}
-- depends_on: {{ ref('live') }}
{% set config = config_core_secrets %}
{{ ephemeral_deploy_core(config) }}