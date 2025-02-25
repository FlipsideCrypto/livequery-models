-- depends_on: {{ ref('_evm__contracts_map') }}
-- depends_on: {{ ref('_evm__abi_map') }}
-- depends_on: {{ ref('_evm__native_symbol_map') }}
-- depends_on: {{ ref('_eth__logs') }}
-- depends_on: {{ ref('_eth__decoded_logs') }}


{%- set configs = [
    config_evm_rpc_primitives,
    config_evm_high_level_abstractions,
    config_eth_high_level_abstractions
    ] -%}
{{- ephemeral_deploy(configs) -}}
