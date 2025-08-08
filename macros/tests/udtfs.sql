{% macro base_test_udtf(model, udf, args, assertions) %}
{#
  Generates a test for a User-Defined Table Function (UDTF).
  Unlike scalar UDFs, UDTFs return a table of results.
 #}
{%- set call -%}
SELECT * FROM TABLE({{ udf }}({{ args }}))
{%- endset -%}

WITH test AS
(
    SELECT
        '{{ udf }}' AS test_name
        ,[{{ args }}] as parameters
        ,t.*
    FROM TABLE({{ udf }}({{ args }})) t
)

{% for assertion in assertions %}
SELECT
    test_name,
    parameters,
    $${{ assertion }}$$ AS assertion,
    $${{ call }}$$ AS sql
FROM test
WHERE NOT {{ assertion }}
{%- if not loop.last %}
UNION ALL
{%- endif -%}
{%- endfor -%}
{% endmacro %}
