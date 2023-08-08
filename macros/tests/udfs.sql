{% macro base_test_udf(model, udf, args, assertions) %}
{#
  Generates a test for a UDF.
 #}
{% if execute %}
    {%- set context -%}
      SET LIVEQUERY_CONTEXT = '{"userId":"{{ var("STUDIO_TEST_USER_ID") }}"}';
    {%- endset -%}
  {%- do run_query(context) -%}
{%- endif -%}
{%- set call -%}
{{ target.database }}.{{ udf }}({{ args }})
{%- endset -%}
,
test AS
(
    SELECT
        '{{ udf }}' AS test_name
        ,[{{ args }}] as parameters
        ,{{ call }} AS result
)
  {% for assertion in assertions %}
    SELECT
    test_name,
    parameters,
    result,
    $${{ assertion }}$$ AS assertion,
    $${{ context ~ "\n" }}SELECT {{ call ~ "\n" }};$$ AS sql
    FROM test
    WHERE NOT {{ assertion }}
    {%- if not loop.last -%}
    UNION ALL
    {%- endif -%}
  {%- endfor -%}
{%- endmacro -%}
