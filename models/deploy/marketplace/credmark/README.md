# Credmark API Integration

Credmark provides DeFi risk modeling and analytics APIs with comprehensive data on lending protocols, token prices, and risk metrics.

## Setup

1. Get your Credmark API key from [Credmark Portal](https://gateway.credmark.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/CREDMARK`

3. Deploy the Credmark marketplace functions:
   ```bash
   dbt run --models credmark__ credmark_utils__credmark_utils
   ```

## Functions

### `credmark.get(path, query_args)`
Make GET requests to Credmark API endpoints.

### `credmark.post(path, body)`
Make POST requests to Credmark API endpoints.

## Examples

```sql
-- Get token price
SELECT credmark.get('/v1/model/token.price', {'token_address': '0x...', 'block_number': 'latest'});

-- Get portfolio risk metrics
SELECT credmark.post('/v1/model/finance.var-portfolio', {'addresses': ['0x...'], 'window': 30});

-- Get lending pool information
SELECT credmark.get('/v1/model/compound-v2.pool-info', {'token_address': '0x...'});
```

## API Documentation

- [Credmark API Documentation](https://docs.credmark.com/)