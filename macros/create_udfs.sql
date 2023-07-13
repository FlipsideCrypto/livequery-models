{% macro create_udfs(blockchain=None, network=None, drop_=False) %}
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

        {% set all = config_all_blockchains_networks() %}

        {% for chain, networks in all %}
            {% for network_ in networks %}
                {% set schema_name = chain ~ "_" ~ network %}
                {{- crud_udfs_in_schema(config_evm_rpc_primitives, chain, network_, drop_) -}}
                {{- crud_udfs_in_schema(config_evm_high_level_abstractions, chain, network_, drop_) -}}
            {% endfor %}
        {% endfor %}

    {% endset %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {% do run_query(sql) %}
    {% else %}
        {{ sql }}
    {% endif %}
{% endmacro %}
