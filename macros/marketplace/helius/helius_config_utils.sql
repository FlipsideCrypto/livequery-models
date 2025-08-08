{% macro helius_rpc_call(schema_name, method) %}
SELECT {{ schema_name -}}.rpc(NETWORK, '{{method}}', PARAMS) as response
{% endmacro %}

{% macro helius_get_call(schema_name, path) %}
SELECT {{ schema_name -}}.get_api(NETWORK, '{{path}}', QUERY_PARAMS) as response
{% endmacro %}

{% macro helius_post_call(schema_name, path) %}
SELECT {{ schema_name -}}.post_api(NETWORK, '{{path}}', BODY) as response
{% endmacro %}