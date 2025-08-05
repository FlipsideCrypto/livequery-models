# CoinGecko API Integration

Comprehensive cryptocurrency market data integration using CoinGecko's Pro API for prices, market data, and trading information.

## Setup

1. Get your CoinGecko Pro API key from [CoinGecko Pro](https://pro.coingecko.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/COINGECKO`

3. Deploy the CoinGecko marketplace functions:
   ```bash
   dbt run --models coingecko__ coingecko_utils__coingecko_utils
   ```

## Functions

### `coingecko.get(path, query_args)`
Make GET requests to CoinGecko Pro API endpoints.

### `coingecko.post(path, body)`
Make POST requests to CoinGecko Pro API endpoints.

## Examples

### Price Data
```sql
-- Get current price for Bitcoin
SELECT coingecko.get('/api/v3/simple/price', {
  'ids': 'bitcoin',
  'vs_currencies': 'usd,eth',
  'include_24hr_change': 'true'
});

-- Get historical prices
SELECT coingecko.get('/api/v3/coins/bitcoin/history', {
  'date': '30-12-2023'
});
```

### Market Data
```sql
-- Get top cryptocurrencies by market cap
SELECT coingecko.get('/api/v3/coins/markets', {
  'vs_currency': 'usd',
  'order': 'market_cap_desc',
  'per_page': 100,
  'page': 1
});

-- Get global cryptocurrency statistics
SELECT coingecko.get('/api/v3/global', {});
```

### Token Information
```sql
-- Get detailed coin information
SELECT coingecko.get('/api/v3/coins/ethereum', {
  'localization': 'false',
  'tickers': 'false',
  'market_data': 'true',
  'community_data': 'true'
});
```

## Rate Limiting

CoinGecko Pro API limits:
- **Basic**: 10,000 calls/month
- **Premium**: 50,000 calls/month
- **Enterprise**: Custom limits

## API Documentation

- [CoinGecko Pro API Documentation](https://apiguide.coingecko.com/getting-started/introduction)
- [API Endpoints Reference](https://docs.coingecko.com/reference/introduction)