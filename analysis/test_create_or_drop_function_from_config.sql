{%-  set udfs = fromyaml(config_core_live()) -%}
{% do udfs.extend(fromyaml(config_core__live())) %}
{% do udfs.extend(fromyaml(config_core__utils())) %}
{% do udfs.extend(fromyaml(config_core_utils())) %}

{%- for udf in udfs -%}
{{- create_or_drop_function_from_config(udf, drop_=True) -}}
{{- create_or_drop_function_from_config(udf, drop_=False) -}}
{% endfor %}
