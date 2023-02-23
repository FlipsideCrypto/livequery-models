{%- set name -%}
  {{- udf_configs() -}}
{% endset %}
{%  set udfs = fromyaml(name) %}
{%- for udf in udfs -%}
{{- create_or_drop_function_from_config(udf, drop_=True) -}}
{{- create_or_drop_function_from_config(udf, drop_=False) -}}
{% endfor %}
