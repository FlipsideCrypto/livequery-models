# Solscan API Integration

Solscan is a leading Solana blockchain explorer providing comprehensive APIs for accessing Solana transaction data, account information, and network statistics.

## Setup

1. Get your Solscan API key from [Solscan API Portal](https://pro-api.solscan.io/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/SOLSCAN`

3. Deploy the Solscan marketplace functions:
   ```bash
   dbt run --models solscan__ solscan_utils__solscan_utils
   ```

## Functions

### `solscan.get(path, query_args)`
Make GET requests to Solscan API endpoints.

## Examples

```sql
-- Get account information
SELECT solscan.get('/account', {'address': 'account_address'});

-- Get transaction details
SELECT solscan.get('/transaction', {'signature': 'transaction_signature'});

-- Get token information
SELECT solscan.get('/token/meta', {'token': 'token_address'});
```

## API Documentation

- [Solscan API Documentation](https://docs.solscan.io/)