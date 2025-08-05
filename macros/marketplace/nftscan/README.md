# NFTScan API Integration

NFTScan is a professional NFT data infrastructure platform providing comprehensive NFT APIs for accessing NFT metadata, transactions, and market data across multiple blockchains.

## Setup

1. Get your NFTScan API key from [NFTScan Developer Portal](https://developer.nftscan.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/NFTSCAN`

3. Deploy the NFTScan marketplace functions:
   ```bash
   dbt run --models nftscan__ nftscan_utils__nftscan_utils
   ```

## Functions

### `nftscan.get(path, query_args)`
Make GET requests to NFTScan API endpoints.

## Examples

```sql
-- Get NFT collection statistics
SELECT nftscan.get('/api/v2/statistics/collection/eth/0x...', {});

-- Get NFTs owned by an address
SELECT nftscan.get('/api/v2/account/own/eth/0x...', {'show_attribute': 'true', 'limit': 100});

-- Get NFT transaction history
SELECT nftscan.get('/api/v2/transactions/account/eth/0x...', {'event_type': 'Sale', 'limit': 50});
```

## API Documentation

- [NFTScan API Documentation](https://developer.nftscan.com/)