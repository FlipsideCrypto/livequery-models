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

## Resources

* Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
* Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
* Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
* Find [dbt events](https://events.getdbt.com) near you
* Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
