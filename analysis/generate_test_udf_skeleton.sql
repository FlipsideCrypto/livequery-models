{% set schema = "alchemy_nfts" %}
{% set config = fromyaml(config_alchemy_nfts_udfs(schema_name = schema, utils_schema_name = "alchemy_utils"))  %}
{% set raw_test_queries %}
alchemy_nfts.get_nfts:
  - "'eth-mainnet'"
  - {'owner': '0x4a9318F375937B56045E5a548e7E66AEA61Dd610'}
alchemy_nfts.get_owners_for_token:
  - "'eth-mainnet'"
  - {
    'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
    'tokenId': 44
  }
alchemy_nfts.get_owners_for_collection:
  - "'eth-mainnet'"
  - {
    'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
    'withTokenBalances': TRUE
  }
alchemy_nfts.is_holder_of_collection:
  - "'eth-mainnet'"
  - {
    'wallet': '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
    'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330'
  }
alchemy_nfts.get_contracts_for_owner:
  - "'eth-mainnet'"
  - {
    'owner': 'vitalik.eth',
    'pageSize': 100,
    'page': 1
  }
alchemy_nfts.get_nft_metadata:
  - "'eth-mainnet'"
  - {
    'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
    'tokenId': 44
  }
alchemy_nfts.get_nft_metadata_batch:
  - "'eth-mainnet'"
  - {
    'tokens': [
      {
        'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
        'tokenId': 44
      },
      {
        'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
        'tokenId': 43
      }
    ]
  }
alchemy_nfts.get_contract_metadata:
  - "'ethereum-mainnet'"
  - {
    'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330'
  }
alchemy_nfts.get_contract_metadata_batch:
  - "'eth-mainnet'"
  - {
    'contractAddresses': [
      '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
      '0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d'
    ]
  }
alchemy_nfts.invalidate_contract:
  - "'eth-mainnet'"
  - {
    'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330'
  }
alchemy_nfts.reingest_contract:
  - "'eth-mainnet'"
  - {
    'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330'
  }
alchemy_nfts.search_contract_metadata:
  - "'eth-mainnet'"
  - {
    'query': 'bored'
  }
alchemy_nfts.get_nfts_for_collection:
  - "'eth-mainnet'"
  - {
    'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
    'withMetadata': TRUE
  }
alchemy_nfts.get_spam_contracts:
  - "'eth-mainnet'"
  - {}
alchemy_nfts.is_spam_contract:
  - "'eth-mainnet'"
  - {
    'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330'
  }
alchemy_nfts.is_airdrop:
  - "'eth-mainnet'"
  - {
    'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
    'tokenId': 44
  }
alchemy_nfts.get_floor_price:
  - "'eth-mainnet'"
  - {
    'contractAddress': '0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d'
  }
alchemy_nfts.get_nft_sales:
  - "'eth-mainnet'"
  - {
    'fromBlock': 0,
    'toBlock': 'latest',
    'order': 'asc',
    'contractAddress': '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
    'tokenId': 44
  }
alchemy_nfts.compute_rarity:
  - "'eth-mainnet'"
  - {
    'tokenId': 3603,
    'contractAddress': '0xb6a37b5d14d502c3ab0ae6f3a0e058bc9517786e'
  }
alchemy_nfts.summarize_nft_attributes:
  - "'eth-mainnet'"
  - {
    'contractAddress': '0xb6a37b5d14d502c3ab0ae6f3a0e058bc9517786e'
  }
alchemy_transfers.get_asset_transfers:
  - "'eth-mainnet'"
  - [
    {
      'fromBlock': '0x0',
      'toBlock': 'latest',
      'toAddress': '0x5c43B1eD97e52d009611D89b74fA829FE4ac56b1',
      'category': ['external'],
      'withMetadata': TRUE,
      'excludeZeroValue': TRUE,
    }
  ]
alchemy_tokens.get_token_allowance:
  - "'eth-mainnet'"
  - [
    {
      'contract': '0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270',
      'owner': '0xf1a726210550c306a9964b251cbcd3fa5ecb275d',
      'spender': '0xdef1c0ded9bec7f1a1670819833240f027b25eff'
    }
  ]
alchemy_tokens.get_token_balances:
  - "'eth-mainnet'"
  - [
    '0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5',
    'erc20'
  ]
alchemy_tokens.get_token_metadata:
  - "'eth-mainnet'"
  - [
    '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'
  ]
{% endset %}
{% set test_queries = fromyaml(raw_test_queries) %}
{{ test_queries }}

_____
    columns:
{%- for item in config %}
      - name: {{ item["name"] | replace(schema~".", "") }}
        tests:
          - test_marketplace_udf:
              name: test_{{ item["name"].replace(".", "__") ~ "_status_200" }}
              args: >
                {{ test_queries[item["name"]] | join(", ") }}
              filter: :status_code
              expected: 200
{%- endfor %}

=====================

{{ config | pprint}}
{# {% for item in config %}
{% if item["return_type"][0] != "VARIANT"%}
  {{ item["return_type"][0] }}
{% endif %}
{% endfor %} #}