{% macro create_udfs(drop_=False) %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {% set sql %}
        CREATE schema if NOT EXISTS silver;
        CREATE schema if NOT EXISTS streamline;
        CREATE schema if NOT EXISTS beta;
{{ create_or_drop_function_from_config((var("UDFS") ["streamline.introspect"]), drop_=drop_) }}
{{ create_or_drop_function_from_config((var("UDFS") ["streamline.whoami"]), drop_=drop_) }}
{{ create_or_drop_function_from_config((var("UDFS") ["streamline.udf_register_secret"]), drop_=drop_) }}
{{ create_or_drop_function_from_config((var("UDFS") ["beta.udf_register_secret"]), drop_=drop_) }}
{{ create_or_drop_function_from_config((var("UDFS") ["streamline.udf_api"]), drop_=drop_) }}
{{ create_or_drop_function_from_config((var("UDFS") ["beta.udf_api"]), drop_=drop_) }}
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}
