{% macro() %}
    SELECT IFF(method IS NULL or params IS NULL,
              NULL,
              {
                'jsonrpc': '2.0',
                'method': method,
                'params': params,
                'id': id
              }
              )
{% endmacro %}
