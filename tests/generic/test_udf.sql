{% test test_udf(model, column_name, args, expected) %}
,
tests AS
(
    SELECT
        '{{ column_name }}' AS test_name
        ,{{ column_name }}({{args}}) AS actual
        ,{{ expected }} AS expected
        ,NOT {{ column_name }}({{args}}) = {{ expected }} AS failed
)
SELECT *
FROM tests
WHERE FAILED = TRUE
{% endtest %}