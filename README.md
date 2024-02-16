# Flipside Utility Functions

Dbt repo for managing the Flipside Utility Functions (FSC_UTILS) dbt package.

## Variables

Control the creation of `UDF` or `SP` macros with dbt run:

* `UPDATE_UDFS_AND_SPS` - 
When `True`, executes all macros included in the on-run-start hooks within dbt_project.yml on model run as normal
When False, none of the on-run-start macros are executed on model run

Default values is `False`

Usage:

```sh
dbt run --var 'UPDATE_UDFS_AND_SPS": True'  -m ...
```

Dropping and creating udfs can also be done without running a model:

```sh
dbt run-operation create_udfs --var 'UPDATE_UDFS_AND_SPS": True' --args 'drop_:false'
dbt run-operation create_udfs --var 'UPDATE_UDFS_AND_SPS": True' --args 'drop_:true'
```

## Adding Release Versions

1. Make the necessary changes to your code in your dbt package repository (e.g., fsc-utils).
2. Commit your changes with `git add .` and `git commit -m "Your commit message"`.
3. Tag your commit with a version number using `git tag -a v1.1.0 -m "version 1.1.0"`.
4. Push your commits to the remote repository with `git push origin ...`.
5. Push your tags to the remote repository with `git push origin --tags`.
6. In the `packages.yml` file of your other dbt project, specify the new version of the package with:

```
packages:
  - git: "https://github.com/FlipsideCrypto/fsc-utils.git"
    revision: "v1.1.0"
```  

7. Run dbt deps in the other dbt project to pull the specific version of the package or follow the steps on `adding the dbt package` below.

Regarding Semantic Versioning;
1. Semantic versioning is a versioning scheme for software that aims to convey meaning about the underlying changes with each new release.
2. It's typically formatted as MAJOR.MINOR.PATCH (e.g. v1.2.3), where:
- MAJOR version (first number) should increment when there are potential breaking or incompatible changes.
- MINOR version (second number) should increment when functionality or features are added in a backwards-compatible manner.
- PATCH version (third number) should increment when bug fixes are made without adding new features.
3. Semantic versioning helps package users understand the degree of changes in a new release, and decide when to adopt new versions. With dbt packages, when you tag a release with a semantic version, users can specify the exact version they want to use in their projects.

## Adding the `fsc_utils` dbt package

The `fsc_utils` dbt package is a centralized repository consisting of various dbt macros and snowflake functions that can be utilized across other repos.

1. Navigate to the `create_udfs.sql` macro in your respective repo where you want to install the package.
2. Add the following: 
```
{% set name %} 
{{- fsc_utils.create_udfs() -}}
{% endset %}
{% do run_query(sql) %}
``` 
3. Note: fsc_utils.create_udfs() takes two parameters (drop_=False, schema="utils"). Set `drop_` to `True` to drop existing functions or define `schema` for the functions (default set to `utils`). Params not required.
4. Navigate to `packages.yml` in your respective repo.
5. Add the following:
```
- git: https://github.com/FlipsideCrypto/fsc-utils.git
```
6. Run `dbt deps` to install the package
7. Run the macro `dbt run-operation create_udfs --var '{"UPDATE_UDFS_AND_SPS":True}'`

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
- `utils.udf_hex_to_string`: Use this UDF to transform any hexadecimal string to a regular string, removing any non-printable or control characters from the resulting string.
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

## **Streamline V 2.0 Functions**

The `Streamline V 2.0` functions are a set of macros and UDFs that are designed to be used with `Streamline V 2.0` deployments. 

### Available macros:

