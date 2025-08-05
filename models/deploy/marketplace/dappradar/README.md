# DappRadar API Integration

DappRadar is a leading DApp analytics platform providing comprehensive data on decentralized applications, DeFi protocols, NFT collections, and blockchain games.

## Setup

1. Get your DappRadar API key from [DappRadar API Dashboard](https://dappradar.com/api)

2. Store the API key in Snowflake secrets under `_FSC_SYS/DAPPRADAR`

3. Deploy the DappRadar marketplace functions:
   ```bash
   dbt run --models dappradar__ dappradar_utils__dappradar_utils
   ```

## Functions

### `dappradar.get(path, query_args)`
Make GET requests to DappRadar API endpoints.

## Examples

```sql
-- Get top DApps by category
SELECT dappradar.get('/dapps', {'chain': 'ethereum', 'category': 'defi', 'limit': 50});

-- Get DApp details
SELECT dappradar.get('/dapps/1', {});

-- Get NFT collection rankings
SELECT dappradar.get('/nft/collections', {'chain': 'ethereum', 'range': '24h', 'limit': 100});
```

## API Documentation

- [DappRadar API Documentation](https://docs.dappradar.com/)