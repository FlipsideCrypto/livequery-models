{% macro base_test_udf(model, udf, args, expected, filter) %}
{% if execute %}
    {% set sql %}
      SET LIVEQUERY_CONTEXT = '{"userId":"c400f64b-1e5d-4539-bb28-7c57d2bf63df"}';
    {% endset %}
  {% do run_query(sql) %}
{% endif %}
,
tests AS
(
    SELECT
        '{{ udf }}' AS test_name
        ,[{{ args }}] as parameters
        ,{{ udf }}({{args}}){{ filter}} AS actual
        ,{{ expected }} AS expected
        ,COALESCE(NOT actual = {{ expected }}, TRUE) AS failed
)
SELECT *
FROM tests
WHERE FAILED = TRUE
{%- endmacro -%}
