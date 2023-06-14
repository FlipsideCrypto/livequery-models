{{
  config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = 'signatures_hash',
    merge_update_columns = [],
    )
}}
{% if execute %}
    {% set all_configs = fromyaml(config_evm_high_level_abstractions("ethereum", "mainnet")) -%}
    {% do all_configs.extend(fromyaml(config_evm_rpc_primitives("ethereum", None))) -%}
    {% do all_configs.extend(fromyaml(config_evm_high_level_abstractions("ethereum", "testnet"))) -%}

    {% set results = [] -%}
    {% for f in all_configs -%}
    {% do results.append(dict(name=f["name"], signature=f["signature"], return_type=f["return_type"])) -%}
    {% endfor -%}
    SELECT
    $${{- results | tojson -}}$$ AS signatures,
    md5(signatures) AS signatures_hash,
    sysdate() as signatures_created_at
{% else %}
    SELECT
    null as signatures,
    null as signatures_hash,
    null as signatures_created_at
    from dual limit 0
{% endif %}

