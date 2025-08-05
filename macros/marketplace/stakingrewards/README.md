# Staking Rewards API Integration

Staking Rewards provides comprehensive data on cryptocurrency staking opportunities, validator performance, and yield farming across multiple blockchain networks.

## Setup

1. Get your Staking Rewards API key from [Staking Rewards API Portal](https://stakingrewards.com/api)

2. Store the API key in Snowflake secrets under `_FSC_SYS/STAKINGREWARDS`

3. Deploy the Staking Rewards marketplace functions:
   ```bash
   dbt run --models stakingrewards__ stakingrewards_utils__stakingrewards_utils
   ```

## Functions

### `stakingrewards.get(path, query_args)`
Make GET requests to Staking Rewards API endpoints.

## Examples

```sql
-- Get staking assets
SELECT stakingrewards.get('/assets', {'limit': 100});

-- Get validator information
SELECT stakingrewards.get('/validators', {'asset': 'ethereum', 'limit': 50});

-- Get staking rewards data
SELECT stakingrewards.get('/rewards', {'asset': 'solana', 'timeframe': '30d'});
```

## API Documentation

- [Staking Rewards API Documentation](https://docs.stakingrewards.com/)