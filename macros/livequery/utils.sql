{% macro sql_live_rpc_call(method, params, blockchain, network) %}
{#
    Helper macro to call a JSON RPC method on a live node.

    Parameters:
        method (string): The JSON RPC method to call.
        params (array): The JSON RPC parameters to pass to the method.
        blockchain (string): The blockchain to call the method on.
        network (string): The network to call the method on.
    Returns:
        string: The SQL to call the method.
 #}
    WITH result as (
        SELECT
            live.udf_api(
                '{endpoint}'
                ,utils.udf_json_rpc_call({{ method }}, {{ params }})
                ,concat_ws('/', 'integration', _utils.udf_provider(), '{{ blockchain }}', '{{ network }}')
            )::VARIANT:data AS data
    )
    SELECT
        COALESCE(data:result, {'error':data:error})
    FROM result
{% endmacro -%}

{% macro sql_live_rpc_batch_call(from, calls, blockchain, network) %}
{#
    Helper macro to batch call a JSON RPC method on a live node.

    Parameters:
        calls (array): The JSON RPC parameters to pass to the method.
        blockchain (string): The blockchain to call the method on.
        network (string): The network to call the method on.
    Returns:
        string: The SQL to call the method.
 #}
    WITH result as (
        SELECT
            live.udf_api(
                '{endpoint}'
                ,{{ calls }}
                ,concat_ws('/', 'integration', _utils.udf_provider(), {{ blockchain }}, {{ network }})
            )::VARIANT:data::ARRAY AS data
    )
    SELECT
        COALESCE(value:result, {'error':value:error})
    FROM result, LATERAL FLATTEN(input => result.data) v
{% endmacro -%}