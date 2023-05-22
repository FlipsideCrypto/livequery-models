{% docs __overview__ %}

# Welcome to the Flipside Crypto Reference Models Documentation!

## **What does this documentation cover?**
The documentation included here details the design of the Reference functions available via [Flipside Crypto](https://flipsidecrypto.xyz/). For more information on how these functions are built, please see [the github repository.](https://github.com/FlipsideCrypto/reference-models)

### **Overview of Available Functions**

#### **UTILS Functions**

- `utils.udf_hex_to_int`: Use this UDF to transform any hex string to integer
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
- `utils.udf_hex_to_string`: Use this UDF to transform any hexadecimal string to a regular string. The function removes any non-printable or control characters from the resulting string.
    ```
    ex: Token Names

    WITH base AS (
    SELECT
        '0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000005452617265202d204368616e74616c20486167656c202d20576f6d656e2773204575726f2032303232202d2032303232205371756164202d20576f6d656e2773204e6174696f6e616c205465616d202d2032303232000000000000000000000000' AS input_token_name
        )

    SELECT 
        utils.udf_hex_to_string(SUBSTR(input_token_name,(64*2+3),LEN(input_token_name))) AS output_token_name
    FROM base;

    NOTE: The expression 64 * 2 + 3 in the query navigates to the 131st character of the hexadecimal string returned by an EVM blockchain contract's function, skipping metadata and adjusting for Snowflake's 1-based indexing. Keep in mind that the exact start of relevant data may vary between different contracts and functions.

    ```


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
- [Tutorials](https://docs.flipsidecrypto.com/our-data/tutorials)
- [Github](https://github.com/FlipsideCrypto/reference-models)
- [What is dbt?](https://docs.getdbt.com/docs/introduction)

{% enddocs %}