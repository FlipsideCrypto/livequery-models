{% macro base_test_udf(model, udf, args, validations) %}
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
        ,{{ udf }}({{args}}) AS result
)
  {% for validation in validations %}
    SELECT
    test_name,
    parameters,
    result,
    $${{ validation }}$$ AS validation
    FROM test
    WHERE NOT {{ validation }}
    {%- if not loop.last -%}
    UNION ALL
    {%- endif -%}
  {%- endfor -%}
{%- endmacro -%}
