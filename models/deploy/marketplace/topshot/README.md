# NBA Top Shot API Integration

NBA Top Shot is Dapper Labs' basketball NFT platform featuring officially licensed NBA highlights as digital collectible Moments.

## Setup

1. Get your NBA Top Shot API key from [Dapper Labs Developer Portal](https://developers.dapperlabs.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/TOPSHOT`

3. Deploy the Top Shot marketplace functions:
   ```bash
   dbt run --models topshot__ topshot_utils__topshot_utils
   ```

## Functions

### `topshot.get(path, query_args)`
Make GET requests to NBA Top Shot API endpoints.

## Examples

```sql
-- Get Top Shot collections
SELECT topshot.get('/collections', {});

-- Get moment details
SELECT topshot.get('/moments/12345', {});

-- Get marketplace listings
SELECT topshot.get('/marketplace/listings', {'player': 'lebron-james', 'limit': 50});
```

## API Documentation

- [NBA Top Shot API Documentation](https://developers.dapperlabs.com/)