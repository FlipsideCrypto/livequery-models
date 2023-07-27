{% test test_udf(model, column_name, args, expected) %}
{%- set schema = model | replace("__dbt__cte__", "") -%}
{%- set udf = schema ~ "." ~ column_name -%}
,
tests AS
(
    SELECT
        '{{ udf }}' AS test_name
        ,[{{ args }}] as parameters
        ,{{ udf }}({{args}}) AS actual
        ,{{ expected }} AS expected
        ,NOT {{ udf }}({{args}}) = {{ expected }} AS failed
)
SELECT *
FROM tests
WHERE FAILED = TRUE
{% endtest %}