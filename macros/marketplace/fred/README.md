# FRED API Integration

FRED (Federal Reserve Economic Data) provides access to economic data from the Federal Reserve Bank of St. Louis, including GDP, inflation, employment, and financial market data.

## Setup

1. Get your FRED API key from [FRED API Registration](https://fred.stlouisfed.org/docs/api/api_key.html)

2. Store the API key in Snowflake secrets under `_FSC_SYS/FRED`

3. Deploy the FRED marketplace functions:
   ```bash
   dbt run --models fred__ fred_utils__fred_utils
   ```

## Functions

### `fred.get(path, query_args)`
Make GET requests to FRED API endpoints.

## Examples

```sql
-- Get GDP data
SELECT fred.get('/series/observations', {'series_id': 'GDP', 'api_key': 'your_key'});

-- Get unemployment rate
SELECT fred.get('/series/observations', {'series_id': 'UNRATE', 'api_key': 'your_key'});

-- Get inflation rate (CPI)
SELECT fred.get('/series/observations', {'series_id': 'CPIAUCSL', 'api_key': 'your_key'});
```

## API Documentation

- [FRED API Documentation](https://fred.stlouisfed.org/docs/api/fred/)