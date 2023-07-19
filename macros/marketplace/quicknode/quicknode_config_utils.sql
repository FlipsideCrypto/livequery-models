{% macro quicknode_ethereum_mainnet_rpc_call(schema_name, method) %}
SELECT {{ schema_name -}}.ethereum_mainnet_rpc('{{method}}', PARAMS) as response
{% endmacro %}

{% macro quicknode_polygon_mainnet_rpc_call(schema_name, method) %}
SELECT {{ schema_name -}}.polygon_mainnet_rpc('{{method}}', PARAMS) as response
{% endmacro %}

{% macro quicknode_solana_mainnet_rpc_call(schema_name, method) %}
SELECT {{ schema_name -}}.solana_mainnet_rpc('{{method}}', PARAMS) as response
{% endmacro %}