# Helius API Integration

Helius provides high-performance Solana RPC infrastructure and enhanced APIs for accessing Solana blockchain data, including DAS (Digital Asset Standard) APIs.

## Setup

1. Get your Helius API key from [Helius Dashboard](https://dashboard.helius.dev/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/HELIUS`

3. Deploy the Helius marketplace functions:
   ```bash
   dbt run --models helius__ helius_utils__helius_utils
   ```

## Functions

### `helius.get(path, query_args)`
Make GET requests to Helius API endpoints.

### `helius.post(path, body)`
Make POST requests to Helius API endpoints.

## Examples

```sql
-- Get Solana account info
SELECT helius.post('/rpc', {
  'jsonrpc': '2.0',
  'method': 'getAccountInfo',
  'params': ['account_address'],
  'id': 1
});

-- Get compressed NFTs by owner
SELECT helius.get('/v0/addresses/owner_address/nfts', {'compressed': true});

-- Get transaction history
SELECT helius.get('/v0/addresses/address/transactions', {'limit': 100});
```

## API Documentation

- [Helius API Documentation](https://docs.helius.dev/)