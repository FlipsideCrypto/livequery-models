{% set name %}
  {{- udf_configs() -}}
{% endset %}
{%  set udfs = fromyaml(name) %}

{{- create_or_drop_function_from_config(udfs["streamline.introspect"], drop_=True) -}}
{{- create_or_drop_function_from_config(udfs["streamline.whoami"], drop_=True) -}}
{{- create_or_drop_function_from_config(udfs["streamline.udf_register_secret"], drop_=True) -}}
{{- create_or_drop_function_from_config(udfs["beta.udf_register_secret"], drop_=True) -}}
{{- create_or_drop_function_from_config(udfs["streamline.udf_api"], drop_=True) -}}
{{- create_or_drop_function_from_config(udfs["beta.udf_api"], drop_=True) -}}
{{- create_or_drop_function_from_config(udfs["streamline.introspect"], drop_=False) -}}
{{- create_or_drop_function_from_config(udfs["streamline.whoami"], drop_=False) -}}
{{- create_or_drop_function_from_config(udfs["streamline.udf_register_secret"], drop_=False) -}}
{{- create_or_drop_function_from_config(udfs["beta.udf_register_secret"], drop_=False) -}}
{{- create_or_drop_function_from_config(udfs["streamline.udf_api"], drop_=False) -}}
{{- create_or_drop_function_from_config(udfs["beta.udf_api"], drop_=False) -}}