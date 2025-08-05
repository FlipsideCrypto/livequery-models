# Transpose API Integration

Transpose provides real-time blockchain data infrastructure with APIs for accessing NFT data, DeFi protocols, and on-chain analytics across multiple networks.

## Setup

1. Get your Transpose API key from [Transpose Dashboard](https://dashboard.transpose.io/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/TRANSPOSE`

3. Deploy the Transpose marketplace functions:
   ```bash
   dbt run --models transpose__ transpose_utils__transpose_utils
   ```

## Functions

### `transpose.get(path, query_args)`
Make GET requests to Transpose API endpoints.

### `transpose.post(path, body)`
Make POST requests to Transpose API endpoints.

## Examples

```sql
-- Get NFT collection data
SELECT transpose.get('/v0/ethereum/collections/0x...', {});

-- Get account NFTs
SELECT transpose.get('/v0/ethereum/nfts/by-owner', {'owner_address': '0x...', 'limit': 100});

-- Get token transfers
SELECT transpose.get('/v0/ethereum/transfers', {'contract_address': '0x...', 'limit': 50});
```

## API Documentation

- [Transpose API Documentation](https://docs.transpose.io/)