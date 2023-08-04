{% macro base_test_udf(model, udf, args, assertions) %}
{#
  Generates a test for a UDF.
 #}
{% if execute %}
    {% set sql %}
      SET LIVEQUERY_CONTEXT = '{"userId":"{{ var("STUDIO_TEST_USER_ID") }}"}';
    {% endset %}
  {% do run_query(sql) %}
{% endif %}
,
test AS
(
    SELECT
        '{{ udf }}' AS test_name
        ,[{{ args }}] as parameters
        ,{{ target.database}}.{{ udf }}({{args}}) AS result
)
  {% for assertion in assertions %}
    SELECT
    test_name,
    parameters,
    result,
    $${{ assertion }}$$ AS assertion
    FROM test
    WHERE NOT {{ assertion }}
    {%- if not loop.last -%}
    UNION ALL
    {%- endif -%}
  {%- endfor -%}
{%- endmacro -%}
