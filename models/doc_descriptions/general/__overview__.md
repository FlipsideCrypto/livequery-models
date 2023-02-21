{% docs __overview__ %}

# Welcome to the Flipside Crypto LiveQuery Models Documentation!

## **What does this documentation cover?**
The documentation included here details the design of the LiveQuery functions available via [Flipside Crypto](https://flipsidecrypto.xyz/). For more information on how these functions are built, please see [the github repository.](https://github.com/FlipsideCrypto/livequery-models)

### **Overview of Available Functions**

**UTILS Functions**

- `utils.hex_to_int`: Use this UDF to transform any hex string to integer
    ```
    ex: Curve Swaps

    SELECT
        regexp_substr_all(SUBSTR(DATA, 3, len(DATA)), '.{64}') AS segmented_data,
        utils.hex_to_int(segmented_data [1] :: STRING) :: INTEGER AS tokens_sold
    FROM
        optimism.core.fact_event_logs
    WHERE
        topics [0] :: STRING IN (
            '0x8b3e96f2b889fa771c53c981b40daf005f63f637f1869f707052d15a3dd97140',
            '0xd013ca23e77a65003c2c659c5442c00c805371b7fc1ebd4c206c41d1536bd90b'
        )
    ```
- `utils.hex_encode_function`(Function VARCHAR): Use this UDF to hex encode any string
    ```
    ex: Decimals Function Signature

    SELECT
        `decimals` AS function_name,
        utils.hex_encode_function(`decimals()`) :: STRING AS text_sig, 
        LEFT(text_sig,10) AS function_sig,
        '0x313ce567' AS expected_sig
    ```
- `utils.evm_decode_logs`
- `utils.udf_introspect`
- `utils.udf_register_secret`
- `utils.whoami`

**LIVE Functions & Examples**

- `live.udf_api`(Method STRING, URL STRING, Headers OBJECT, Data OBJECT): Use this UDF to make a GET or POST request on any API
    ```
    ex: Solana Token Metadata

    SELECT
        live.udf_api(
            'GET',
            'https://public-api.solscan.io/token/meta?tokenAddress=SPraYi59a21jEhqvPBbWuwmjA4vdTaSLbiRTefcHJSR',
            { },
            { }
        );

    Running with multiple Solana token addresses at the same time

    WITH solana_addresses AS (
        SELECT
            'SPraYi59a21jEhqvPBbWuwmjA4vdTaSLbiRTefcHJSR' AS address
        UNION
        SELECT
            '4KbzSz2VF1LCvEaw8viq1335VgWzNjMd8rwQMsCkKHip'
    )
    SELECT
        live.udf_api(
            'GET',
            concat(
                'https://public-api.solscan.io/token/meta?tokenAddress=',
                address
            ),
            { },
            { }
        )
    FROM
        solana_addresses;

    Hit Quicknode (see instructions below for how to register an API Key with Flipside securely)
    
    SELECT
        live.udf_api(
            'POST',
            '{my_url}',
            {},
            { 'method' :'eth_blockNumber',
              'params' :[],
                'id' :1,
                'jsonrpc' :'2.0' },
            'quicknode'
        );
    ```

### **Registering and Using LiveQuery Credentials to Query Quicknode**
With LiveQuery you can safely store encrypted credentials, such as an API key, with Flipside, and query blockchain nodes directly via our SQL interface. Here’s how:
1. Sign up for a free [Quicknode API Account](https://www.quicknode.com/core-api)
2. Navigate to ***Endpoints*** on the left hand side then click the ***Get Started*** tab and ***Copy*** the HTTP Provider Endpoint. Do not adjust the Setup or Security parameters.
3. Visit [Ephit](https://science.flipsidecrypto.xyz/ephit) to obtain an Ephemeral query that will securely link your API Endpoint to Flipside's backend. This will allow you to refer to the URL securely in our application without referencing it or exposing keys directly.
4. Fill out the form and ***Submit this Credential***
5. Paste the provided query into [Flipside](https://flipside.new) and query your node directly in the app with your submitted Credential (`{my_url}`).


## **Using dbt docs**
### Navigation

You can use the ```Project``` and ```Database``` navigation tabs on the left side of the window to explore the models in the project.

### Database Tab

This view shows relations (tables and views) grouped into database schemas. Note that ephemeral models are *not* shown in this interface, as they do not exist in the database.

### Graph Exploration

You can click the blue icon on the bottom-right corner of the page to view the lineage graph of your models.

On model pages, you'll see the immediate parents and children of the model you're exploring. By clicking the Expand button at the top-right of this lineage pane, you'll be able to see all of the models that are used to build, or are built from, the model you're exploring.

Once expanded, you'll be able to use the ```--models``` and ```--exclude``` model selection syntax to filter the models in the graph. For more information on model selection, check out the [dbt docs](https://docs.getdbt.com/docs/model-selection-syntax).

Note that you can also right-click on models to interactively filter and explore the graph.

### **More information**
- [Flipside](https://flipsidecrypto.xyz/)
- [Velocity](https://app.flipsidecrypto.com/velocity?nav=Discover)
- [Tutorials](https://docs.flipsidecrypto.com/our-data/tutorials)
- [Github](https://github.com/FlipsideCrypto/external-models)
- [What is dbt?](https://docs.getdbt.com/docs/introduction)



{% enddocs %}