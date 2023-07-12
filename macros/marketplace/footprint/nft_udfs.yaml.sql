{% macro config_footprint_nft_udfs(schema_name = "footprint_nfts", utils_schema_name = "footprint_utils") -%}
{#
    This macro is used to generate the Footprint nft endpoints
 #}

- name: {{ schema_name -}}.get_nft_txs_by_collection
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the sales record of the NFT collection in the marketplace. [Footprint docs here](https://docs.footprint.network/reference/get_nft-collection-transactions).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/collection/transactions") | trim}}

- name: {{ schema_name -}}.get_nft_transfers_by_collection
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the transfers record of the NFT collection. [Footprint docs here](https://docs.footprint.network/reference/get_nft-collection-transfers).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/collection/transfers") | trim}}

- name: {{ schema_name -}}.get_nft_listings
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the sales listing of the NFT in the marketplace. [Footprint docs here](https://docs.footprint.network/reference/get_nft-order-listings).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/order/listings") | trim}}

- name: {{ schema_name -}}.check_nft_wash_trade
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns whether the transaction hash is wash trading. [Footprint docs here](https://docs.footprint.network/reference/get_nft-collection-transactions-is-washtrade).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/collection/transactions/is-washtrade") | trim}}

- name: {{ schema_name -}}.get_nft_collection_stats
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the statistics metrics data of the specified NFT collection. [Footprint docs here](https://docs.footprint.network/reference/get_nft-collection-metrics).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/collection/metrics") | trim}}

- name: {{ schema_name -}}.get_nft_collection_floor_price_history
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the floor price history of the specified NFT collection. [Footprint docs here](https://docs.footprint.network/reference/get_nft-collection-floor-price-history).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/collection/floor-price/history") | trim}}

- name: {{ schema_name -}}.get_nft_collection_market_cap_history
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the market cap history of the specified NFT collection. [Footprint docs here](https://docs.footprint.network/reference/get_nft-collection-market-cap-history).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/collection/market-cap/history") | trim}}

- name: {{ schema_name -}}.get_nft_collection_volume_history
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the volume history of the specified NFT collection. [Footprint docs here](https://docs.footprint.network/reference/get_nft-collection-volume-history).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/collection/volume/history") | trim}}

- name: {{ schema_name -}}.get_nft_marketplace_stats
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the statistics metrics data of single NFT collection in the marketplace. [Footprint docs here](https://docs.footprint.network/reference/get_nft-marketplace-statistics).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/marketplace/statistics") | trim}}

- name: {{ schema_name -}}.get_nft_collections
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the basic information of the NFT collection. [Footprint docs here](https://docs.footprint.network/reference/get_nft-collection-info).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/collection/info") | trim}}

- name: {{ schema_name -}}.get_nft_tokens_by_collection
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the basic information of the NFT. [Footprint docs here](https://docs.footprint.network/reference/get_nft-info).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/info") | trim}}

- name: {{ schema_name -}}.get_nft_attributes
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the attributes of the NFT. [Footprint docs here](https://docs.footprint.network/reference/get_nft-attributes).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/attributes") | trim}}

- name: {{ schema_name -}}.get_nft_owners_by_collection
  signature:
    - [QUERY_PARAMS, OBJECT, The query parameters]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the owners of the NFT. [Footprint docs here](https://docs.footprint.network/reference/get_nft-collection-owners).$$
  sql: {{footprint_get_api_call(utils_schema_name, "/v2/nft/collection/owners") | trim}}

{% endmacro %}