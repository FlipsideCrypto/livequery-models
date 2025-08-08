# DefiLlama API Integration

DeFi analytics and TVL (Total Value Locked) data integration using DefiLlama's comprehensive DeFi protocol database.

## Setup

1. Most DefiLlama endpoints are free and don't require an API key

2. For premium endpoints, get your API key from [DefiLlama](https://defillama.com/docs/api)

3. Store the API key in Snowflake secrets under `_FSC_SYS/DEFILLAMA` (if using premium features)

4. Deploy the DefiLlama marketplace functions:
   ```bash
   dbt run --models defillama__ defillama_utils__defillama_utils
   ```

## Functions

### `defillama.get(path, query_args)`
Make GET requests to DefiLlama API endpoints.

## Examples

### Protocol TVL Data
```sql
-- Get current TVL for all protocols
SELECT defillama.get('/protocols', {});

-- Get specific protocol information
SELECT defillama.get('/protocol/uniswap', {});

-- Get historical TVL for a protocol
SELECT defillama.get('/protocol/aave', {});
```

### Chain TVL Data
```sql
-- Get TVL for all chains
SELECT defillama.get('/chains', {});

-- Get historical TVL for Ethereum
SELECT defillama.get('/historicalChainTvl/Ethereum', {});
```

### Yield Farming Data
```sql
-- Get current yields
SELECT defillama.get('/yields', {});

-- Get yields for specific protocol
SELECT defillama.get('/yields/project/aave', {});
```

### Token Pricing
```sql
-- Get current token prices
SELECT defillama.get('/prices/current/ethereum:0xA0b86a33E6417e8EdcfCfdD8fb59a3A5b3dB8BFD', {});

-- Get historical token prices
SELECT defillama.get('/prices/historical/1640995200/ethereum:0xA0b86a33E6417e8EdcfCfdD8fb59a3A5b3dB8BFD', {});
```

### Stablecoin Data
```sql
-- Get stablecoin market caps
SELECT defillama.get('/stablecoins', {});

-- Get specific stablecoin information
SELECT defillama.get('/stablecoin/1', {});  -- USDT
```

### Bridge Data
```sql
-- Get bridge volumes
SELECT defillama.get('/bridges', {});

-- Get specific bridge information  
SELECT defillama.get('/bridge/1', {});
```

## Rate Limiting

DefiLlama API is generally rate-limited to prevent abuse. Most endpoints are free to use.

## API Documentation

- [DefiLlama API Documentation](https://defillama.com/docs/api)
- [TVL API](https://defillama.com/docs/api#operations-tag-TVL)
- [Yields API](https://defillama.com/docs/api#operations-tag-Yields)