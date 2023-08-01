
{% test test_marketplace_udf(model, column_name, args, expected, filter) %}
    {%- set schema = model | replace("__dbt__cte__", "") -%}
    {%- set schema = schema.split("__") | first -%}
    {%- set udf = schema ~ "." ~ column_name -%}

    {{ base_test_udf(model, udf, args, expected, filter) }}
{% endtest %}

{% test test_udf(model, column_name, args, expected, filter) %}
    {%- set schema = model | replace("__dbt__cte__", "") -%}
    {%- set udf = schema ~ "." ~ column_name -%}

    {{ base_test_udf(model, udf, args, expected, filter) }}
{% endtest %}