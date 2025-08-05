# NBA All Day API Integration

NBA All Day is Dapper Labs' basketball NFT platform, offering officially licensed NBA Moments as digital collectibles.

## Setup

1. Get your NBA All Day API key from [Dapper Labs developer portal](https://developers.dapperlabs.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/ALLDAY`

3. Deploy the All Day marketplace functions:
   ```bash
   dbt run --models allday__ allday_utils__allday_utils
   ```

## Functions

### `allday.get(path, query_args)`
Make GET requests to NBA All Day API endpoints.

## Examples

```sql
-- Get NBA All Day collections
SELECT allday.get('/collections', {});

-- Get specific moment details
SELECT allday.get('/moments/12345', {});

-- Search for moments by player
SELECT allday.get('/moments', {'player_id': 'lebron-james'});
```

## API Documentation

- [NBA All Day API Documentation](https://developers.dapperlabs.com/)