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
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "ethereum", "rinkeby", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "ethereum", "ropsten", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "ethereum", "goerli", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "ethereum", "kovan", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "arbitrum_nova", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "arbitrum_one", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "arbitrum_one", "goerli", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "arbitrum_one", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "avalanche_c", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "avalanche_c", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "bsc", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "bsc", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "celo", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "fantom", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "gnosis", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "harmony", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "harmony", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "optimism", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "optimism", "goerli", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "optimism", "kovan", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "polygon", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "polygon", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "polygon_zkevm", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "polygon_zkevm", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_rpc_primitives, "base", "goerli", drop_) -}}

        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "ethereum", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "ethereum", "rinkeby", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "ethereum", "ropsten", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "ethereum", "goerli", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "ethereum", "kovan", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "arbitrum_nova", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "arbitrum_one", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "arbitrum_one", "goerli", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "arbitrum_one", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "avalanche_c", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "avalanche_c", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "bsc", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "bsc", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "celo", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "fantom", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "gnosis", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "harmony", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "harmony", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "optimism", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "optimism", "goerli", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "optimism", "kovan", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "polygon", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "polygon", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "polygon_zkevm", "mainnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "polygon_zkevm", "testnet", drop_) -}}
        {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "base", "goerli", drop_) -}}

        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}
