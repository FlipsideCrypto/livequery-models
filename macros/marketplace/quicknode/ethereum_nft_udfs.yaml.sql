{% macro config_quicknode_ethereum_nft_udfs(schema_name = "quicknode_ethereum_nfts", utils_schema_name = "quicknode_utils") -%}
{#
    This macro is used to generate the QuickNode Ethereum NFT endpoints
 #}

- name: {{ schema_name -}}.fetch_nft_collection_details
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns collection details for specified contracts. [QuickNode docs here](https://www.quicknode.com/docs/ethereum/qn_fetchNFTCollectionDetails_v2).$$
  sql: {{ quicknode_ethereum_mainnet_rpc_call(utils_schema_name, 'qn_fetchNFTCollectionDetails') | trim }}

- name: {{ schema_name -}}.fetch_nfts
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns aggregated data on NFTs for a given wallet. [QuickNode docs here](https://www.quicknode.com/docs/ethereum/qn_fetchNFTs).$$
  sql: {{ quicknode_ethereum_mainnet_rpc_call(utils_schema_name, 'qn_fetchNFTs') | trim }}

- name: {{ schema_name -}}.fetch_nfts_by_collection
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns aggregated data on NFTs within a given collection. [QuickNode docs here](https://www.quicknode.com/docs/ethereum/qn_fetchNFTsByCollection_v2).$$
  sql: {{ quicknode_ethereum_mainnet_rpc_call(utils_schema_name, 'qn_fetchNFTsByCollection') | trim }}

- name: {{ schema_name -}}.get_transfers_by_nft
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns transfers by given NFT. [QuickNode docs here](https://www.quicknode.com/docs/ethereum/qn_getTransfersByNFT_v2).$$
  sql: {{ quicknode_ethereum_mainnet_rpc_call(utils_schema_name, 'qn_getTransfersByNFT') | trim }}

- name: {{ schema_name -}}.verify_nfts_owner
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Confirms ownership of specified NFTs for a given wallet. [QuickNode docs here](https://www.quicknode.com/docs/ethereum/qn_verifyNFTsOwner_v2).$$
  sql: {{ quicknode_ethereum_mainnet_rpc_call(utils_schema_name, 'qn_verifyNFTsOwner') | trim }}
{% endmacro %}