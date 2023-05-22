{% macro udf_hex_to_string(hex_string) %}
    LTRIM(regexp_replace(
        try_hex_decode_string({{ hex_string }}),
          '[\x00-\x1F\x7F-\x9F\xAD]', '', 1))
{% endmacro %}