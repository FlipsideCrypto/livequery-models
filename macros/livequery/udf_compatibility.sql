{% macro get_streamline_stack_version() -%}
{# Determine the environment based on target.name #}
{% if target.name == 'dev' %}
  {% set env = 'stg' %}
{% elif target.name == 'prod' %}
  {% set env = 'prod' %}
{% else %}
  {% set env = 'stg' %}
{% endif %}

{# Extract database prefix if it follows pattern <database_name>_<target_name> #}
{% set database_parts = target.database.split('_') %}
{% if database_parts|length > 1 and database_parts[-1].lower() == target.name.lower() %}
  {% set database_prefix = database_parts[:-1]|join('_') %}
{% else %}
  {% set database_prefix = target.database %}
{% endif %}


{% set streamline_stack_version_query %}
  SELECT
    TAGS:streamline_runtime_version::STRING as runtime_version,
    TAGS:streamline_infrastructure_version::STRING as infrastructure_version
  FROM TABLE(STREAMLINE.AWS.CLOUDFORMATION_DESCRIBE_STACKS('{{ env }}', '{{ database_prefix.lower() }}-api-{{ env }}'));
{% endset %}

{% if execute %}
  {% set result = run_query(streamline_stack_version_query) %}
  {% if result.rows|length > 0 %}
    {% set runtime_version = result.rows[0][0] %}
    {% set infrastructure_version = result.rows[0][1] %}
    {% set streamline_stack_version = {'runtime_version': runtime_version, 'infrastructure_version': infrastructure_version} %}
  {% else %}
    {% set streamline_stack_version = {'runtime_version': false, 'infrastructure_version': false} %}
  {% endif %}
{% else %}
  {% set streamline_stack_version = {'runtime_version': false, 'infrastructure_version': false} %}
{% endif %}

{{ return(streamline_stack_version) }}
{%- endmacro -%}

{% macro is_udf_api_v2_compatible() -%}
{% set versions = get_streamline_stack_version() %}

{% if execute and versions.runtime_version %}
  {# Extract version number from runtime_version string (e.g., "v3.1.2" -> "3.1.2") #}
  {% set version_str = versions.runtime_version.replace('v', '') %}
  {% set version_parts = version_str.split('.') %}

  {# Convert to comparable format: major.minor.patch #}
  {% set major = version_parts[0] | int %}
  {% set minor = version_parts[1] | int if version_parts|length > 1 else 0 %}
  {% set patch = version_parts[2] | int if version_parts|length > 2 else 0 %}

  {# Check if version is >= 3.0.0 #}
  {% set is_compatible = major >= 3 %}
{% else %}
  {% set is_compatible = false %}
{% endif %}

{{ return(is_compatible) }}
{%- endmacro -%}
