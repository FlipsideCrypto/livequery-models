{% macro sql_live_rpc_call(method, params, blockchain, network) %}
{#
    Helper macro to call a JSON RPC method on a live node.
 #}
    WITH result as (
        SELECT
            live.udf_api(
                '{endpoint}'
                ,utils.udf_json_rpc_call('{{ method}}', {{ params }})
                ,concat_ws('/', 'integration', _utils.udf_provider(), '{{ blockchain }}', {{ network }})
            )::VARIANT:data AS data
    )
    SELECT
        COALESCE(data:result, {'error':data:error})
    FROM result
{%- endmacro -%}