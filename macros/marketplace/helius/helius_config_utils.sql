{% macro helius_rpc_call(schema_name, method) %}
SELECT {{ schema_name -}}.rpc(NETWORK, '{{method}}', PARAMS) as response
{% endmacro %}