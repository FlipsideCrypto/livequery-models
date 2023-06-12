  {% set blockchain, network = "ethereum", "mainnet" %}
  CREATE SCHEMA IF NOT EXISTS {{ blockchain }}_{{ network }};
  {%-  set udfs = fromyaml(config_evm_abstractions(blockchain, network)) -%}
  {%- for udf in udfs -%}
      {{- create_or_drop_function_from_config(udf, drop_=drop_) -}}
  {%- endfor -%}