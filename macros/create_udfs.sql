{% macro create_udfs(drop_=False) %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {% set name %}
        {{- reference_models.udf_configs() -}}
        {% endset %}
        {%  set udfs = fromyaml(name) %}
        {% set sql %}
        CREATE schema if NOT EXISTS utils;
        {%- for udf in udfs -%}
        {{- reference_models.create_or_drop_function_from_config(udf, drop_=drop_) -}}
        {% endfor %}
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}
