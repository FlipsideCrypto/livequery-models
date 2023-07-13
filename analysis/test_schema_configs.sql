{% set all = fromyaml(config_all_blockchains_networks())  -%}

{{ all | pprint }}

{% for  v in all | selectattr("ethereum") %}
    {{ v}}
    {% for k, v2 in v | items %}
      {{ v2 }}
    {% endfor %}
{% endfor %}

