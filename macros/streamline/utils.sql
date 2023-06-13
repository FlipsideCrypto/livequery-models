{% macro sql_rpc_call(method, params, blockchain, network) %}
    SELECT
        live.udf_api(
            '{endpoint}'
            ,utils.udf_json_rpc_call('{{ method}}', {{ params }})
            ,concat_ws('/', 'integration', _utils.udf_provider(), '{{ blockchain }}', {{ network }})
        )::VARIANT:data::OBJECT
{% endmacro %}