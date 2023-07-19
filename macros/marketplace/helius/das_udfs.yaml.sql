{% macro config_helius_das_udfs(schema_name = "helius_das", utils_schema_name = "helius_utils") -%}
{#
    This macro is used to generate the Helius DAS endpoints
 #}

- name: {{ schema_name -}}.get_asset
  signature:
    - [NETWORK, STRING, mainnet or devnet]
    - [PARAMS, OBJECT, The RPC Params argument]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Get an asset by its ID. [Helius docs here](https://docs.helius.xyz/solana-compression/digital-asset-standard-das-api/get-asset).$$
  sql: {{ helius_rpc_call(utils_schema_name, 'getAsset') | trim }}

- name: {{ schema_name -}}.get_signatures_for_asset
  signature:
    - [NETWORK, STRING, mainnet or devnet]
    - [PARAMS, OBJECT, The RPC Params argument]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Get a list of transaction signatures related to a compressed asset. [Helius docs here](https://docs.helius.xyz/solana-compression/digital-asset-standard-das-api/get-signatures-for-asset).$$
  sql: {{ helius_rpc_call(utils_schema_name, 'getSignaturesForAsset') | trim }}

- name: {{ schema_name -}}.search_assets
  signature:
    - [NETWORK, STRING, mainnet or devnet]
    - [PARAMS, OBJECT, The RPC Params argument]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Search for assets by a variety of parameters. [Helius docs here](https://docs.helius.xyz/solana-compression/digital-asset-standard-das-api/search-assets).$$
  sql: {{ helius_rpc_call(utils_schema_name, 'searchAssets') | trim }}

- name: {{ schema_name -}}.get_asset_proof
  signature:
    - [NETWORK, STRING, mainnet or devnet]
    - [PARAMS, OBJECT, The RPC Params argument]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Get a merkle proof for a compressed asset by its ID. [Helius docs here](https://docs.helius.xyz/solana-compression/digital-asset-standard-das-api/get-asset-proof).$$
  sql: {{ helius_rpc_call(utils_schema_name, 'getAssetProof') | trim }}

- name: {{ schema_name -}}.get_assets_by_owner
  signature:
    - [NETWORK, STRING, mainnet or devnet]
    - [PARAMS, OBJECT, The RPC Params argument]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Get a list of assets owned by an address. [Helius docs here](https://docs.helius.xyz/solana-compression/digital-asset-standard-das-api/get-assets-by-owner).$$
  sql: {{ helius_rpc_call(utils_schema_name, 'getAssetsByOwner') | trim }}

- name: {{ schema_name -}}.get_assets_by_authority
  signature:
    - [NETWORK, STRING, mainnet or devnet]
    - [PARAMS, OBJECT, The RPC Params argument]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Get a list of assets with a specific authority. [Helius docs here](https://docs.helius.xyz/solana-compression/digital-asset-standard-das-api/get-assets-by-authority).$$
  sql: {{ helius_rpc_call(utils_schema_name, 'getAssetsByAuthority') | trim }}

- name: {{ schema_name -}}.get_assets_by_creator
  signature:
    - [NETWORK, STRING, mainnet or devnet]
    - [PARAMS, OBJECT, The RPC Params argument]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Get a list of assets created by an address. [Helius docs here](https://docs.helius.xyz/solana-compression/digital-asset-standard-das-api/get-assets-by-creator).$$
  sql: {{ helius_rpc_call(utils_schema_name, 'getAssetsByCreator') | trim }}

- name: {{ schema_name -}}.get_assets_by_group
  signature:
    - [NETWORK, STRING, mainnet or devnet]
    - [PARAMS, OBJECT, The RPC Params argument]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Get a list of assets by a group key and value. [Helius docs here](https://docs.helius.xyz/solana-compression/digital-asset-standard-das-api/get-assets-by-group).$$
  sql: {{ helius_rpc_call(utils_schema_name, 'getAssetsByCreator') | trim }}

{% endmacro %}