# SubQuery API Integration

SubQuery provides decentralized data indexing infrastructure for Web3, offering APIs to access indexed blockchain data across multiple networks including Polkadot, Ethereum, and Cosmos.

## Setup

1. Get your SubQuery API key from [SubQuery Managed Service](https://managedservice.subquery.network/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/SUBQUERY`

3. Deploy the SubQuery marketplace functions:
   ```bash
   dbt run --models subquery__ subquery_utils__subquery_utils
   ```

## Functions

### `subquery.get(path, query_args)`
Make GET requests to SubQuery API endpoints.

### `subquery.post(path, body)`
Make POST requests to SubQuery GraphQL API endpoints.

## Examples

```sql
-- Get indexed project data
SELECT subquery.post('/graphql', {
  'query': 'query { transfers(first: 10) { id from to value } }'
});

-- Get block information
SELECT subquery.post('/graphql', {
  'query': 'query { blocks(first: 5, orderBy: NUMBER_DESC) { id number timestamp } }'
});

-- Get account transactions
SELECT subquery.post('/graphql', {
  'query': 'query { accounts(filter: {id: {equalTo: "address"}}) { id transactions { nodes { id } } } }'
});
```

## API Documentation

- [SubQuery API Documentation](https://academy.subquery.network/)