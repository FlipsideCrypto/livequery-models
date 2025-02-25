-- depends_on: {{ ref('_evm__contracts_map') }}
-- depends_on: {{ ref('_evm__abi_map') }}
-- depends_on: {{ ref('_evm__native_symbol_map') }}


{%- set configs = [
    config_evm_rpc_primitives,
    config_evm_high_level_abstractions
    ] -%}
{{- ephemeral_deploy(configs) -}}
