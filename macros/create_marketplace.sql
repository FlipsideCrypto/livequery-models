{% macro create_marketplace(drop_=False) %}
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