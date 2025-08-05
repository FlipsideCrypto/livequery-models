# OpenSea API Integration

OpenSea is the world's largest NFT marketplace, providing APIs for accessing NFT collections, listings, sales data, and marketplace activities.

## Setup

1. Get your OpenSea API key from [OpenSea Developer Portal](https://docs.opensea.io/reference/api-keys)

2. Store the API key in Snowflake secrets under `_FSC_SYS/OPENSEA`

3. Deploy the OpenSea marketplace functions:
   ```bash
   dbt run --models opensea__ opensea_utils__opensea_utils
   ```

## Functions

### `opensea.get(path, query_args)`
Make GET requests to OpenSea API endpoints.

### `opensea.post(path, body)`
Make POST requests to OpenSea API endpoints.

## Examples

```sql
-- Get NFT collection stats
SELECT opensea.get('/api/v2/collections/boredapeyachtclub/stats', {});

-- Get NFT listings
SELECT opensea.get('/api/v2/orders/ethereum/seaport/listings', {'limit': 20});

-- Get collection events
SELECT opensea.get('/api/v2/events/collection/boredapeyachtclub', {'event_type': 'sale'});
```

## API Documentation

- [OpenSea API Documentation](https://docs.opensea.io/reference/api-overview)