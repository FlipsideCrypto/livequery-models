# ESPN API Integration

ESPN provides comprehensive sports data including scores, schedules, player statistics, and news across multiple sports leagues.

## Setup

1. Get your ESPN API key from [ESPN Developer Portal](https://developer.espn.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/ESPN`

3. Deploy the ESPN marketplace functions:
   ```bash
   dbt run --models espn__ espn_utils__espn_utils
   ```

## Functions

### `espn.get(path, query_args)`
Make GET requests to ESPN API endpoints.

## Examples

```sql
-- Get NFL scores
SELECT espn.get('/v1/sports/football/nfl/scoreboard', {});

-- Get NBA team roster
SELECT espn.get('/v1/sports/basketball/nba/teams/1/roster', {});

-- Get MLB standings
SELECT espn.get('/v1/sports/baseball/mlb/standings', {});
```

## API Documentation

- [ESPN API Documentation](https://site.api.espn.com/apis/site/v2/sports/)