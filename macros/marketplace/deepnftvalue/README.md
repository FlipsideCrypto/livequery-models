# DeepNFTValue API Integration

DeepNFTValue provides AI-powered NFT valuation and analytics services, offering price predictions and market insights for NFT collections.

## Setup

1. Get your DeepNFTValue API key from [DeepNFTValue Dashboard](https://deepnftvalue.com/dashboard)

2. Store the API key in Snowflake secrets under `_FSC_SYS/DEEPNFTVALUE`

3. Deploy the DeepNFTValue marketplace functions:
   ```bash
   dbt run --models deepnftvalue__ deepnftvalue_utils__deepnftvalue_utils
   ```

## Functions

### `deepnftvalue.get(path, query_args)`
Make GET requests to DeepNFTValue API endpoints.

### `deepnftvalue.post(path, body)`
Make POST requests to DeepNFTValue API endpoints.

## Examples

```sql
-- Get NFT valuation
SELECT deepnftvalue.get('/api/v1/valuation', {'contract_address': '0x...', 'token_id': '1234'});

-- Get collection analytics
SELECT deepnftvalue.get('/api/v1/collection/analytics', {'contract_address': '0x...'});

-- Get price predictions
SELECT deepnftvalue.post('/api/v1/predict', {'contract_address': '0x...', 'token_ids': [1, 2, 3]});
```

## API Documentation

- [DeepNFTValue API Documentation](https://docs.deepnftvalue.com/)