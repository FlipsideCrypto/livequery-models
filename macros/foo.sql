{% macro my_id() %}
{{ print("output: " ~ invocation_id) }}
{% endmacro %}