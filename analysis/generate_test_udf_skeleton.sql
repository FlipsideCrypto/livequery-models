{# {% set schema = "strangelove" %}
{% set config = fromyaml(config_strangelove_udfs(schema_name = schema, utils_schema_name = "quicknode_utils"))  %}
{% set raw_test_queries %}
strangelove.get:
  - |
    'https://api.strange.love/cosmoshub/mainnet/rpc/block_by_hash'
  - |
    {
      'blockHash': '0xD70952032620CC4E2737EB8AC379806359D8E0B17B0488F627997A0B043ABDED'
    }


strangelove.post:
  - |
    'https://endpoint'
  - |
    {
      'foo': 'bar'
    }

{% endset %}
{% set test_queries = fromyaml(raw_test_queries) %}
{{ test_queries }}
{{ schema }}
_____
    columns:
{%- for item in config %}
      - name: {{ item["name"] | replace(schema~".", "") }}
        tests:
          - test_marketplace_udf:
              name: test_{{ item["name"].replace(".", "__") ~ "_status_200" }}
              args: >
                {{ test_queries[item["name"]] | join(", ") | indent(16) }}
              validations:
                - result:status_code = 200
{%- endfor %}

=====================

{{ config | pprint}}
{# {% for item in config %}
{% if item["return_type"][0] != "VARIANT"%}
  {{ item["return_type"][0] }}
{% endif %}
{% endfor %} #} #}