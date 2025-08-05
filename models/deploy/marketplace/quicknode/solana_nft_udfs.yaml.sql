{% macro config_quicknode_solana_nfts_udfs(schema_name = "quicknode_solana_nfts", utils_schema_name = "quicknode_utils") -%}
{#
    This macro is used to generate the QuickNode Solana NFT endpoints
 #}

- name: {{ schema_name -}}.fetch_nfts
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns aggregated data on NFTs for a given wallet. [QuickNode docs here](https://www.quicknode.com/docs/solana/qn_fetchNFTs).$$
  sql: {{ quicknode_solana_mainnet_rpc_call(utils_schema_name, 'qn_fetchNFTs') | trim }}

- name: {{ schema_name -}}.fetch_nfts_by_creator
  signature:
    - [PARAMS, OBJECT, The RPC Params]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns aggregated data on NFTs that have been created by an address. [QuickNode docs here](https://www.quicknode.com/docs/solana/qn_fetchNFTsByCreator).$$
  sql: {{ quicknode_solana_mainnet_rpc_call(utils_schema_name, 'qn_fetchNFTsByCreator') | trim }}

{% endmacro %}