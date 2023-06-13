{% macro sql_udf_json_rpc_call(use_default_id=True ) %}
    SELECT IFF(method IS NULL or params IS NULL,
              NULL,
              {
                'jsonrpc': '2.0',
                'method': method,
                'params': params
                {% if use_default_id %}
                  , 'id': hash(method, params)::string
                {% else %}
                  , 'id': id
                {% endif %}
              }
              )
{% endmacro %}
