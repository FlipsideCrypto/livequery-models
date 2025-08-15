{% macro create_s3_express_external_access_integration() %}
  {% set network_rule_sql %}
    CREATE NETWORK RULE IF NOT EXISTS s3_express_network_rule
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = (
      '*.s3express-use1-az4.us-east-1.amazonaws.com:443',
      '*.s3express-use1-az5.us-east-1.amazonaws.com:443',
      '*.s3express-use1-az6.us-east-1.amazonaws.com:443'
    )
  {% endset %}

  {% set external_access_sql %}
    CREATE EXTERNAL ACCESS INTEGRATION IF NOT EXISTS s3_express_external_access_integration
    ALLOWED_NETWORK_RULES = (s3_express_network_rule)
    ENABLED = true
  {% endset %}

  {% do run_query(use_schema_sql) %}
  {% do run_query(network_rule_sql) %}
  {% do run_query(external_access_sql) %}
{% endmacro %}
