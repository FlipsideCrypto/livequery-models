# Dune Analytics API Integration

Access Dune Analytics queries and results directly from Snowflake for blockchain data analysis and visualization.

## Setup

1. Get your Dune API key from [Dune Analytics](https://dune.com/settings/api)

2. Store the API key in Snowflake secrets under `_FSC_SYS/DUNE`

3. Deploy the Dune marketplace functions:
   ```bash
   dbt run --models dune__ dune_utils__dune_utils
   ```

## Functions

### `dune.get(path, query_args)`
Make GET requests to Dune API endpoints.

### `dune.post(path, body)`
Make POST requests to Dune API endpoints.

## Examples

### Execute Queries
```sql
-- Execute a Dune query
SELECT dune.post('/api/v1/query/1234567/execute', {
  'query_parameters': {
    'token_address': '0xA0b86a33E6417e8EdcfCfdD8fb59a3A5b3dB8BFD'
  }
});
```

### Get Query Results
```sql
-- Get results from executed query
SELECT dune.get('/api/v1/execution/01234567-89ab-cdef-0123-456789abcdef/results', {});

-- Get latest results for a query
SELECT dune.get('/api/v1/query/1234567/results', {});
```

### Query Status
```sql
-- Check execution status
SELECT dune.get('/api/v1/execution/01234567-89ab-cdef-0123-456789abcdef/status', {});
```

### Parameterized Queries
```sql
-- Execute query with parameters
SELECT dune.post('/api/v1/query/1234567/execute', {
  'query_parameters': {
    'start_date': '2023-01-01',
    'end_date': '2023-12-31',
    'min_amount': 1000
  }
});
```

## Rate Limiting

Dune API rate limits vary by plan:
- **Free**: 20 executions per day
- **Plus**: 1,000 executions per day  
- **Premium**: 10,000 executions per day

## API Documentation

- [Dune API Documentation](https://dune.com/docs/api/)
- [Authentication](https://dune.com/docs/api/api-reference/authentication/)
- [Query Execution](https://dune.com/docs/api/api-reference/execute-queries/)