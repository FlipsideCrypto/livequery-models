-- depends_on: {{ ref('_internal__contracts_map') }}
-- depends_on: {{ ref('_internal__abi_map') }}
{%- set configs = [
    config_evm_rpc_primitives,
    config_evm_high_level_abstractions
    ] -%}
{{- ephemeral_deploy(configs) -}}