# Bitquery API Integration

Bitquery provides GraphQL APIs for blockchain data across multiple networks including Bitcoin, Ethereum, Binance Smart Chain, and many others.

## Setup

1. Get your Bitquery API key from [Bitquery IDE](https://ide.bitquery.io/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/BITQUERY`

3. Deploy the Bitquery marketplace functions:
   ```bash
   dbt run --models bitquery__ bitquery_utils__bitquery_utils
   ```

## Functions

### `bitquery.get(path, query_args)`
Make GET requests to Bitquery API endpoints.

### `bitquery.post(path, body)`
Make POST requests to Bitquery API endpoints for GraphQL queries.

## Examples

```sql
-- Get Ethereum DEX trades
SELECT bitquery.post('/graphql', {
  'query': 'query { ethereum { dexTrades(date: {since: "2023-01-01"}) { count } } }'
});

-- Get Bitcoin transactions
SELECT bitquery.post('/graphql', {
  'query': 'query { bitcoin { transactions(date: {since: "2023-01-01"}) { count } } }'
});

-- Get token transfers on BSC
SELECT bitquery.post('/graphql', {
  'query': 'query { ethereum(network: bsc) { transfers(date: {since: "2023-01-01"}) { count } } }'
});
```

## API Documentation

- [Bitquery API Documentation](https://docs.bitquery.io/)