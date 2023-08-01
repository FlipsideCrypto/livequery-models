{% macro base_test_udf(model, udf, args, expected, filter) %}
{% if execute %}
    {% set sql %}
      SET LIVEQUERY_CONTEXT = '{"userId":"98d15c30-9fa5-43cd-9c69-3d4c0bb269f5"}';
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
