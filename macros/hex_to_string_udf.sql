{% macro create_udf_hex_to_string(schema) %}
CREATE OR REPLACE FUNCTION {{ schema }}.udf_hex_to_string(hex STRING)
  RETURNS TEXT
  LANGUAGE SQL 
  STRICT IMMUTABLE AS
$$
    SELECT
      LTRIM(regexp_replace(
        try_hex_decode_string(hex),
          '[\x00-\x1F\x7F-\x9F\xAD]', '', 1))
$$;
{% endmacro %}