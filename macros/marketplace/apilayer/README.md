# API Layer Integration

API Layer provides a comprehensive suite of APIs including currency conversion, geolocation, weather data, and more utility APIs.

## Setup

1. Get your API Layer API key from [API Layer Dashboard](https://apilayer.com/dashboard)

2. Store the API key in Snowflake secrets under `_FSC_SYS/APILAYER`

3. Deploy the API Layer marketplace functions:
   ```bash
   dbt run --models apilayer__ apilayer_utils__apilayer_utils
   ```

## Functions

### `apilayer.get(path, query_args)`
Make GET requests to API Layer API endpoints.

### `apilayer.post(path, body)`
Make POST requests to API Layer API endpoints.

## Examples

```sql
-- Get currency exchange rates
SELECT apilayer.get('/exchangerates_data/latest', {'base': 'USD', 'symbols': 'EUR,GBP,JPY'});

-- Get IP geolocation data
SELECT apilayer.get('/ip_api/check', {'ip': '8.8.8.8'});

-- Validate email address
SELECT apilayer.get('/email_validation/check', {'email': 'test@example.com'});
```

## API Documentation

- [API Layer Documentation](https://apilayer.com/marketplace)