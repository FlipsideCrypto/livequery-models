use database livequery_dev;

select *
from livequery.ephit;

select livequery_dev.utils.udf_register_secret( 'f01811d4-eb16-4cd6-8877-8edd1a9419df', 'YdYiXmBLQC7PtfGUQH+Z5iUSp2nmLhuNzjL4kUgB0RA=');

describe function livequery_dev._utils.udf_register_secret( varchar, varchar, varchar);

show external functions in schema _utils;

select *
from information_schema.functions
where api_integration is not null;

create or replace external function livequery_dev._utils.udf_register_secret(REQUEST_ID VARCHAR, USER_ID VARCHAR, KEY VARCHAR)
copy grants
returns object
api_integration = AWS_LIVE_QUERY_STG
  as 'https://u5z0tu43sc.execute-api.us-east-1.amazonaws.com/stg/secret/register';

  describe api integration AWS_LIVE_QUERY_STG;

  show api integrations like '%live%';

grant usage on integration AWS_LIVE_QUERY_STG to role DBT_CLOUD_LIVEQUERY;



show grants of api integratoin AWS_LIVE_QUERY_STG;

show grants on integration AWS_LIVE_QUERY_STG;
show grants on integration AWS_LIVE_QUERY_dev;


-- create or replace transient table LIVEQUERY_DEV.test_secrets.udf_create_secret
--          as
--         (


with __dbt__cte___utils as (



    SELECT '_utils' as schema_
),  __dbt__cte__utils as (
-- depends_on: __dbt__cte___utils



    SELECT 'utils' as schema_
),  __dbt__cte___live as (



    SELECT '_live' as schema_
),  __dbt__cte__live as (
-- depends_on: __dbt__cte___utils
-- depends_on: __dbt__cte__utils
-- depends_on: __dbt__cte___live



    SELECT 'live' as schema_
),  __dbt__cte__secrets as (
-- depends_on: __dbt__cte___utils
-- depends_on: __dbt__cte__live

)
select *
,;
-- test1 AS
-- (
--     SELECT 1
--         -- 'secrets.udf_create_secret' AS test_name
--         -- ,['test', {'key': 'value'}] as parameters
--         -- ,LIVEQUERY_DEV.secrets.udf_create_secret('test', {'key': 'value'}) AS result
-- )

--     SELECT
--     test_name,
--     parameters,
--     result,
--     $$result = 200$$ AS assertion,
--     $$SET LIVEQUERY_CONTEXT = '{"userId":"fda9e624-d6c9-4cf7-b38f-3c5a4cea8e2f"}';
-- SELECT LIVEQUERY_DEV.secrets.udf_create_secret('test', {'key': 'value'})
-- ;$$ AS sql
--     FROM test
--     WHERE NOT result = 200

--         -- );


show grants to role dbt_cloud_livequery;

select
*
from table(result_scan('01afe44a-0503-e7d4-3d4f-830182e9865f'))
where "granted_on" = 'WAREHOUSE';

GRANT USAGE ON WAREHOUSE DBT_CLOUD TO role dbt_cloud_livequery;