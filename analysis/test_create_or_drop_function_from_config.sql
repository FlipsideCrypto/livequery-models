{%-  set udfs = fromyaml(udf_configs()) -%}
{%- for udf in udfs -%}
{{- create_or_drop_function_from_config(udf, drop_=True) -}}
{{- create_or_drop_function_from_config(udf, drop_=False) -}}
{% endfor %}
