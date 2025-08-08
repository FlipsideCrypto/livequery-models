# CoinMarketCap API Integration

CoinMarketCap is a leading cryptocurrency market data platform providing real-time and historical cryptocurrency prices, market capitalizations, and trading volumes.

## Setup

1. Get your CoinMarketCap API key from [CoinMarketCap Pro API](https://pro.coinmarketcap.com/account)

2. Store the API key in Snowflake secrets under `_FSC_SYS/CMC`

3. Deploy the CoinMarketCap marketplace functions:
   ```bash
   dbt run --models cmc__ cmc_utils__cmc_utils
   ```

## Functions

### `cmc.get(path, query_args)`
Make GET requests to CoinMarketCap API endpoints.

## Examples

```sql
-- Get latest cryptocurrency listings
SELECT cmc.get('/v1/cryptocurrency/listings/latest', {'limit': 100});

-- Get specific cryptocurrency quotes
SELECT cmc.get('/v2/cryptocurrency/quotes/latest', {'symbol': 'BTC,ETH,ADA'});

-- Get cryptocurrency metadata
SELECT cmc.get('/v2/cryptocurrency/info', {'symbol': 'BTC'});
```

## API Documentation

- [CoinMarketCap API Documentation](https://coinmarketcap.com/api/documentation/v1/)