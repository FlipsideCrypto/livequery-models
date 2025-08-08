# Alchemy API Integration

Comprehensive blockchain data integration using Alchemy's powerful APIs for NFTs, tokens, transfers, and RPC calls across multiple networks.

## Supported Networks

- **Ethereum** (`eth-mainnet`)
- **Polygon** (`polygon-mainnet`) 
- **Arbitrum** (`arb-mainnet`)
- **Optimism** (`opt-mainnet`)
- **Base** (`base-mainnet`)
- **And more** - Check [Alchemy's documentation](https://docs.alchemy.com/reference/api-overview) for the latest supported networks

## Setup

1. Get your Alchemy API key from [Alchemy Dashboard](https://dashboard.alchemy.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/ALCHEMY`

3. Deploy the Alchemy marketplace functions:
   ```bash
   dbt run --models alchemy__ alchemy_utils__alchemy_utils
   ```

## Core Functions

### Utility Functions (`alchemy_utils` schema)

#### `alchemy_utils.nfts_get(network, path, query_args)`
Make GET requests to Alchemy NFT API endpoints.

#### `alchemy_utils.nfts_post(network, path, body)`
Make POST requests to Alchemy NFT API endpoints.

#### `alchemy_utils.rpc(network, method, params)`
Make RPC calls to blockchain networks via Alchemy.

### NFT Functions (`alchemy` schema)

#### `alchemy.get_nfts_for_owner(network, owner[, query_args])`
Get all NFTs owned by an address.

#### `alchemy.get_nft_metadata(network, contract_address, token_id)`
Get metadata for a specific NFT.

#### `alchemy.get_nfts_for_collection(network, contract_address[, query_args])`
Get all NFTs in a collection.

#### `alchemy.get_owners_for_nft(network, contract_address, token_id)`
Get all owners of a specific NFT.

### Token Functions

#### `alchemy.get_token_balances(network, owner[, contract_addresses])`
Get token balances for an address.

#### `alchemy.get_token_metadata(network, contract_address)`
Get metadata for a token contract.

### Transfer Functions

#### `alchemy.get_asset_transfers(network, query_args)`
Get asset transfer data with flexible filtering.

## Examples

### NFT Queries

#### Get NFTs for Owner
```sql
-- Get all NFTs owned by an address
SELECT alchemy.get_nfts_for_owner(
  'eth-mainnet',
  '0x742d35Cc6634C0532925a3b8D45C5f8B9a8Fb15b'
);

-- With pagination and filtering
SELECT alchemy.get_nfts_for_owner(
  'eth-mainnet', 
  '0x742d35Cc6634C0532925a3b8D45C5f8B9a8Fb15b',
  {
    'pageSize': 100,
    'contractAddresses': ['0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D']  -- BAYC
  }
);
```

#### Get NFT Metadata
```sql
-- Get metadata for specific NFT
SELECT alchemy.get_nft_metadata(
  'eth-mainnet',
  '0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D',  -- BAYC contract
  '1234'  -- Token ID
);
```

#### Get Collection NFTs
```sql
-- Get all NFTs in a collection
SELECT alchemy.get_nfts_for_collection(
  'eth-mainnet',
  '0x60E4d786628Fea6478F785A6d7e704777c86a7c6',  -- MAYC
  {
    'pageSize': 50,
    'startToken': '0'
  }
);
```

### Token Queries

#### Get Token Balances
```sql
-- Get all token balances for an address
SELECT alchemy.get_token_balances(
  'eth-mainnet',
  '0x742d35Cc6634C0532925a3b8D45C5f8B9a8Fb15b'
);

-- Get specific token balances
SELECT alchemy.get_token_balances(
  'eth-mainnet',
  '0x742d35Cc6634C0532925a3b8D45C5f8B9a8Fb15b',
  ['0xA0b86a33E6417e8EdcfCfdD8fb59a3A5b3dB8BFD']  -- USDC
);
```

#### Get Token Metadata
```sql
-- Get token contract information
SELECT alchemy.get_token_metadata(
  'eth-mainnet',
  '0xA0b86a33E6417e8EdcfCfdD8fb59a3A5b3dB8BFD'  -- USDC
);
```

### Transfer Analysis

#### Asset Transfers
```sql
-- Get recent transfers for an address
SELECT alchemy.get_asset_transfers(
  'eth-mainnet',
  {
    'fromAddress': '0x742d35Cc6634C0532925a3b8D45C5f8B9a8Fb15b',
    'category': ['erc721', 'erc1155'],
    'maxCount': 100
  }
);

-- Get transfers for a specific contract
SELECT alchemy.get_asset_transfers(
  'eth-mainnet',
  {
    'contractAddresses': ['0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D'],
    'category': ['erc721'],
    'fromBlock': '0x12A05F200',
    'toBlock': 'latest'
  }
);
```

### RPC Calls

#### Direct Blockchain Queries
```sql
-- Get latest block number
SELECT alchemy_utils.rpc(
  'eth-mainnet',
  'eth_blockNumber',
  []
);

-- Get block by number
SELECT alchemy_utils.rpc(
  'eth-mainnet',
  'eth_getBlockByNumber',
  ['0x12A05F200', true]
);

-- Get transaction receipt
SELECT alchemy_utils.rpc(
  'eth-mainnet',
  'eth_getTransactionReceipt',
  ['0x1234567890abcdef...']
);
```

### Multi-Network Analysis

#### Compare NFT Holdings Across Networks
```sql
-- Get BAYC holdings on Ethereum
WITH eth_nfts AS (
  SELECT 'ethereum' as network, alchemy.get_nfts_for_owner(
    'eth-mainnet',
    '0x742d35Cc6634C0532925a3b8D45C5f8B9a8Fb15b'
  ) as nfts
),
-- Get NFTs on Polygon
polygon_nfts AS (
  SELECT 'polygon' as network, alchemy.get_nfts_for_owner(
    'polygon-mainnet', 
    '0x742d35Cc6634C0532925a3b8D45C5f8B9a8Fb15b'
  ) as nfts
)
SELECT network, nfts:totalCount::INTEGER as nft_count
FROM eth_nfts
UNION ALL
SELECT network, nfts:totalCount::INTEGER 
FROM polygon_nfts;
```

### Advanced Analytics

#### NFT Floor Price Tracking
```sql
-- Track collection stats over time
WITH collection_data AS (
  SELECT alchemy.get_nfts_for_collection(
    'eth-mainnet',
    '0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D',  -- BAYC
    {'pageSize': 1}
  ) as collection_info
)
SELECT 
  collection_info:contract:name::STRING as collection_name,
  collection_info:contract:totalSupply::INTEGER as total_supply,
  CURRENT_TIMESTAMP as snapshot_time
FROM collection_data;
```

## Error Handling

Handle API errors and rate limits:

```sql
WITH api_response AS (
  SELECT alchemy.get_nfts_for_owner(
    'eth-mainnet',
    '0xinvalid-address'
  ) as response
)
SELECT
  CASE 
    WHEN response:error IS NOT NULL THEN 
      CONCAT('API Error: ', response:error:message::STRING)
    WHEN response:ownedNfts IS NOT NULL THEN
      CONCAT('Success: Found ', ARRAY_SIZE(response:ownedNfts), ' NFTs')
    ELSE 
      'Unexpected response format'
  END as result
FROM api_response;
```

## Rate Limiting

Alchemy API has the following rate limits:
- **Free tier**: 300 requests per second
- **Growth tier**: 660 requests per second  
- **Scale tier**: Custom limits

The functions automatically handle rate limiting through Livequery's retry mechanisms.

## Best Practices

1. **Use pagination**: For large datasets, use `pageSize` and pagination tokens
2. **Filter requests**: Use `contractAddresses` to limit scope when possible
3. **Cache results**: Store frequently accessed data in tables
4. **Monitor usage**: Track API calls to stay within limits
5. **Network selection**: Choose the most relevant network for your use case

## Supported Categories

For asset transfers, use these categories:
- `erc20` - ERC-20 token transfers
- `erc721` - NFT transfers
- `erc1155` - Multi-token standard transfers
- `internal` - Internal ETH transfers
- `external` - External ETH transfers

## API Documentation

- [Alchemy API Reference](https://docs.alchemy.com/reference/api-overview)
- [NFT API](https://docs.alchemy.com/reference/nft-api-quickstart)
- [Token API](https://docs.alchemy.com/reference/token-api-quickstart)  
- [Enhanced API Methods](https://docs.alchemy.com/reference/enhanced-api-quickstart)