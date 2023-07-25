{% test test_udf(model, column_name, args, expected) %}
,
tests as
(
SELECT
'{{ column_name }}' as test_name
,{{ column_name }}({{args}}) as actual
,{{ expected }} as expected
,NOT {{ column_name }}({{args}}) = {{ expected }} as failed
)
select *
from tests
WHERE FAILED = TRUE
{% endtest %}