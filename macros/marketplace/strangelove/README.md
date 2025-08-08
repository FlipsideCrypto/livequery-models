# Strangelove API Integration

Strangelove provides blockchain infrastructure and data services for Cosmos ecosystem blockchains, offering APIs for accessing cross-chain data and IBC information.

## Setup

1. Get your Strangelove API key from [Strangelove Ventures](https://strangelove.ventures/)

2. Store the API key in Snowflakerets under `_FSC_SYS/STRANGELOVE`

3. Deploy the Strangelove marketplace functions:
   ```bash
   dbt run --models strangelove__ strangelove_utils__strangelove_utils
   ```

## Functions

### `strangelove.get(path, query_args)`
Make GET requests to Strangelove API endpoints.

### `strangelove.post(path, body)`
Make POST requests to Strangelove API endpoints.

## Examples

```sql
-- Get Cosmos network data
SELECT strangelove.get('/api/v1/chains', {});

-- Get IBC transfer data
SELECT strangelove.get('/api/v1/ibc/transfers', {'chain': 'cosmoshub', 'limit': 100});

-- Get validator information
SELECT strangelove.get('/api/v1/validators', {'chain': 'osmosis'});
```

## API Documentation

- [Strangelove API Documentation](https://docs.strangelove.ventures/)