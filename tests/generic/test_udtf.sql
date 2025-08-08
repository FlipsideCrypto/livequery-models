{% test test_udtf(model, column_name, args, assertions) %}
    {%- set schema = model | replace("__dbt__cte__", "") -%}
    {%- set schema = schema.split("__") | first -%}
    {%- set udf = schema ~ "." ~ column_name -%}

    WITH base_test_data AS
    (
        SELECT
            '{{ udf }}' AS test_name
            ,[{{ args }}] as parameters
            ,COUNT(*) OVER () AS row_count
        FROM TABLE({{ udf }}({{ args }})) t
        LIMIT 1
    )

    {% for assertion in assertions %}
    SELECT
        test_name,
        parameters,
        $${{ assertion }}$$ AS assertion,
        $$SELECT * FROM TABLE({{ udf }}({{ args }}))$$ AS sql
    FROM base_test_data
    WHERE NOT ({{ assertion }})
    {% if not loop.last %}
    UNION ALL
    {% endif %}
    {% endfor %}
{% endtest %}
