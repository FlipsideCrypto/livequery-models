# ZettaBlock API Integration

ZettaBlock provides real-time blockchain data infrastructure with GraphQL APIs for accessing multi-chain data, analytics, and custom data indexing.

## Setup

1. Get your ZettaBlock API key from [ZettaBlock Console](https://console.zettablock.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/ZETTABLOCK`

3. Deploy the ZettaBlock marketplace functions:
   ```bash
   dbt run --models zettablock__ zettablock_utils__zettablock_utils
   ```

## Functions

### `zettablock.get(path, query_args)`
Make GET requests to ZettaBlock API endpoints.

### `zettablock.post(path, body)`
Make POST requests to ZettaBlock GraphQL API endpoints.

## Examples

```sql
-- Get blockchain data via GraphQL
SELECT zettablock.post('/graphql', {
  'query': 'query { ethereum { transactions(first: 10) { hash value gasPrice } } }'
});

-- Get token information
SELECT zettablock.post('/graphql', {
  'query': 'query { tokens(network: "ethereum", first: 20) { address symbol name } }'
});

-- Get DeFi protocol data
SELECT zettablock.post('/graphql', {
  'query': 'query { defi { protocols(first: 10) { name tvl volume24h } } }'
});
```

## API Documentation

- [ZettaBlock API Documentation](https://docs.zettablock.com/)