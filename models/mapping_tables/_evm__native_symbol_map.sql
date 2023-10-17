{{ config(
    materialized = 'view',
    grants = {'+select': fromyaml(var('ROLES'))}
) }}

WITH blockchain_assets AS (

    SELECT
        'avalanche' AS blockchain,
        'AVAX' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'avalanche' AS blockchain,
        'AVAX' AS asset_symbol,
        'testnet' AS network
    UNION ALL
    SELECT
        'binance' AS blockchain,
        'BNB' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'binance' AS blockchain,
        'BNB' AS asset_symbol,
        'testnet' AS network
    UNION ALL
    SELECT
        'gnosis' AS blockchain,
        'xDAI' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'ethereum' AS blockchain,
        'ETH' AS asset_symbol,
        'goerli' AS network
    UNION ALL
    SELECT
        'ethereum' AS blockchain,
        'ETH' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'ethereum' AS blockchain,
        'ETH' AS asset_symbol,
        'sepolia' AS network
    UNION ALL
    SELECT
        'arbitrum_nova' AS blockchain,
        'ETH' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'arbitrum_one' AS blockchain,
        'ETH' AS asset_symbol,
        'goerli' AS network
    UNION ALL
    SELECT
        'arbitrum_one' AS blockchain,
        'ETH' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'base' AS blockchain,
        'ETH' AS asset_symbol,
        'goerli' AS network
    UNION ALL
    SELECT
        'fantom' AS blockchain,
        'FTM' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'gnosis' AS blockchain,
        'xDAI' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'harmony' AS blockchain,
        'ONE' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'harmony' AS blockchain,
        'ONE' AS asset_symbol,
        'testnet' AS network
    UNION ALL
    SELECT
        'optimism' AS blockchain,
        'ETH' AS asset_symbol,
        'goerli' AS network
    UNION ALL
    SELECT
        'optimism' AS blockchain,
        'ETH' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'polygon' AS blockchain,
        'MATIC' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'polygon' AS blockchain,
        'MATIC' AS asset_symbol,
        'testnet' AS network
    UNION ALL
    SELECT
        'polygon_zkevm' AS blockchain,
        'ETH' AS asset_symbol,
        'mainnet' AS network
    UNION ALL
    SELECT
        'polygon_zkevm' AS blockchain,
        'ETH' AS asset_symbol,
        'testnet' AS network
    UNION ALL
    SELECT
        'CELO' AS blockchain,
        'CELO' AS asset_symbol,
        'mainnet' AS network
)

SELECT
    blockchain,
    network,
    asset_symbol AS symbol
FROM
    blockchain_assets
