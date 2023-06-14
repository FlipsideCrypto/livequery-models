{% macro evm_latest_native_balance(schema) %}
    select 'foo', 'bar', '{{schema}}', 1.0
{% endmacro %}