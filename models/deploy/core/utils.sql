 -- depends_on: {{ ref('_utils') }}
 -- depends_on: {{ ref('_external_access')}}
{% set config = config_core_utils %}
{{ ephemeral_deploy_core(config) }}
