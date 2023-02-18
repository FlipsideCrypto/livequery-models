{% macro create_udf_introspect(
        drop_ = False
    ) %}
    {% set name_ = 'silver.udf_introspect' %}
    {% set signature = [('json', 'variant')] %}
    {% set return_type = 'text' %}
    {% set sql_ = construct_api_route("introspect") %}
    {% if not drop_ %}
        {{ create_sql_function(
            name_ = name_,
            signature = signature,
            return_type = return_type,
            sql_ = sql_,
            api_integration = var("API_INTEGRATION")
        ) }}
    {% else %}
        {{ drop_function(
            name_,
            signature = signature,
        ) }}
    {% endif %}
{% endmacro %}