- [if_data_call_function_v2](/macros/streamline/utils.sql#L86): This macro is used to call a udf in the `Streamline V 2.0` deployment. It is defined in the dbt model config block and accepts the  `udf name` and the `udf` parameters. For legibility the `udf` parameters are passed as a `JSON object`. 

    **NOTE**: Ensure your project has registered the `udf` being invoked here prior to using this macro.

    **`Parameters`**:
    -  `func` - The name of the udf to be called.
    - `target` - The target table for the udf to be called on, interpolated in the [if_data_call_function_v2 macro](/macros/streamline/utils.sql#L101).
    - `params` - The parameters to be passed to the udf, a `JSON object` that contains the minimum parameters required by the udf all Streamline 2.0 udfs.


    ```sql
    -- Example usage in a dbt model config block
    {{ config (
        materialized = "view",
        post_hook = fsc_utils.if_data_call_function_v2(
            func = 'udf_bulk_rest_api_v2',
            target = "{{this.schema}}.{{this.identifier}}",
            params = {
                "external_table": "external_table",
                "sql_limit": "10",
                "producer_batch_size": "10",
                "worker_batch_size": "10",
                "sm_secret_name": "aws/sm/path",
                "sql_source": "{{this.identifier}}"
            }
        ),
        tags = ['model_tags']
    ) }} 
    ```
    When a dbt model with this config block is run we will see the following in the logs:

    ```sh

    # Example dbt run logs

    21:59:44  Found 244 models, 15 seeds, 7 operations, 5 analyses, 875 tests, 282 sources, 0 exposures, 0 metrics, 1024 macros, 0 groups, 0 semantic models
    21:59:44  
    21:59:49  
    21:59:49  Running 6 on-run-start hooks
    ...
    21:59:50  
    21:59:51  Concurrency: 12 threads (target='dev')
    21:59:51  
    21:59:51  1 of 1 START sql view model streamline.coingecko_realtime_ohlc ................. [RUN]
    21:59:51  Running macro `if_data_call_function`: Calling udf udf_bulk_rest_api_v2 with params: 
    {
    "external_table": "ASSET_OHLC_API/COINGECKO",
    "producer_batch_size": "10",
    "sm_secret_name": "prod/coingecko/rest",
    "sql_limit": "10",
    "sql_source": "{{this.identifier}}",
    "worker_batch_size": "10"
    }
    on {{this.schema}}.{{this.identifier}}
    22:00:03  1 of 1 OK created sql view model streamline.coingecko_realtime_ohlc ............ [SUCCESS 1 in 12.75s]
    22:00:03  
    ```
- [create_udf_bulk_rest_api_v2](/macros/streamline/udfs.sql#L1): This macro is used to create a `udf` named `udf_bulk_rest_api_v2` in the `streamline` schema of the database this is invoked in. This function returns a `variant` type and uses an API integration. The API integration and the external function URI are determined based on the target environment (`prod`, `dev`, or `sbx`).
    The [macro interpolates](/macros/streamline/udfs.sql#L9) the `API_INTEGRATION` and `EXTERNAL_FUNCTION_URI` vars from the `dbt_project.yml` file.

    ```yml
    # Setup variables in dbt_project.yml
    API_INTEGRATION: '{{ var("config")[target.name]["API_INTEGRATION"] }}' 
    EXTERNAL_FUNCTION_URI: '{{ var("config")[target.name]["EXTERNAL_FUNCTION_URI"] }}'

    config:
    # The keys correspond to dbt profiles and are case sensitive
    dev:
        API_INTEGRATION: AWS_CROSSCHAIN_API_STG
        EXTERNAL_FUNCTION_URI: q0bnjqvs9a.execute-api.us-east-1.amazonaws.com/stg

    prod:
        API_INTEGRATION: AWS_CROSSCHAIN_API_PROD
        EXTERNAL_FUNCTION_URI: 35hm1qhag9.execute-api.us-east-1.amazonaws.com/prod 
    ```



## **LiveQuery Functions**

LiveQuery is now available to be deployed into individual projects. For base functionality, you will need to deploy the core functions using `dbt run` in your project and reference the path to the LiveQuery schema or by tag.

### Basic Setup ###

1. Make sure `fsc-utils` package referenced in the project is version `v1.8.0` or greater. Re-run `dbt deps` if revision was changed.
2. Deploy the core LiveQuery functions by schema or tag

    By Schema
    ```
    dbt run -s livequery_models.deploy.core --vars '{UPDATE_UDFS_AND_SPS: true}'
    ```
    By Tag
    ```
    dbt run -s "livequery_models,tag:core" --vars '{UPDATE_UDFS_AND_SPS: true}'
    ```
3. Deploy any additional functions

    For example, deploy quicknode solana nft function + any dependencies (in this case the quicknode utils function)
    ```
    dbt run -s livequery_models.deploy.quicknode.quicknode_utils__quicknode_utils livequery_models.deploy.quicknode.quicknode_solana_nfts__quicknode_utils --vars '{UPDATE_UDFS_AND_SPS: true}'
    ```
4. Override default LiveQuery configuration values by adding the below lines in the `vars` section of your project's `dbt_project.yml`

    ```
    API_INTEGRATION: '{{ var("config")[target.name]["API_INTEGRATION"] if var("config")[target.name] else var("config")["dev"]["API_INTEGRATION"] }}'
    EXTERNAL_FUNCTION_URI: '{{ var("config")[target.name]["EXTERNAL_FUNCTION_URI"] if var("config")[target.name] else var("config")["dev"]["EXTERNAL_FUNCTION_URI"] }}'
    ROLES: |
        ["INTERNAL_DEV"]
    ```

### Configuring LiveQuery API endpoints

Individual projects have the option to point to a different LiveQuery API endpoint. To do so, modify your project's `dbt_projects.yml` to include the additional configurations within the project `vars`. If no configurations are specified, the default endpoints defined in the `livequery_models` package are used.

Below is a sample configuration. The `API_INTEGRATION` and `EXTERNAL_FUNCTION_URI` should point to the specific resources deployed for your project. The `ROLES` property is a list of Snowflake role names that are granted usage to the LiveQuery functions on deployment.

```
config:
    # The keys correspond to dbt profiles and are case sensitive
    dev:
      API_INTEGRATION: AWS_MY_PROJECT_LIVE_QUERY
      EXTERNAL_FUNCTION_URI: myproject.api.livequery.com/path-to-endpoint/
      ROLES:
        - INTERNAL_DEV
```

## Snowflake Tasks for GitHub Actions

A set of macros and UDFs have been created to help with the creation of Snowflake tasks to manage runs in GitHub Actions.

### Basic Setup ###

1. Make sure `fsc-utils` package referenced in the project is version `v1.11.0` or greater. Re-run `dbt deps` if revision was changed. 
2. Make sure LiveQuery has been deployed to the project. See [LiveQuery Functions](#livequery-functions) for more information.
   > If you are using tags to run your workflows, it is highly recommend to add the project name to the tag. For example, `"ethereum_models,tag:core"` instead of `tag:core`. This will ensure that the correct workflows are being ran within your project.
3. Install the GitHub LiveQuery Functions
    ```
    dbt run -s livequery_models.deploy.marketplace.github --vars '{UPDATE_UDFS_AND_SPS: true}'
    ```
    Use `-t prod` when running in production

    GitHub secrets have been registered to the Snowflake System account, which is the user that will execute tasks. If you wish to use a different user to interact with the GitHub API, you will need to register the secrets to that user using [Ephit](https://science.flipsidecrypto.xyz/ephit).
4. Deploy UDFs from `fsc-utils` package
    ```
    dbt run-operation fsc_utils.create_udfs --vars '{UPDATE_UDFS_AND_SPS: true}'
    ```
    Use `-t prod` when running in production

    Alternatively, you can add  `{{- fsc_utils.create_udfs() -}}` to the `create_udfs` macro in your project to deploy the UDFs from `fsc-utils` on model start and when `UPDATE_UDFS_AND_SPS` is set to `True`.
5. Add `github_actions__workflows.csv` to the data folder in your project. This file will contain the list of workflows to be created. The workflow name should be the same as the name of the `.yml` file in your project. It is recommended that the file name be the same as the workflow and run name. See [Polygon](https://github.com/FlipsideCrypto/polygon-models/blob/main/data/github_actions__workflows.csv) for sample format.
    
   Seed the file into dbt 
   ```
   dbt seed -s github_actions__workflows
   ```
   Add file to `sources.yml`
   ```
   - name: github_actions
     database: {{prod_db}}
     schema: github_actions
     tables:
       - name: workflows
   ```
   If you would like to test in dev, you will need to seed your file to prod with a separate PR.

6. Add the `github_actions` folder to your project's `models` folder. This folder contains the models that will be used to create and monitor the workflows. See [Polygon](https://github.com/FlipsideCrypto/polygon-models/tree/main/models/github_actions) 
   
   Build the GitHub Actions View 
   ```
   dbt run -m models/github_actions --full-refresh
   ```
   Add `--vars '{UPDATE_UDFS_AND_SPS: true}'` if you have not already created UDFs on version `v1.11.0` or greater.

7. Add the template workflows `dbt_alter_gha_tasks.yml` and `dbt_test_tasks.yml`
   > The [alter workflow](https://github.com/FlipsideCrypto/arbitrum-models/blob/main/.github/workflows/dbt_alter_gha_task.yml) is used to `SUSPEND` or `RESUME` tasks, which you will need to do if you want to pause a workflow while merging a big PR, for example. This is intended to be ran on an ad-hoc basis.

   > The [test workflow](https://github.com/FlipsideCrypto/arbitrum-models/blob/main/.github/workflows/dbt_test_tasks.yml) is used to test the workflows. It ensures that workflows are running according to the schedule and that the tasks are completing successfully. You will want to include this workflow within `github_actions__workflows.csv`. You can change the `.yml` included in the `models/github_actions` folder to better suite your testing needs, if necessary.

8. Remove the cron schedule from any workflow `.yml` files that have been added to `github_actions__workflows.csv`, replace with workflow_dispatch:
   ```
   on:
    workflow_dispatch:
        branches:
        - "main"
   ```
9. Add the `START_GHA_TASKS` variable to `dbt_project.yml`
   ```
   START_GHA_TASKS: False
   ``````
10. Create the Tasks
    ```
    dbt run-operation fsc_utils.create_gha_tasks --vars '{"START_GHA_TASKS":True}'
    ```
    > This will create the tasks in Snowflake and the workflows in GitHub Actions. The tasks will only be started if `START_GHA_TASKS` is set to `True` and the target is the production database for your project.

11. Add a Data Dog CI Pipeline Alert on the logs of `dbt_test_tasks` to ensure that the test is checking the workflows successfully. See `Polygon Task Alert` in Data Dog for sample alert.

## Dynamic Merge Predicate

A set of macros to help with generating dynamic merge predicate statements for models in chain projects. Specifically this will output a concatenanted set of BETWEEN statements of contiguous ranges.

### Setup and Usage ###

The macro only supports generating predicates for column types of DATE and INTEGER

  1. Make sure fsc-utils package referenced in the project is version `v1.16.1` or greater. Re-run dbt deps if revision was changed.

#### Inline Usage ####

    {% set between_stmts = fsc_utils.dynamic_range_predicate("silver.my_temp_table", "block_timestamp::date") %}
    
    ...

    SELECT 
        *
    FROM 
        some_other_table
    WHERE 
        {{ between_stmts }}

#### DBT Snowflake incremental_predicate Usage ####

 1. Requires overriding behavior of `get_merge_sql` macro

 2. Create a file in `macros/dbt/` ex: `macros/dbt/get_merge.sql`

 3. Copy this to the new file
    ```
    {% macro get_merge_sql(target, source, unique_key, dest_columns, incremental_predicates) -%}
        {% set merge_sql = fsc_utils.get_merge_sql(target, source, unique_key, dest_columns, incremental_predicates) %}
        {{ return(merge_sql) }}
    {% endmacro %}
    ```
    **NOTE**:  This is backwards compatible with the default dbt merge behavior, however it does override the default macro. If additional customization is needed, the above macro should be modified.
    
4. Example usage to create predicates using block_id
    ```
    {{ config(
        ...
        incremental_predicates = ["dynamic_range_predicate", "block_id"],
        ...
    ) }}
    ```
    Example Output:  ```(DBT_INTERNAL_DEST.block_id between 100 and 200 OR DBT_INTERNAL_DEST.block_id between 100000 and 150000)```

## Resources

* Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
* Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
* Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
* Find [dbt events](https://events.getdbt.com) near you
* Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
