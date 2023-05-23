# Flipside Utility Functions

Dbt repo for managing the Flipside Utility Functions (FSC_UTILS) dbt package.

## Variables

To control the creation of UDF or SP macros with dbt run:

* UPDATE_UDFS_AND_SPS
When True, executes all macros included in the on-run-start hooks within dbt_project.yml on model run as normal
When False, none of the on-run-start macros are executed on model run

Default values are False

* Usage:
dbt run --var 'UPDATE_UDFS_AND_SPS": True'  -m ...

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
6. In the packages.yml file of your other dbt project, specify the new version of the package with:
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

## Resources

* Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
* Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
* Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
* Find [dbt events](https://events.getdbt.com) near you
* Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
