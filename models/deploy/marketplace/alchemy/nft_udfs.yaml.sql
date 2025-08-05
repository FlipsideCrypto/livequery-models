{% macro config_alchemy_nfts_udfs(schema_name = "alchemy_nfts", utils_schema_name = "alchemy_utils") -%}
{#
    This macro is used to generate the alchemy nft endpoints
 #}

- name: {{ schema_name -}}.get_nfts
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Gets all NFTs currently owned by a given address. [Alchemy docs here](https://docs.alchemy.com/reference/getnfts).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'getNFTs') | trim }}

- name: {{ schema_name -}}.get_owners_for_token
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Get the owner(s) for a token. [Alchemy docs here](https://docs.alchemy.com/reference/getownersfortoken).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'getOwnersForToken') | trim }}

- name: {{ schema_name -}}.get_owners_for_collection
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Gets all owners for a given NFT contract. [Alchemy docs here](https://docs.alchemy.com/reference/getownersforcollection).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'getOwnersForCollection') | trim }}

- name: {{ schema_name -}}.is_holder_of_collection
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Checks whether a wallet holds a NFT in a given collection. [Alchemy docs here](https://docs.alchemy.com/reference/isholderofcollection).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'isHolderOfCollection') | trim }}

- name: {{ schema_name -}}.get_contracts_for_owner
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Gets all NFT contracts held by an owner address. [Alchemy docs here](https://docs.alchemy.com/reference/getcontractsforowner).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'getContractsForOwner') | trim }}

- name: {{ schema_name -}}.get_nft_metadata
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Gets the metadata associated with a given NFT. [Alchemy docs here](https://docs.alchemy.com/reference/getnftmetadata).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'getNFTMetadata') | trim }}

- name: {{ schema_name -}}.get_nft_metadata_batch
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [BODY, OBJECT, JSON Body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Gets the metadata associated with up to 100 given NFT contracts. [Alchemy docs here](https://docs.alchemy.com/reference/getnftmetadatabatch).$$
  sql: {{ alchemy_nft_post_api_call(utils_schema_name, 'getNFTMetadataBatch') | trim }}

- name: {{ schema_name -}}.get_contract_metadata
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Queries NFT high-level collection/contract level information. [Alchemy docs here](https://docs.alchemy.com/reference/getcontractmetadata).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'getContractMetadata') | trim }}

- name: {{ schema_name -}}.get_contract_metadata_batch
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [BODY, OBJECT, JSON Body]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Gets the metadata associated with the given list of contract addresses. [Alchemy docs here](https://docs.alchemy.com/reference/getcontractmetadatabatch).$$
  sql: {{ alchemy_nft_post_api_call(utils_schema_name, 'getContractMetadataBatch') | trim }}

- name: {{ schema_name -}}.invalidate_contract
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Marks all cached tokens for the particular contract as stale. So the next time the endpoint is queried it fetches live data instead of fetching from cache. [Alchemy docs here](https://docs.alchemy.com/reference/invalidatecontract).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'invalidateContract') | trim }}

- name: {{ schema_name -}}.reingest_contract
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Triggers metadata refresh for an entire NFT collection and refreshes stale metadata after a collection reveal/collection changes. [Alchemy docs here](https://docs.alchemy.com/reference/reingestcontract).$$
  sql: {{ alchemy_nft_get_api_call_version(utils_schema_name, 'invalidateContract', 'v3') | trim }}

- name: {{ schema_name -}}.search_contract_metadata
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Search for a keyword across metadata of all ERC-721 and ERC-1155 smart contracts. [Alchemy docs here](https://docs.alchemy.com/reference/searchcontractmetadata).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'searchContractMetadata') | trim }}

- name: {{ schema_name -}}.get_nfts_for_collection
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Gets all NFTs for a given NFT contract. [Alchemy docs here](https://docs.alchemy.com/reference/getnftsforcollection).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'getNFTsForCollection') | trim }}

- name: {{ schema_name -}}.get_spam_contracts
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns a list of all spam contracts marked by Alchemy. [Alchemy docs here](https://docs.alchemy.com/reference/getspamcontracts).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'getSpamContracts') | trim }}

- name: {{ schema_name -}}.is_spam_contract
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns whether a contract is marked as spam or not by Alchemy. [Alchemy docs here](https://docs.alchemy.com/reference/isspamcontract).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'isSpamContract') | trim }}

- name: {{ schema_name -}}.is_airdrop
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns whether a token is marked as an airdrop or not. Airdrops are defined as NFTs that were minted to a user address in a transaction sent by a different address. [Alchemy docs here](https://docs.alchemy.com/reference/isairdrop).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'isAirdrop') | trim }}

- name: {{ schema_name -}}.report_spam
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Report a particular address to our APIs if you think it is spam. [Alchemy docs here](https://docs.alchemy.com/reference/reportspam).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'reportSpam') | trim }}

- name: {{ schema_name -}}.get_floor_price
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the floor prices of a NFT collection by marketplace. [Alchemy docs here](https://docs.alchemy.com/reference/getfloorprice).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'getFloorPrice') | trim }}

- name: {{ schema_name -}}.get_nft_sales
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Gets NFT sales that have happened through on-chain marketplaces. [Alchemy docs here](https://docs.alchemy.com/reference/getnftsales).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'getNFTSales') | trim }}

- name: {{ schema_name -}}.compute_rarity
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Computes the rarity of each attribute of an NFT. [Alchemy docs here](https://docs.alchemy.com/reference/computerarity).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'computeRarity') | trim }}

- name: {{ schema_name -}}.summarize_nft_attributes
  signature:
    - [NETWORK, STRING, The blockchain/network]
    - [QUERY_ARGS, OBJECT, The query arguments]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Generate a summary of attribute prevalence for an NFT collection. [Alchemy docs here](https://docs.alchemy.com/reference/summarizenftattributes).$$
  sql: {{ alchemy_nft_get_api_call(utils_schema_name, 'summarizeNFTAttributes') | trim }}

{% endmacro %}
