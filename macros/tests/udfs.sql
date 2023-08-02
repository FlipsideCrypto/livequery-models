{% macro base_test_udf(model, udf, args, validations) %}
{% if execute %}
    {% set sql %}
      SET LIVEQUERY_CONTEXT = '{"userId":"98d15c30-9fa5-43cd-9c69-3d4c0bb269f5"}';
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
