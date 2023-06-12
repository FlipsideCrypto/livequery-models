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

            {% set config, blockchain, schema = config_evm_rpc_primitives, "ethereum", "ethereum" %}
            CREATE SCHEMA IF NOT EXISTS {{ schema }};
            {%-  set ethereum_rpc_udfs = fromyaml(config(schema, blockchain)) -%}
            {%- for udf in ethereum_rpc_udfs -%}
                {{- create_or_drop_function_from_config(udf, drop_=drop_) -}}
            {% endfor %}

            {% set config, blockchain, network = config_evm_abstractions, "ethereum", "mainnet" %}
            CREATE SCHEMA IF NOT EXISTS {{ blockchain }}_{{ network }};
            {%-  set udfs = fromyaml(config(blockchain, network)) -%}
            {%- for udf in udfs -%}
                {{- create_or_drop_function_from_config(udf, drop_=drop_) -}}
            {% endfor %}

            {% set config, blockchain, network = config_evm_abstractions, "ethereum", "testnet" %}
            CREATE SCHEMA IF NOT EXISTS {{ blockchain }}_{{ network }};
            {%-  set udfs = fromyaml(config(blockchain, network)) -%}
            {%- for udf in udfs -%}
                {{- create_or_drop_function_from_config(udf, drop_=drop_) -}}
            {% endfor %}
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}
