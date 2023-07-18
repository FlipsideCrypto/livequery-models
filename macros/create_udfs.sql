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

            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "arbitrum_nova", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "arbitrum_one", "goerli", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "arbitrum_one", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "avalanche_c", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "avalanche_c", "testnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "base", "goerli", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "bsc", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "bsc", "testnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "celo", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "ethereum", "goerli", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "ethereum", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "ethereum", "sepolia", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "fantom", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "gnosis", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "harmony", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "harmony", "testnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "optimism", "goerli", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "optimism", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "polygon", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "polygon", "testnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "polygon_zkevm", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_rpc_primitives, "polygon_zkevm", "testnet", drop_) -}}

            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "arbitrum_nova", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "arbitrum_one", "goerli", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "arbitrum_one", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "avalanche_c", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "avalanche_c", "testnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "base", "goerli", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "bsc", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "bsc", "testnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "celo", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "ethereum", "goerli", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "ethereum", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "ethereum", "sepolia", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "fantom", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "gnosis", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "harmony", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "harmony", "testnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "optimism", "goerli", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "optimism", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "polygon", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "polygon", "testnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "polygon_zkevm", "mainnet", drop_) -}}
            {{- crud_udfs_in_schema(config_evm_high_level_abstractions, "polygon_zkevm", "testnet", drop_) -}}

        {% endset %}
        {% do run_query(sql) %}
    {% endif %}

    {% set mp_providers = ({
            "ALCHEMY": ({
                "UTILS": config_alchemy_util_udfs,
                "NFTS": config_alchemy_nft_udfs,
                "TOKENS": config_alchemy_token_udfs,
                "TRANSFERS": config_alchemy_transfers_udfs
            }),
            "BLOCKPOUR": ({
                "UTILS": config_blockpour_util_udfs
            }),
            "CHAINBASE": ({
                "UTILS": config_chainbase_util_udfs
            }),
            "CREDMARK": ({
                "UTILS": config_credmark_util_udfs
            }),
            "FOOTPRINT": ({
                "UTILS": config_footprint_util_udfs,
                "BALANCES": config_footprint_balances_udfs,
                "ADDRESS": config_footprint_address_udfs,
                "NFTS": config_footprint_nft_udfs,
                "TOKENS": config_footprint_token_udfs,
                "GAMEFI": config_footprint_gamefi_udfs,
                "CHAINS": config_footprint_chain_udfs,
                "CHARTS": config_footprint_chart_udfs
            }),
            "QUICKNODE": ({
                "UTILS": config_quicknode_util_udfs,
                "ETHEREUM_NFTS": config_quicknode_ethereum_nft_udfs,
                "ETHEREUM_TOKENS": config_quicknode_ethereum_token_udfs,
                "POLYGON_NFTS": config_quicknode_polygon_nft_udfs,
                "POLYGON_TOKENS": config_quicknode_polygon_token_udfs,
                "SOLANA_NFTS": config_quicknode_solana_nft_udfs
            }),
            "HELIUS": ({
                "UTILS": config_helius_util_udfs,
                "DAS": config_helius_das_udfs
            })
    })%}

    {% if var("UPDATE_MARKETPLACE_UDFS") %}
        {% set sql %}
            {%- for provider_name in mp_providers -%}
                {%- for category in mp_providers[provider_name] -%}
                    CREATE SCHEMA IF NOT EXISTS {{provider_name}}_{{category}};
                {%- endfor -%}
            {%- endfor -%}
        {% endset %}
        {% do run_query(sql) %}

        {% set sql %}
            {%- for provider_name in mp_providers -%}
                {%- for category in mp_providers[provider_name] -%}
                    {% set schema_name = provider_name ~ '_' ~ category %}
                    {% set utils_schema_name = provider_name ~ '_utils' %}
                    {{- crud_marketplace_udfs(mp_providers[provider_name][category], schema_name, utils_schema_name, drop_) -}}
                {%- endfor -%}
            {%- endfor -%}
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}