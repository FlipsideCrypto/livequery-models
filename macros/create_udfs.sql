{% macro create_udfs(drop_=False) %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {% set sql %}
            CREATE SCHEMA IF NOT EXISTS silver;
            CREATE SCHEMA IF NOT EXISTS beta;
            CREATE SCHEMA IF NOT EXISTS utils;
            CREATE SCHEMA IF NOT EXISTS _utils;
            CREATE SCHEMA IF NOT EXISTS _live;
            CREATE SCHEMA IF NOT EXISTS live;
            {%-  set udfs = fromyaml(udf_configs()) -%}
            {%- for udf in udfs -%}
                {{- create_or_drop_function_from_config(udf, drop_=drop_) -}}
            {% endfor %}

            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "ethereum", None, drop_) -}}

            {# TODO: Add udfs to macros/livequery/evm.yaml.sql then uncomment #}
            {# {{- crud_udfs_in_schema(config_evm_abstractions, "ethereum", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_abstractions, "ethereum", "testnet", drop_) -}} #}
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}
