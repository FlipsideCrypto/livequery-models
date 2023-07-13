{% macro config_all_blockchains_networks() %}
{#
    All schemas for blockchains and networks are defined here.
 #}
{{ config_evm_blockchains_networks() }}
{%- endmacro -%}

{% macro config_evm_blockchains_networks() %}
{#
    All schemas for EVM blockchains and networks are defined here.
    This includes all EVM-compatible chains, such as Ethereum, Polygon, Arbitrum, etc.
 #}
- arbitrum_nova:
  - mainnet
- arbitrum_one:
  - goerli
  - mainnet
- avalanche_c:
  - mainnet
  - testnet
- base:
  - goerli
- bsc:
  - mainnet
  - testnet
- celo:
  - mainnet
- ethereum:
  - goerli
  - mainnet
  - sepolia
- fantom:
  - mainnet
- gnosis:
  - mainnet
- harmony:
  - mainnet
  - testnet
- optimism:
  - goerli
  - mainnet
- polygon:
  - mainnet
  - testnet
- polygon_zkevm:
  - mainnet
  - testnet
{%- endmacro -%}