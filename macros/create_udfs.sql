{% macro create_udfs(drop_=False,schema="utils") %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {% set name %}
        {{- fsc_utils.udf_configs(schema) -}}
        {% endset %}
        {%  set udfs = fromyaml(name) %}
        {% set sql %}
        CREATE schema if NOT EXISTS {{ schema }};
        {%- for udf in udfs -%}
        {{- fsc_utils.create_or_drop_function_from_config(udf, drop_=drop_) -}}
        {% endfor %}
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}
