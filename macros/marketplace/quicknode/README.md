# QuickNode API Integration

QuickNode provides high-performance blockchain infrastructure with RPC endpoints and enhanced APIs for Ethereum, Polygon, Solana, and other networks.

## Setup

1. Get your QuickNode endpoint and API key from [QuickNode Dashboard](https://dashboard.quicknode.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/QUICKNODE`

3. Deploy the QuickNode marketplace functions:
   ```bash
   dbt run --models quicknode__ quicknode_utils__quicknode_utils
   ```

## Functions

### `quicknode.get(path, query_args)`
Make GET requests to QuickNode API endpoints.

### `quicknode.post(path, body)`
Make POST requests to QuickNode API endpoints.

## Examples

```sql
-- Get latest block number
SELECT quicknode.post('/rpc', {
  'jsonrpc': '2.0',
  'method': 'eth_blockNumber',
  'params': [],
  'id': 1
});

-- Get NFT metadata
SELECT quicknode.get('/nft/v1/ethereum/nft/0x.../1', {});

-- Get token transfers
SELECT quicknode.get('/token/v1/ethereum/transfers', {'address': '0x...', 'limit': 100});
```

## API Documentation

- [QuickNode API Documentation](https://www.quicknode.com/docs/)