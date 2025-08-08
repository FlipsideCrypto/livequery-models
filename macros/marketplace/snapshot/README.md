# Snapshot API Integration

Snapshot is a decentralized voting platform that provides APIs for accessing DAO governance data, proposals, votes, and community participation metrics.

## Setup

1. Get your Snapshot API key from [Snapshot Hub](https://snapshot.org/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/SNAPSHOT`

3. Deploy the Snapshot marketplace functions:
   ```bash
   dbt run --models snapshot__ snapshot_utils__snapshot_utils
   ```

## Functions

### `snapshot.get(path, query_args)`
Make GET requests to Snapshot API endpoints.

### `snapshot.post(path, body)`
Make POST requests to Snapshot GraphQL API endpoints.

## Examples

```sql
-- Get DAO spaces
SELECT snapshot.post('/graphql', {
  'query': 'query { spaces(first: 20, orderBy: "created", orderDirection: desc) { id name } }'
});

-- Get proposals for a space
SELECT snapshot.post('/graphql', {
  'query': 'query { proposals(first: 10, where: {space: "uniswap"}) { id title state } }'
});

-- Get votes for a proposal
SELECT snapshot.post('/graphql', {
  'query': 'query { votes(first: 100, where: {proposal: "proposal_id"}) { voter choice } }'
});
```

## API Documentation

- [Snapshot API Documentation](https://docs.snapshot.org/)