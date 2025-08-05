# Binance API Integration

Binance is the world's largest cryptocurrency exchange by trading volume, providing access to spot trading, futures, and market data.

## Setup

1. Get your Binance API key from [Binance API Management](https://www.binance.com/en/my/settings/api-management)

2. Store the API key in Snowflake secrets under `_FSC_SYS/BINANCE`

3. Deploy the Binance marketplace functions:
   ```bash
   dbt run --models binance__ binance_utils__binance_utils
   ```

## Functions

### `binance.get(path, query_args)`
Make GET requests to Binance API endpoints.

### `binance.post(path, body)`
Make POST requests to Binance API endpoints.

## Examples

```sql
-- Get current Bitcoin price
SELECT binance.get('/api/v3/ticker/price', {'symbol': 'BTCUSDT'});

-- Get 24hr ticker statistics
SELECT binance.get('/api/v3/ticker/24hr', {'symbol': 'ETHUSDT'});

-- Get order book depth
SELECT binance.get('/api/v3/depth', {'symbol': 'ADAUSDT', 'limit': 100});
```

## API Documentation

- [Binance API Documentation](https://binance-docs.github.io/apidocs/spot/en/)