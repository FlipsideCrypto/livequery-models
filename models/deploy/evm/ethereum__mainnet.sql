-- depends_on: {{ ref('_evm__contracts_map') }}
-- depends_on: {{ ref('_evm__abi_map') }}
-- depends_on: {{ ref('_evm__native_symbol_map') }}
-- depends_on: {{ ref('_eth__logs') }}
-- depends_on: {{ ref('_eth__decoded_logs') }}
-- depends_on: {{ ref('live') }}
-- depends_on: {{ ref('utils') }}
-- depends_on: {{ ref('price__ez_prices_hourly') }}
-- depends_on: {{ ref('core__dim_contracts')}}
-- depends_on: {{ ref('bronze__blocks') }}
-- depends_on: {{ ref('bronze__blocks_fr') }}
-- depends_on: {{ ref('bronze__transactions') }}
-- depends_on: {{ ref('bronze__transactions_fr') }}
-- depends_on: {{ ref('bronze__receipts') }}
-- depends_on: {{ ref('bronze__receipts_fr') }}
-- depends_on: {{ ref('bronze__traces') }}
-- depends_on: {{ ref('bronze__traces_fr') }}
-- depends_on: {{ ref('bronze__decoded_logs') }}
-- depends_on: {{ ref('bronze__decoded_logs_fr') }}
-- depends_on: {{ ref('fsc_evm', 'silver__blocks') }}
-- depends_on: {{ ref('fsc_evm', 'silver__transactions') }}
-- depends_on: {{ ref('fsc_evm', 'silver__receipts') }}
-- depends_on: {{ ref('fsc_evm', 'silver__traces') }}
-- depends_on: {{ ref('fsc_evm', 'silver__decoded_logs') }}
-- depends_on: {{ ref('evm__fact_blocks') }}
-- depends_on: {{ ref('evm__fact_transactions') }}
-- depends_on: {{ ref('fsc_evm', 'core__fact_blocks') }}
-- depends_on: {{ ref('fsc_evm', 'core__fact_transactions') }}
-- depends_on: {{ ref('fsc_evm', 'core__fact_event_logs') }}
-- depends_on: {{ ref('fsc_evm', 'core__fact_traces') }}
-- depends_on: {{ ref('fsc_evm', 'core__ez_native_transfers') }}
-- depends_on: {{ ref('fsc_evm', 'core__ez_decoded_event_logs') }}
{%- set configs = [
    config_evm_rpc_primitives,
    config_evm_high_level_abstractions,
    config_eth_high_level_abstractions
    ] -%}
{{- ephemeral_deploy(configs) -}}
