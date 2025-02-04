# LiveQuery Functions Overview
**LiveQuery is a powerful tool that enables users to interact with approved APIs, access utility functions for easy handling of complex blockchain data, and maintain best practices for usage. With LiveQuery Functions, users can access a variety of APIs, create JSON RPC requests, easily convert data types such as hex strings to integers, securely store encrypted credentials, and more. This resource offers guidance on limits, best practices, sample queries, and future enhancements to ensure effective use of the LiveQuery Functions.**

## Table of Contents
- [LiveQuery Functions Overview](#livequery-functions-overview)
  - [Table of Contents](#table-of-contents)
- [LiveQuery Functions](#livequery-functions)
- [Live Functions](#live-functions)
  - [Limits and Best Practices](#limits-and-best-practices)
  - [udf\_api](#udf_api)
    - [Syntax](#syntax)
    - [Arguments](#arguments)
    - [Approved APIs](#approved-apis)
    - [Sample Queries](#sample-queries)
- [Utility Functions](#utility-functions)
  - [udf\_hex\_to\_int](#udf_hex_to_int)
    - [Syntax](#syntax-1)
    - [Arguments](#arguments-1)
    - [Sample Queries](#sample-queries-1)
  - [udf\_hex\_to\_string](#udf_hex_to_string)
    - [Syntax](#syntax-2)
    - [Arguments](#arguments-2)
    - [Sample Queries](#sample-queries-2)
  - [udf\_json\_rpc\_call](#udf_json_rpc_call)
    - [Syntax](#syntax-3)
    - [Arguments](#arguments-3)
    - [Sample Queries](#sample-queries-3)
- [Registering Secrets](#registering-secrets)
- [Other DBT docs - LiveQuery Models](#other-dbt-docs---livequery-models)
  - [Profile Set Up](#profile-set-up)
  - [Variables](#variables)
  - [Resources](#resources)
  - [Applying Model Tags](#applying-model-tags)
  - [Database / Schema level tags](#database--schema-level-tags)
    - [Model tags](#model-tags)
    - [Querying for existing tags on a model in snowflake](#querying-for-existing-tags-on-a-model-in-snowflake)


# LiveQuery Functions

| Function Name                                 | Purpose                                       | Status      |
| --------------------------------------------- | --------------------------------------------- | ----------- |
| [live.udf_api](#udf_api)                      | Can interact directly with approved APIs      | Available   |
| [utils.udf_hex_to_int](#udf_hex_to_int)       | Converts hex strings to integers              | Available   |
| [utils.udf_hex_to_string](#udf_hex_to_string) | Converts hex strings to text                  | Available   |
| [utils.udf_json_rpc_call](#udf_json_rpc_call) | Creates JSON RPC requests                     | Available   |
| utils.udf_hex_encode_function                 | Converts a function or event signature to hex | Coming Soon |
| utils.udf_evm_decode_logs                     | Decodes EVM log data                          | Coming Soon |


# Live Functions

## Limits and Best Practices
- The `udf_api` function is very powerful, but it is also very easy to abuse. Please be mindful of the following limits and best practices when using this function.
  - We reserve the right to disable the `udf_api` function for particular users, or as a whole, if we see it being abused.
- Most APIs have rate limits. Please be mindful of these limits and do not abuse them.
- Most of the limits you will encounter using this function will be on the API side. Please be sure to thoroughly read an API's documentation before using it.
- **However, certain limits do apply to the `udf_api` function itself, including:**
  - API request = 1 row in the query
  - API request (per row) response size limit: 6MB
  - API request timeout (per row) limit: 30 seconds
  - Data app query timeout limit: 15 minutes
- Batching is supported for JSON RPC requests.
  - Again, this is very easy to abuse. Be mindful of the API's rate limits when using this functionality.
- It is strongly recommended that you start small and test your queries before requesting large amounts of data.
- Response data is not cached.
  - This means that if you run the same query twice, that API will be called twice. A future enhancement may address this need, but for now, please be mindful of this limitation.
- Many APIs require authentication.
  - Please see the [secret registration section](#registering-secrets) below for more information on how to register secrets for use with the `udf_api` function.
  - Technically, you can pass secrets into the `udf_api` function directly, but this is not recommended.
    - If you do pass your secrets without following the steps in the [secret registration section](#registering-secrets), your secrets will be visible in Flipside's internal query history.
- These docs and this process will continue to evolve. More detailed examples and powerful use cases will continue to be added. We are just getting started!
- Please be patient with us as we work to improve this process.
  - Upcoming enhancements include:
    - Support for more APIs
    - Secret management improvements
- If you build something that you believe is powerful enough to be included in this documentation, please reach out to us on [Discord](https://discord.com/channels/784442203187314689/1095714436599267409)! We would love to hear feedback and see what you are building.

## udf_api
This function can be used to interact directly with approved APIs, including QuickNode, DeFi Llama, and more. Please see the [Approved APIs](#approved-apis) section below for a list of approved APIs.
### Syntax
```sql
livequery.live.udf_api(
  [method,]
  url,
  [headers,]
  [data,]
  [secret_name]
)
```
### Arguments
**Required**
- `url` (string): The URL to call. If you are doing a GET request that does not require authentication, you can pass the URL directly. Otherwise, you may need to pass in some or all of the optional arguments below. You may also need to pass a secret value into the URL if you are using an API that requires authentication. See the QuickNode example below for more information on this case.

**Optional**
- `method` (string): The HTTP method to use (GET, POST, etc.)
- `headers` (object): A JSON object containing the headers to send with the request
- `data` (object): A JSON object containing the data to send with the request. Batched JSON RPC requests are supported by passing an array of JSON RPC requests.
- `secret_name` (string): The name of the secret to use for authentication. Please see the [secret registration section](#registering-secrets) below for more information.


### Approved APIs

| API Name              | API Docs                                                                               | Authentication Required |
| --------------------- | -------------------------------------------------------------------------------------- | ----------------------- |
| QuickNode             | [Docs](https://www.quicknode.com/docs)                                                 | Yes                     |
| DeFi Llama            | [Docs](https://defillama.com/docs/api)                                                 | No                      |
| zkSync                | [Docs](https://docs.zksync.io/apiv02-docs/)                                            | No                      |
| DeepNFT Value         | [Docs](https://deepnftvalue.readme.io/reference/getting-started-with-deepnftvalue-api) | Yes                     |
| Zapper                | [Docs](https://api.zapper.fi/api/static/index.html#/Apps/AppsController_getApps)       | No                      |
| Helius                | [Docs](https://docs.helius.xyz/welcome/what-is-helius)                                 | No                      |
| Stargaze Name Service | [Docs](https://github.com/public-awesome/names/blob/main/API.md)                       | No                      |
| Snapshot              | [Docs](https://docs.snapshot.org/graphql-api)                                          | No                      |
| Solscan               | [Docs](https://public-api.solscan.io/docs/)                                            | Yes                     |
| SubGraphs             | [Docs](https://thegraph.com/docs/en/querying/querying-the-graph/)                      | Sometimes               |
| IPFS                  | [Docs](https://docs.ipfs.tech/reference/http/api/)                                     | No                      |


If you are interested in using an API that is not on this list, please reach out to us on [Discord](https://discord.com/channels/784442203187314689/1095714436599267409).

---
### Sample Queries
<details>
  <summary>QuickNode Examples</summary>

  ```sql
  -- Get the latest block number, please note you will need to register your node secrets
  -- See docs for more info on how to register secrets and use them in queries
  -- See docs for more info on how to create JSON RPC requests (utils.udf_json_rpc_call)
  WITH create_rpc_request AS (
       SELECT
              livequery.utils.udf_json_rpc_call(
                     'eth_blockNumber',
                     []
              ) AS rpc_request
),
base AS (
       SELECT
              livequery.live.udf_api(
                     'POST',
                     'https://indulgent-smart-shape.discover.quiknode.pro/{url_key}/',{}, -- your words will likely be different. This is just an example URL.
                     rpc_request,
                     'quicknode_eth'
              ) AS api_call
       FROM
              create_rpc_request
)
SELECT
       api_call :data :result :: STRING AS hex_block,
       livequery.utils.udf_hex_to_int(hex_block) :: INT AS int_block
FROM
       base;


  -- Get the latest balance for a wallet, please note you will need to register your node secrets
  -- This is a general ETH call example, and can be used for any contract and function
  WITH inputs AS (
     -- input function_sig, token_address, wallet_address
     -- format data for eth call, should be 64 chars long (32 bytes) + 10 chars for function sig (including 0x)
     SELECT
            LOWER('0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84') AS token_address,
            -- stETH
            LOWER('0x66B870dDf78c975af5Cd8EDC6De25eca81791DE1') AS wallet_address,
            --a16Z
            '0x70a08231' AS function_sig,
            --balanceOf(address)
            CONCAT(
                   function_sig,
                   LPAD(REPLACE(wallet_address, '0x', ''), 64, 0)
            ) AS DATA
) -- creates a formatted json rpc eth_call request that is ready to be sent to a node
, create_rpc_request as (
SELECT
    wallet_address,
     livequery.utils.udf_json_rpc_call(
            'eth_call',
            [{ 'to': token_address, 'from': null, 'data': data },'latest']
     ) AS rpc_request
FROM
     inputs
)
, base AS ( --sending request to node
    SELECT
        wallet_address,
        livequery.live.udf_api(
            'POST',
            'https://indulgent-smart-shape.discover.quiknode.pro/{url_key}/',{},rpc_request, --secret value in URL (URL Key). Your subdomain will likely be different. This is just an example URL.
            'quicknode_eth' --registered secret name
        ) AS response
from create_rpc_request
)
SELECT
    wallet_address,
    livequery.utils.udf_hex_to_int(response:data:result::string) :: INT / pow(10,18) AS balance
FROM
    base;
  ```
</details>
<details>
  <summary>Subgraph Example</summary>

  ```sql
  -- Getting Univ3 Liquidity Data from a Subgraph
  -- Create a graphQL query and post it to the subgraph
  SELECT
       livequery.live.udf_api(
              'POST',
              'https://api.thegraph.com/subgraphs/name/messari/uniswap-v3-polygon',{ 'Content-Type': 'application/json' },{ 'query' :'{\n liquidityPools(first: 10, orderBy: totalLiquidity, orderDirection: desc) {\n id\n totalLiquidity\n name\n}\n}',
              'variables':{}}
       ) AS response;
 -- format the response
 with base as (
SELECT
    livequery.live.udf_api(
        'POST',
        'https://api.thegraph.com/subgraphs/name/messari/uniswap-v3-polygon',
        {'Content-Type': 'application/json'},
        {'query':'{\n  liquidityPools(first: 10, orderBy: totalLiquidity, orderDirection: desc) {\n    id\n    totalLiquidity\n    name\n}\n}',
        'variables':{}
        }
    ) as response
)
select
value:id::string as address,
value:name::string as name,
value:totalLiquidity::int as totalLiquidity
from base,
lateral flatten (input => response:data:data:liquidityPools)
;
  ```
</details>
<details>
  <summary>DeFi Llama API Example</summary>

  ```sql
  -- DeFI Llama does not require authentication, so we can just pass the URL
  SELECT
    livequery.live.udf_api('https://api.llama.fi/chains') as response;

  -- format the response
  WITH base AS (
       SELECT
              livequery.live.udf_api('https://api.llama.fi/chains') AS response
)
SELECT
       VALUE :chainId :: INT AS chainID,
       VALUE :cmcId :: INT AS cmcID,
       VALUE :gecko_id :: STRING AS geckoID,
       VALUE :name :: STRING AS NAME,
       VALUE :tokenSymbol :: STRING AS symbol,
       VALUE :tvl :: FLOAT AS tvl
FROM
       base,
       LATERAL FLATTEN (
              input => response :data
       );


  ```
</details>

</details>
<details>
  <summary>IPFS Example</summary>

  ```sql
  -- you can use this function to retrieve data from IPFS. You can find the hash in the URL within several places onchain, including evm logs and traces.
     SELECT
      livequery.live.udf_api('https://ipfs.io/ipfs/QmTFX3TopS8JsgpfBLKGDnTiaWrRcfStDWDQaREzD36sWW') AS response;
  ```
</details>

---

# Utility Functions
Utility functions are designed to make your life easier when interacting with blockchain data.

## udf_hex_to_int
This function converts a hex string to an integer.

### Syntax
```sql
livequery.utils.udf_hex_to_int(
  [encoding,]
  hex
)
```
### Arguments
**Required**
- `hex` (string): The hex string to convert

**Optional**
- `encoding` (string): The encoding to use. Valid values are `s2c` and `hex`. This parameter is optional. If not provided, the function will default to `hex`.

### Sample Queries
<details>
  <summary>Convert Hex to Integer</summary>

  ```sql
    -- these are all the same
  select
    livequery.utils.udf_hex_to_int ('1E240')::int as int1,
    livequery.utils.udf_hex_to_int ('0x1E240')::int as int2,
    livequery.utils.udf_hex_to_int ('hex','0x1E240')::int as int3;
  ```
</details>
<details>
  <summary>Convert Hex to Signed 2's Complement Integer</summary>

  ```sql
  -- these are the same
  select
    livequery.utils.udf_hex_to_int ('s2c','FFFE1DC0')::int as int1,
    livequery.utils.udf_hex_to_int ('s2c','0xFFFE1DC0')::int as int2
  ```
</details>

---

## udf_hex_to_string

This function converts a hex string to a string of human readable characters. It will handle obscure characters like emojis and special characters.

### Syntax
```sql
livequery.utils.udf_hex_to_string(
  hex
)
```
### Arguments
**Required**
- `hex` (string): The hex string to convert

### Sample Queries
<details>
  <summary>Convert Hex to Text</summary>

  ```sql
  select
    livequery.utils.udf_hex_to_string('466C69707369646520726F636B73') as text1
  ```
</details>

---

## udf_json_rpc_call
This function creates a JSON RPC request based on the parameters provided.

### Syntax
```sql
livequery.utils.udf_json_rpc_call(
  method,
  params
  [,id]
)
```
### Arguments
**Required**
- `method` (string): The method to call
- `params` (array, object): The parameters to pass to the method. This can be an array or an object.

**Optional**
- `id` (string): The ID of the request. This parameter is optional. If not provided, the function will default to a random number.

### Sample Queries
<details>
  <summary>Create eth_blockNumber Request</summary>

  ```sql
  -- creates a JSON RPC request to get the latest block number
     SELECT
        livequery.utils.udf_json_rpc_call('eth_blockNumber',[]) AS rpc_request;
  ```
</details>
<details>
  <summary>Create eth_call Request</summary>

  ```sql
  -- this will create a balanceOf request for a16Z's wallet on stETH. Make sure to format the data correctly for the function you are calling.
  WITH inputs AS (
       -- input function_sig, token_address, wallet_address
       -- format data for eth call, should be 64 chars long (32 bytes) + 10 chars for function sig (including 0x)
       SELECT
              LOWER('0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84') AS token_address,
              -- stETH
              LOWER('0x66B870dDf78c975af5Cd8EDC6De25eca81791DE1') AS wallet_address,
              --a16Z
              '0x70a08231' AS function_sig,
              --balanceOf(address)
              CONCAT(
                     function_sig,
                     LPAD(REPLACE(wallet_address, '0x', ''), 64, 0)
              ) AS DATA
) -- creates a formatted json rpc eth_call request that is ready to be sent to a node
SELECT
       livequery.utils.udf_json_rpc_call(
              'eth_call',
              [{ 'to': token_address, 'from': null, 'data': data },'latest']
       ) AS rpc_request
FROM
       inputs;

  ```
</details>

---
# Registering Secrets
With LiveQuery you can safely store encrypted credentials, such as an API key, with Flipside. This allows you to securely reference your credentials in your queries without exposing them directly.

To register a secret, follow these steps:
1. Visit [Ephit](https://science.flipsidecrypto.xyz/ephit) to obtain an Ephemeral query that will securely link your API Endpoint to Flipside's backend. This will allow you to refer to the URL securely in our application without referencing it or exposing keys directly.
2. Fill out the form and click ***Submit this Credential***
3. Paste the provided query into [Flipside](https://flipside.new) and query your node directly in the app with your submitted Credential (`{my_key}`)

Registering a secret from Quicknode to query nodes directly in Flipside:

1. Sign up for a free [Quicknode API Account](https://www.quicknode.com/core-api)
2. Navigate to ***Endpoints*** on the left hand side then click the ***Get Started*** tab and ***Copy*** the HTTP Provider Endpoint. Do not adjust the Setup or Security parameters.
3. Follow the steps above to register your secret
4. See [live.udf_api](#udf_api) for sample queries
# Other DBT docs - LiveQuery Models

Dbt repo for managing LiveQuery database.

## Profile Set Up

Use the following within profiles.yml

```yml
livequery:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <ACCOUNT>
      role: <ROLE>
      user: <USERNAME>
      password: <PASSWORD>
      region: <REGION>
      database: LIVEQUERY_DEV
      warehouse: <WAREHOUSE>
      schema: silver
      threads: 12
      client_session_keep_alive: False
      query_tag: <TAG>
    prod:
      type: snowflake
      account: <ACCOUNT>
      role: <ROLE>
      user: <USERNAME>
      password: <PASSWORD>
      region: <REGION>
      database: LIVEQUERY_DEV
      warehouse: <WAREHOUSE>
      schema: silver
      threads: 12
      client_session_keep_alive: False
      query_tag: <TAG>
```

## Variables

To control the creation of UDF or SP macros with dbt run:

* UPDATE_UDFS_AND_SPS
When True, executes all macros included in the on-run-start hooks within dbt_project.yml on model run as normal
When False, none of the on-run-start macros are executed on model run

Default values are False

* Usage:
`dbt run --vars '{"UPDATE_UDFS_AND_SPS":True}' -m ...`

Dropping and creating udfs can also be done without running a model:

```sh
dbt run-operation create_udfs --vars '{"UPDATE_UDFS_AND_SPS":True}' --args '{"drop_":false}'
dbt run-operation create_udfs --vars '{"UPDATE_UDFS_AND_SPS":True}' --args '{"drop_":true}'
```

## Resources

* Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
* Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
* Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
* Find [dbt events](https://events.getdbt.com) near you
* Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

## Applying Model Tags

## Database / Schema level tags

Database and schema tags are applied via the `add_database_or_schema_tags` macro.  These tags are inherited by their downstream objects.  To add/modify tags call the appropriate tag set function within the macro.

```jinja
{{ set_database_tag_value('SOME_DATABASE_TAG_KEY','SOME_DATABASE_TAG_VALUE') }}
{{ set_schema_tag_value('SOME_SCHEMA_TAG_KEY','SOME_SCHEMA_TAG_VALUE') }}
```

### Model tags

To add/update a model's snowflake tags, add/modify the `meta` model property under `config` .  Only table level tags are supported at this time via DBT.

```jinja
{{ config(
    ...
    meta={
        'database_tags':{
            'table': {
                'PURPOSE': 'SOME_PURPOSE'
            }
        }
    },
    ...
) }}
```

By default, model tags are pushed to Snowflake on each load. You can disable this by setting the `UPDATE_SNOWFLAKE_TAGS` project variable to `False` during a run.

```sh
dbt run --var '{"UPDATE_SNOWFLAKE_TAGS":False}' -s models/core/core__fact_blocks.sql
```

### Querying for existing tags on a model in snowflake

```sql
select *
from table(livequery.information_schema.tag_references('livequery.core.fact_blocks', 'table'));
```
