{% macro python_hex_to_int() %}
def hex_to_int(hex) -> str:
    """
    Converts hex (of any size) to int (as a string). Snowflake and java script can only handle up to 64-bit (38 digits of precision)
    hex_to_int('200000000000000000000000000000211');
    >> 680564733841876926926749214863536423441
    hex_to_int('0x200000000000000000000000000000211');
    >> 680564733841876926926749214863536423441
    hex_to_int(NULL);
    >> NULL
    """
    try:
        return str(int(hex, 16)) if hex and hex != "0x" else None
    except:
        return None
{% endmacro %}


{% macro python_udf_hex_to_int_with_encoding() %}
def hex_to_int(encoding, hex) -> str:
    """
    Converts hex (of any size) to int (as a string). Snowflake and java script can only handle up to 64-bit (38 digits of precision)
    hex_to_int('hex', '200000000000000000000000000000211');
    >> 680564733841876926926749214863536423441
    hex_to_int('hex', '0x200000000000000000000000000000211');
    >> 680564733841876926926749214863536423441
    hex_to_int('hex', NULL);
    >> NULL
    hex_to_int('s2c', 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffe5b83acf');
    >> -440911153
    """
    try:
        if not hex:
            return None
        if encoding.lower() == 's2c':
            if hex[0:2].lower() != '0x':
                hex = f'0x{hex}'

            bits = len(hex[2:]) * 4
            value = int(hex, 0)
            if value & (1 << (bits - 1)):
                value -= 1 << bits
            return str(value)
        else:
            return str(int(hex, 16))
    except:
        return None
{% endmacro %}

{% macro create_udf_keccak256() %}
from Crypto.Hash import keccak

def udf_encode(event_name):
    keccak_hash = keccak.new(digest_bits=256)
    keccak_hash.update(event_name.encode('utf-8'))
    return '0x' + keccak_hash.hexdigest()
{% endmacro %}

{% macro create_udf_evm_text_signature() %}

def get_simplified_signature(abi):
    def generate_signature(inputs):
        signature_parts = []
        for input_data in inputs:
            if 'components' in input_data:
                component_signature_parts = []
                components = input_data['components']
                component_signature_parts.extend(generate_signature(components))
                component_signature_parts[-1] = component_signature_parts[-1].rstrip(",")
                if input_data['type'].endswith('[]'):
                    signature_parts.append("(" + "".join(component_signature_parts) + ")[],")
                else:
                    signature_parts.append("(" + "".join(component_signature_parts) + "),")
            else:
                signature_parts.append(input_data['type'].replace('enum ', '').replace(' payable', '') + ",")
        return signature_parts

    signature_parts = [abi['name'] + "("]
    signature_parts.extend(generate_signature(abi['inputs']))
    signature_parts[-1] = signature_parts[-1].rstrip(",") + ")"
    return "".join(signature_parts)
{% endmacro %}


{% macro python_object_to_url_query_string() %}
import urllib.parse

def object_to_url_query_string(variant_object):
    params = f'?{urllib.parse.urlencode(variant_object)}'
    if params == '?':
        return ''
    return params

{% endmacro %}

{% macro python_udf_evm_transform_log(schema) %}
from copy import deepcopy

def transform_event(event: dict):
    new_event = deepcopy(event)
    if new_event.get("components"):
        components = new_event.get("components")
        for iy, y in enumerate(new_event["value"]):
            for i, c in enumerate(components):
                y[i] = {"value": y[i], **c}
            new_event["value"][iy] = {z["name"]: z["value"] for z in y}
        return new_event
    else:
        return event


def transform(events: list):
    try:
        results = [
            transform_event(event) if event["decoded"] else event
            for event in events["data"]
        ]
        events["data"] = results
        return events
    except:
        return events

{% endmacro %}