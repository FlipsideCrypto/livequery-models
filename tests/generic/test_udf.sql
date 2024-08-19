{% test test_udf(model, column_name, args, assertions, integration_test=false) %}
    {#
        This is a generic test for UDFs.
        The udfs are deployed using ephemeral models, so we need to
        use the ephemeral model name to get the udf name.
    #}

    {% if integration_test %}
        {{ config(tags=["integration_test"]) }}
    {% endif %}

    {%- set schema = model | replace("__dbt__cte__", "") -%}
    {%- set schema = schema.split("__") | first -%}
    {%- set udf = schema ~ "." ~ column_name -%}

    {{ base_test_udf(model, udf, args, assertions) }}
{% endtest %}