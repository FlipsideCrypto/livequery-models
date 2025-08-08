# Zapper API Integration

Zapper provides DeFi portfolio tracking and analytics with APIs for accessing wallet balances, DeFi positions, transaction history, and yield farming opportunities.

## Setup

1. Get your Zapper API key from [Zapper API Portal](https://api.zapper.fi/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/ZAPPER`

3. Deploy the Zapper marketplace functions:
   ```bash
   dbt run --models zapper__ zapper_utils__zapper_utils
   ```

## Functions

### `zapper.get(path, query_args)`
Make GET requests to Zapper API endpoints.

## Examples

```sql
-- Get wallet token balances
SELECT zapper.get('/v2/balances', {'addresses[]': '0x...', 'networks[]': 'ethereum'});

-- Get DeFi protocol positions
SELECT zapper.get('/v2/apps/tokens', {'groupId': 'uniswap-v2', 'addresses[]': '0x...'});

-- Get transaction history
SELECT zapper.get('/v2/transactions', {'address': '0x...', 'network': 'ethereum'});
```

## API Documentation

- [Zapper API Documentation](https://docs.zapper.fi/)