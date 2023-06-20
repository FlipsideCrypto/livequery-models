{{ config(
    materialized = 'view'
) }}

SELECT 
  'avalanche' AS blockchain,
  'AVAX' AS symbol 
UNION 
SELECT 
  'polygon' AS blockchain,
  'MATIC' AS symbol 
UNION 
SELECT 
  'binance' AS blockchain,
  'BNB' AS symbol 
UNION 
SELECT 
  'gnosis' AS blockchain,
  'xDAI' AS symbol 
UNION 
SELECT 
  'ethereum' AS blockchain,
  'ETH' AS symbol 
UNION 
SELECT 
  'arbitrum' AS blockchain,
  'ETH' AS symbol 
UNION 
SELECT 
  'optimism' AS blockchain,
  'ETH' AS symbol 
UNION 
SELECT 
  'base' AS blockchain,
  'ETH' AS symbol 
UNION 
SELECT 
  'fantom' AS blockchain,
  'ETH' AS symbol 
UNION 
SELECT 
  'harmony' AS blockchain,
  'ONE' AS symbol
