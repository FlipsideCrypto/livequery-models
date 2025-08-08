{% macro config_helius_apis_udfs(schema_name = "helius_apis", utils_schema_name = "helius_utils") -%}
{#
    This macro is used to generate the Helius API endpoints
 #}

- name: {{ schema_name -}}.token_metadata
  signature:
    - [NETWORK, STRING, mainnet or devnet]
    - [BODY, OBJECT, The body of the API request]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns metadata for a list of given token mint addresses. [Helius docs here](https://docs.helius.xyz/solana-apis/token-metadata-api).$$
  sql: {{ helius_post_call(utils_schema_name, '/v0/token-metadata') | trim }}

- name: {{ schema_name -}}.balances
  signature:
    - [NETWORK, STRING, mainnet or devnet]
    - [ADDRESS, STRING, The address to retrieve balances for]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns the native Solana balance (in lamports) and all token balances for a given address. [Helius docs here](https://docs.helius.xyz/solana-apis/balances-api).$$
  sql: |
    SELECT 
    {% set v2_exists = check_udf_api_v2_exists() %}
    {% if v2_exists -%}
      live.udf_api_v2(
        'GET',
        CASE 
            WHEN NETWORK = 'devnet' THEN 
                concat('https://api-devnet.helius.xyz/v0/addresses/', ADDRESS, '/balances?api-key={API_KEY}')
            ELSE 
                concat('https://api.helius.xyz/v0/addresses/', ADDRESS, '/balances?api-key={API_KEY}')
        END,
        {'fsc-quantum-execution-mode': 'async'},
        {},
        '_FSC_SYS/HELIUS',
        TRUE
      )
    {%- else -%}
      live.udf_api(
        'GET',
        CASE 
            WHEN NETWORK = 'devnet' THEN 
                concat('https://api-devnet.helius.xyz/v0/addresses/', ADDRESS, '/balances?api-key={API_KEY}')
            ELSE 
                concat('https://api.helius.xyz/v0/addresses/', ADDRESS, '/balances?api-key={API_KEY}')
        END,
        {},
        {},
        '_FSC_SYS/HELIUS'
      )
    {%- endif %}
    as response

- name: {{ schema_name -}}.parse_transactions
  signature:
    - [NETWORK, STRING, mainnet or devnet]
    - [TRANSACTIONS, ARRAY, An array of transaction signatures]
  return_type:
    - "VARIANT"
  options: |
    COMMENT = $$Returns an array of enriched, human-readable transactions of the given transaction signatures. Up to 100 transactions per call. [Helius docs here](https://docs.helius.xyz/solana-apis/enhanced-transactions-api/parse-transaction-s).$$
  sql: |
    SELECT {{ utils_schema_name -}}.post_api(NETWORK, '/v0/transactions', {'transactions': TRANSACTIONS}) as response

{% endmacro %}