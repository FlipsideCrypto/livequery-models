# Footprint Analytics API Integration

Footprint Analytics provides comprehensive blockchain data analytics with APIs for accessing DeFi, NFT, GameFi, and cross-chain data insights.

## Setup

1. Get your Footprint API key from [Footprint Analytics Dashboard](https://www.footprint.network/dashboard)

2. Store the API key in Snowflake secrets under `_FSC_SYS/FOOTPRINT`

3. Deploy the Footprint marketplace functions:
   ```bash
   dbt run --models footprint__ footprint_utils__footprint_utils
   ```

## Functions

### `footprint.get(path, query_args)`
Make GET requests to Footprint Analytics API endpoints.

### `footprint.post(path, body)`
Make POST requests to Footprint Analytics API endpoints.

## Examples

```sql
-- Get DeFi protocol TVL data
SELECT footprint.get('/api/v1/defi/protocol/tvl', {'protocol': 'uniswap', 'chain': 'ethereum'});

-- Get NFT market trends
SELECT footprint.get('/api/v1/nft/market/overview', {'timeframe': '7d'});

-- Get GameFi protocol statistics
SELECT footprint.get('/api/v1/gamefi/protocols', {'chain': 'polygon', 'limit': 20});
```

## API Documentation

- [Footprint Analytics API Documentation](https://docs.footprint.network/)