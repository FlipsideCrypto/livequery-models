# Chainbase API Integration

Chainbase provides comprehensive blockchain data infrastructure with APIs for accessing multi-chain data, NFTs, and DeFi protocols.

## Setup

1. Get your Chainbase API key from [Chainbase Console](https://console.chainbase.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/CHAINBASE`

3. Deploy the Chainbase marketplace functions:
   ```bash
   dbt run --models chainbase__ chainbase_utils__chainbase_utils
   ```

## Functions

### `chainbase.get(path, query_args)`
Make GET requests to Chainbase API endpoints.

### `chainbase.post(path, body)`
Make POST requests to Chainbase API endpoints.

## Examples

```sql
-- Get token metadata
SELECT chainbase.get('/v1/token/metadata', {'chain_id': 1, 'contract_address': '0x...'});

-- Get NFT collections
SELECT chainbase.get('/v1/nft/collections', {'chain_id': 1, 'page': 1, 'limit': 20});

-- Get account token balances
SELECT chainbase.get('/v1/account/tokens', {'chain_id': 1, 'address': '0x...', 'limit': 20});
```

## API Documentation

- [Chainbase API Documentation](https://docs.chainbase.com/)