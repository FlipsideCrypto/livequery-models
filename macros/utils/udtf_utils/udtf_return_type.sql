{# Macro to determine which columns to include based on feature flags #}
{% macro generate_udtf_return_type(blockchain, columns) %}

    {# Set Global Variables #}
    {% set GLOBAL_PROD_DB_NAME = blockchain %}

    {# Columns included by default, with specific exclusions #}
    {% set excludes_eip_1559 = ['CORE','RONIN'] %}
    {% set excludes_base_fee = ['CORE'] %}
    {% set excludes_total_difficulty = ['INK','SWELL'] %}

    {# Columns excluded by default, with explicit inclusion #}
    {% set includes_l1_columns = ['INK', 'MANTLE', 'SWELL'] %}
    {% set includes_l1_tx_fee_calc = ['INK', 'MANTLE', 'SWELL'] %}
    {% set includes_eth_value = ['MANTLE'] %}
    {% set includes_mint = ['INK', 'MANTLE', 'SWELL'] %}
    {% set includes_y_parity = ['INK', 'SWELL'] %}
    {% set includes_access_list = ['INK', 'SWELL'] %}
    {% set includes_source_hash = ['INK','MANTLE','SWELL'] %}
    {% set includes_blob_base_fee = ['INK','SWELL'] %}
    {% set includes_mix_hash = ['INK', 'MANTLE', 'SWELL', 'RONIN'] %}
    {% set includes_blob_gas_used = ['INK', 'SWELL'] %}
    {% set includes_parent_beacon_block_root = ['INK', 'SWELL'] %}
    {% set includes_withdrawals = ['INK', 'SWELL'] %}

    {# Set Variables using inclusions and exclusions #}
    {% set current_db = blockchain.upper() %}

    {# Transaction feature flags #}
    {% set uses_eip_1559 = current_db not in excludes_eip_1559 %}
    {% set uses_l1_columns = current_db in includes_l1_columns %}
    {% set uses_l1_tx_fee_calc = current_db in includes_l1_tx_fee_calc %}
    {% set uses_eth_value = current_db in includes_eth_value %}
    {% set uses_mint = current_db in includes_mint %}
    {% set uses_y_parity = current_db in includes_y_parity %}
    {% set uses_access_list = current_db in includes_access_list %}
    {% set uses_source_hash = current_db in includes_source_hash %}
    {% set uses_blob_base_fee = current_db in includes_blob_base_fee %}
    {% set uses_traces_arb_mode = var('TRACES_ARB_MODE', false) %}

    {# Block feature flags #}
    {% set uses_base_fee = current_db not in excludes_base_fee %}
    {% set uses_total_difficulty = current_db not in excludes_total_difficulty %}
    {% set uses_mix_hash = current_db in includes_mix_hash %}
    {% set uses_blob_gas_used = current_db in includes_blob_gas_used %}
    {% set uses_parent_beacon_block_root = current_db in includes_parent_beacon_block_root %}
    {% set uses_withdrawals = current_db in includes_withdrawals %}

    TABLE(
        {% for col in columns %}
            {% if col.flag is not defined
               or (col.flag == 'uses_eip_1559' and uses_eip_1559)
               or (col.flag == 'uses_l1_columns' and uses_l1_columns)
               or (col.flag == 'uses_eth_value' and uses_eth_value)
               or (col.flag == 'uses_mint' and uses_mint)
               or (col.flag == 'uses_y_parity' and uses_y_parity)
               or (col.flag == 'uses_access_list' and uses_access_list)
               or (col.flag == 'uses_source_hash' and uses_source_hash)
               or (col.flag == 'uses_blob_base_fee' and uses_blob_base_fee)
               or (col.flag == 'uses_traces_arb_mode' and uses_traces_arb_mode)
               or (col.flag == 'uses_mix_hash' and uses_mix_hash)
               or (col.flag == 'uses_base_fee' and uses_base_fee)
               or (col.flag == 'uses_total_difficulty' and uses_total_difficulty)
               or (col.flag == 'uses_blob_gas_used' and uses_blob_gas_used)
               or (col.flag == 'uses_parent_beacon_block_root' and uses_parent_beacon_block_root)
               or (col.flag == 'uses_withdrawals' and uses_withdrawals)
            %}
                {{ col.name }} {{ col.type }}{% if not loop.last %},{% endif %}
            {% endif %}
        {% endfor %}
    )
{% endmacro %}
