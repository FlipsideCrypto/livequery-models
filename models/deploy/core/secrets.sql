-- depends_on: {{ ref('_utils') }}
-- depends_on: {{ ref('live') }}
{% if var("ENABLE_SNOWFLAKE_SECRETS") %}
  {% set config = config_core_secrets %}
	{{ ephemeral_deploy_core(config) }}
{% endif %}
