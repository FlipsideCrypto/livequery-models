# DappLooker API Integration

DappLooker provides blockchain analytics and data visualization platform with APIs for accessing DeFi, NFT, and on-chain metrics across multiple networks.

## Setup

1. Get your DappLooker API key from [DappLooker Dashboard](https://dapplooker.com/dashboard)

2. Store the API key in Snowflake secrets under `_FSC_SYS/DAPPLOOKER`

3. Deploy the DappLooker marketplace functions:
   ```bash
   dbt run --models dapplooker__ dapplooker_utils__dapplooker_utils
   ```

## Functions

### `dapplooker.get(path, query_args)`
Make GET requests to DappLooker API endpoints.

### `dapplooker.post(path, body)`
Make POST requests to DappLooker API endpoints.

## Examples

```sql
-- Get DeFi protocol metrics
SELECT dapplooker.get('/api/v1/defi/protocols', {'network': 'ethereum'});

-- Get NFT collection statistics
SELECT dapplooker.get('/api/v1/nft/collections/stats', {'collection': '0x...'});

-- Get wallet analytics
SELECT dapplooker.get('/api/v1/wallet/analytics', {'address': '0x...', 'network': 'ethereum'});
```

## API Documentation

- [DappLooker API Documentation](https://docs.dapplooker.com/)