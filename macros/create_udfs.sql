{% macro create_udfs(drop_=False) %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {% set sql %}
            CREATE SCHEMA IF NOT EXISTS silver;
            CREATE SCHEMA IF NOT EXISTS beta;
            CREATE SCHEMA IF NOT EXISTS utils;
            CREATE SCHEMA IF NOT EXISTS _utils;
            CREATE SCHEMA IF NOT EXISTS _live;
            CREATE SCHEMA IF NOT EXISTS live;
            {%-  set udfs = fromyaml(config_core_udfs()) -%}
            {%- for udf in udfs -%}
                {{- create_or_drop_function_from_config(udf, drop_=drop_) -}}
            {% endfor %}

            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "ethereum", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "ethereum", "testnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "ethereum", "goerli", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "polygon", "mainnet", drop_) -}}

            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "ethereum", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "ethereum", "testnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "ethereum", "goerli", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "polygon", "mainnet", drop_) -}}
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}
