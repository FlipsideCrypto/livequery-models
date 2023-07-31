{% set schema = "alchemy_nfts" %}
{% set config = fromyaml(config_alchemy_nfts_udfs(schema_name = schema, utils_schema_name = "alchemy_utils"))  %}

    columns:
{%- for item in config -%}
    {%- set full_sig %}
        {%- for sig in item["signature"] -%}
            {%- if sig[1] == "OBJECT" -%}
                {%- if loop.index > 0 and not loop.last -%}
                {},
                {%- else-%}
                {}
                {%- endif -%}
            {%- elif sig[1] == "ARRAY" -%}
                {%- if loop.index > 0 and not loop.last  -%}
                [],
                {%- else-%}
                []
                {%- endif -%}
            {%- else -%}
                {%- if loop.index > 0 and not loop.last -%}
                '',
                {%- else-%}
                ''
                {%- endif -%}
            {%- endif -%}
        {%- endfor -%}
    {%- endset %}
      - name: {{ item["name"] | replace(schema~".", "") }}
        tests:
          - test_udf:
              args: |
                {{ full_sig}}
              expected: >
                {}
{%- endfor %}

=====================
{# {{ config | pprint}} #}

{% for item in config %}
{% if item["return_type"][0] != "VARIANT"%}
  {{ item["return_type"][0] }}
{% endif %}
{% endfor %}