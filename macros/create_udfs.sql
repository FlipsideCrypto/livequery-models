{% macro create_udfs(drop_=False) %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {% set name %}
        {{- udf_configs() -}}
        {% endset %}
        {%  set udfs = fromyaml(name) %}
        {% set sql %}
        CREATE schema if NOT EXISTS silver;
        CREATE schema if NOT EXISTS utils;
        CREATE schema if NOT EXISTS _utils;
        CREATE schema if NOT EXISTS _live;
        CREATE schema if NOT EXISTS live;
        {%- for udf in udfs -%}
        {{- create_or_drop_function_from_config(udf, drop_=drop_) -}}
        {% endfor %}
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}
