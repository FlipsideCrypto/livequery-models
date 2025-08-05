# Blockpour API Integration

Blockpour provides blockchain infrastructure and data services with high-performance APIs for accessing on-chain data.

## Setup

1. Get your Blockpour API key from [Blockpour Dashboard](https://blockpour.com/dashboard)

2. Store the API key in Snowflake secrets under `_FSC_SYS/BLOCKPOUR`

3. Deploy the Blockpour marketplace functions:
   ```bash
   dbt run --models blockpour__ blockpour_utils__blockpour_utils
   ```

## Functions

### `blockpour.get(path, query_args)`
Make GET requests to Blockpour API endpoints.

### `blockpour.post(path, body)`
Make POST requests to Blockpour API endpoints.

## Examples

```sql
-- Get latest block information
SELECT blockpour.get('/api/v1/blocks/latest', {});

-- Get transaction details
SELECT blockpour.get('/api/v1/transactions/0x...', {});

-- Get token balances for an address
SELECT blockpour.get('/api/v1/addresses/0x.../tokens', {});
```

## API Documentation

- [Blockpour API Documentation](https://docs.blockpour.com/)