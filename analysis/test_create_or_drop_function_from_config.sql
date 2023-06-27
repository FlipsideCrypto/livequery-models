{%-  set udfs = fromyaml(config_core_udfs()) -%}
{%- for udf in udfs -%}
{{- create_or_drop_function_from_config(udf, drop_=True) -}}
{{- create_or_drop_function_from_config(udf, drop_=False) -}}
{% endfor %}
