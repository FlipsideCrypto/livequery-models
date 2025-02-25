
{{ config(
    materialized = 'view',
    grants = {'+select': fromyaml(var('ROLES'))}
) }}
SELECT '*.' || t.value AS allowed_domains
FROM table(flatten(input => {{ this.database }}.live.udf_allow_list())) AS t
ORDER BY
    split_part(allowed_domains, '.', -1),
    split_part(allowed_domains, '.', -2),
    split_part(allowed_domains, '.', -3)
