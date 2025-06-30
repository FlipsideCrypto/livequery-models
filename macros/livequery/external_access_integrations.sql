{% macro create_s3_express_external_access_integration() %}
  {% set sql %}
    CREATE OR REPLACE NETWORK RULE live.s3_express_network_rule
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = (
      '*.s3express-use1-az4.us-east-1.amazonaws.com:443',
      '*.s3express-use1-az5.us-east-1.amazonaws.com:443',
      '*.s3express-use1-az6.us-east-1.amazonaws.com:443'
    );

    CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION live.s3_express_external_access_integration
    ALLOWED_NETWORK_RULES = (s3_express_network_rule)
    ENABLED = true
    ;
  {% endset %}

  {% do run_query(sql) %}
  {% do log("External S3 Express access integration successfully created", true) %}
{% endmacro %}
