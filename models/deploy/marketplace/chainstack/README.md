# Chainstack API Integration

Chainstack provides managed blockchain infrastructure with high-performance nodes and APIs for multiple blockchain networks.

## Setup

1. Get your Chainstack API key from [Chainstack Console](https://console.chainstack.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/CHAINSTACK`

3. Deploy the Chainstack marketplace functions:
   ```bash
   dbt run --models chainstack__ chainstack_utils__chainstack_utils
   ```

## Functions

### `chainstack.get(path, query_args)`
Make GET requests to Chainstack API endpoints.

### `chainstack.post(path, body)`
Make POST requests to Chainstack API endpoints.

## Examples

```sql
-- Get latest block number
SELECT chainstack.post('/rpc', {
  'jsonrpc': '2.0',
  'method': 'eth_blockNumber',
  'params': [],
  'id': 1
});

-- Get account balance
SELECT chainstack.post('/rpc', {
  'jsonrpc': '2.0',
  'method': 'eth_getBalance',
  'params': ['0x...', 'latest'],
  'id': 1
});

-- Get transaction receipt
SELECT chainstack.post('/rpc', {
  'jsonrpc': '2.0',
  'method': 'eth_getTransactionReceipt',
  'params': ['0x...'],
  'id': 1
});
```

## API Documentation

- [Chainstack API Documentation](https://docs.chainstack.com/)