{% macro claude_get_api_call(schema_name, api_path) %}
SELECT {{ schema_name }}.get(
    '{{ api_path }}'
) as response
{% endmacro %}

{% macro claude_post_api_call(schema_name, api_path, body) %}
SELECT {{ schema_name }}.post(
    '{{ api_path }}',
    {{ body }}
) as response
{% endmacro %}

{% macro claude_delete_api_call(schema_name, api_path) %}
SELECT {{ schema_name }}.delete_method(
    '{{ api_path }}'
) as response
{% endmacro %}
