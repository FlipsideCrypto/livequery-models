{% macro check_udf_api_v2_exists() -%}
{#
    Check if live.udf_api_v2 function exists at compile time
    Returns true/false to control which UDF call to render
    
    Usage:
    {% set v2_exists = check_udf_api_v2_exists() %}
    {% if v2_exists %}
      live.udf_api_v2(...)
    {% else %}
      live.udf_api(...)
    {% endif %}
#}
{% set check_v2_query %}
  SELECT COUNT(*) FROM information_schema.functions 
  WHERE function_name = 'UDF_API_V2' AND function_schema = 'LIVE'
{% endset %}

{% if execute %}
  {% set v2_exists = run_query(check_v2_query).rows[0][0] > 0 %}
{% else %}
  {% set v2_exists = false %}
{% endif %}

{{ return(v2_exists) }}
{%- endmacro -%}