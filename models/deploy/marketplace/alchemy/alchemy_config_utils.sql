{% macro alchemy_nft_get_api_call(schema_name, api_path) %}
SELECT {{ schema_name -}}.nfts_get(NETWORK, '/{{api_path}}', QUERY_ARGS) as response
{% endmacro %}

{% macro alchemy_nft_get_api_call_version(schema_name, api_path, version) %}
SELECT {{ schema_name -}}.nfts_get(NETWORK, '{{version}}', '/{{api_path}}', QUERY_ARGS) as response
{% endmacro %}

{% macro alchemy_nft_post_api_call(schema_name, api_path) %}
SELECT {{ schema_name -}}.nfts_post(NETWORK, '/{{api_path}}', BODY) as response
{% endmacro %}

{% macro alchemy_rpc_call(schema_name, method) %}
SELECT {{ schema_name -}}.rpc(NETWORK, '{{method}}', PARAMS) as response
{% endmacro %}
