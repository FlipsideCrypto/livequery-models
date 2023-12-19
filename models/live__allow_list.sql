{{ config(
    materialized = 'view',
    grants = {'+select': fromyaml(var('ROLES'))}
) }}

select
  '*.' || t.value as ALLOWED_DOMAINS
from table(flatten(input=>{{ this.database }}.live.udf_allow_list())) t
order by
  split_part(ALLOWED_DOMAINS, '.', -1)
  ,split_part(ALLOWED_DOMAINS, '.', -2)
  ,split_part(ALLOWED_DOMAINS, '.', -3)
