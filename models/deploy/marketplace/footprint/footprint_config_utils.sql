{% macro footprint_get_api_call(schema_name, api_path) %}
SELECT {{ schema_name -}}.get('/{{api_path}}', QUERY_PARAMS) as response
{% endmacro %}

{% macro footprint_post_api_call(schema_name, api_path) %}
SELECT {{ schema_name -}}.post('/{{api_path}}', BODY) as response
{% endmacro %}