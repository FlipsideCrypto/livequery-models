# Playgrounds API Integration

Playgrounds provides gaming and entertainment data APIs with access to game statistics, player data, and gaming platform analytics.

## Setup

1. Get your Playgrounds API key from [Playgrounds Developer Portal](https://playgrounds.com/developers)

2. Store the API key in Snowflake secrets under `_FSC_SYS/PLAYGROUNDS`

3. Deploy the Playgrounds marketplace functions:
   ```bash
   dbt run --models playgrounds__ playgrounds_utils__playgrounds_utils
   ```

## Functions

### `playgrounds.get(path, query_args)`
Make GET requests to Playgrounds API endpoints.

### `playgrounds.post(path, body)`
Make POST requests to Playgrounds API endpoints.

## Examples

```sql
-- Get game statistics
SELECT playgrounds.get('/api/v1/games/stats', {'game_id': 'fortnite'});

-- Get player rankings
SELECT playgrounds.get('/api/v1/leaderboards', {'game': 'valorant', 'region': 'na'});

-- Get tournament data
SELECT playgrounds.get('/api/v1/tournaments', {'status': 'active', 'limit': 50});
```

## API Documentation

- [Playgrounds API Documentation](https://docs.playgrounds.com/)