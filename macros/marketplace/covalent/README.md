# Covalent API Integration

Covalent provides a unified API to access rich blockchain data across multiple networks, offering historical and real-time data for wallets, transactions, and DeFi protocols.

## Setup

1. Get your Covalent API key from [Covalent Dashboard](https://www.covalenthq.com/platform/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/COVALENT`

3. Deploy the Covalent marketplace functions:
   ```bash
   dbt run --models covalent__ covalent_utils__covalent_utils
   ```

## Functions

### `covalent.get(path, query_args)`
Make GET requests to Covalent API endpoints.

## Examples

```sql
-- Get token balances for an address
SELECT covalent.get('/v1/1/address/0x.../balances_v2/', {});

-- Get transaction history for an address
SELECT covalent.get('/v1/1/address/0x.../transactions_v2/', {'page-size': 100});

-- Get NFTs owned by an address
SELECT covalent.get('/v1/1/address/0x.../balances_nft/', {});
```

## API Documentation

- [Covalent API Documentation](https://www.covalenthq.com/docs/api/)