    {% set mp_providers = ({
            "ALCHEMY": ({
                "UTILS": config_alchemy_utils_udfs,
                "NFTS": config_alchemy_nfts_udfs,
                "TOKENS": config_alchemy_tokens_udfs,
                "TRANSFERS": config_alchemy_transfers_udfs
            }),
            "BLOCKPOUR": ({
                "UTILS": config_blockpour_utils_udfs
            }),
            "CHAINBASE": ({
                "UTILS": config_chainbase_utils_udfs
            }),
            "CREDMARK": ({
                "UTILS": config_credmark_utils_udfs
            }),
            "FOOTPRINT": ({
                "UTILS": config_footprint_utils_udfs,
                "BALANCES": config_footprint_balances_udfs,
                "ADDRESS": config_footprint_address_udfs,
                "NFTS": config_footprint_nfts_udfs,
                "TOKENS": config_footprint_tokens_udfs,
                "GAMEFI": config_footprint_gamefi_udfs,
                "CHAINS": config_footprint_chains_udfs,
                "CHARTS": config_footprint_charts_udfs
            })
    })%}

    {{ mp_providers | pprint}}
    {% for p in  mp_providers -%}
        {% for key2, value2 in mp_providers[p]|items %}
            {{ p ~ "__" ~ key2  }}
        {%- endfor %}
    {%- endfor %}