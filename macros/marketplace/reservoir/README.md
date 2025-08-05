# Reservoir API Integration

Reservoir provides comprehensive NFT data infrastructure with APIs for accessing real-time NFT market data, collections, sales, and aggregated marketplace information.

## Setup

1. Get your Reservoir API key from [Reservoir Dashboard](https://reservoir.tools/dashboard)

2. Store the API key in Snowflake secrets under `_FSC_SYS/RESERVOIR`

3. Deploy the Reservoir marketplace functions:
   ```bash
   dbt run --models reservoir__ reservoir_utils__reservoir_utils
   ```

## Functions

### `reservoir.get(path, query_args)`
Make GET requests to Reservoir API endpoints.

### `reservoir.post(path, body)`
Make POST requests to Reservoir API endpoints.

## Examples

```sql
-- Get collection floor prices
SELECT reservoir.get('/collections/v7', {'id': '0x...', 'includeTopBid': 'true'});

-- Get recent sales
SELECT reservoir.get('/sales/v6', {'collection': '0x...', 'limit': 100});

-- Get token details
SELECT reservoir.get('/tokens/v7', {'collection': '0x...', 'tokenId': '1234'});
```

## API Documentation

- [Reservoir API Documentation](https://docs.reservoir.tools/)