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
from urllib.parse import urlencode

def object_to_url_query_string(query, doseq=False):
    {# return type(query) #}
    if isinstance(query, dict):
        return urlencode(query, doseq)
    return urlencode([tuple(i) for i in query], doseq)

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

{% macro create_udf_base58_to_hex() %}

def transform_base58_to_hex(base58):
    if base58 is None:
        return 'Invalid input'

    ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    base_count = len(ALPHABET)

    num = 0
    leading_zeros = 0

    for char in base58:
        if char == '1':
            leading_zeros += 1
        else:
            break

    for char in base58:
        num *= base_count
        if char in ALPHABET:
            num += ALPHABET.index(char)
        else:
            return 'Invalid character in input'

    hex_string = hex(num)[2:]

    if len(hex_string) % 2 != 0:
        hex_string = '0' + hex_string

    hex_leading_zeros = '00' * leading_zeros

    return '0x' + hex_leading_zeros + hex_string

{% endmacro %}

{% macro create_udf_hex_to_base58() %}

def transform_hex_to_base58(hex):
    if hex is None or not hex.startswith('0x'):
        return 'Invalid input'

    hex = hex[2:]

    ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    byte_array = bytes.fromhex(hex)
    num = int.from_bytes(byte_array, 'big')

    encoded = ''
    while num > 0:
        num, remainder = divmod(num, 58)
        encoded = ALPHABET[remainder] + encoded

    for byte in byte_array:
        if byte == 0:
            encoded = '1' + encoded
        else:
            break

    return encoded

{% endmacro %}

{% macro create_udf_hex_to_bech32() %}

def transform_hex_to_bech32(hex, hrp=''):
    CHARSET = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"

    def bech32_polymod(values):
        generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
        checksum = 1
        for value in values:
            top = checksum >> 25
            checksum = ((checksum & 0x1ffffff) << 5) ^ value
            for i in range(5):
                checksum ^= generator[i] if ((top >> i) & 1) else 0
        return checksum

    def bech32_hrp_expand(hrp):
        return [ord(x) >> 5 for x in hrp] + [0] + [ord(x) & 31 for x in hrp]

    def bech32_create_checksum(hrp, data):
        values = bech32_hrp_expand(hrp) + data
        polymod = bech32_polymod(values + [0, 0, 0, 0, 0, 0]) ^ 1
        return [(polymod >> 5 * (5 - i)) & 31 for i in range(6)]

    def bech32_convertbits(data, from_bits, to_bits, pad=True):
        acc = 0
        bits = 0
        ret = []
        maxv = (1 << to_bits) - 1
        max_acc = (1 << (from_bits + to_bits - 1)) - 1
        for value in data:
            acc = ((acc << from_bits) | value) & max_acc
            bits += from_bits
            while bits >= to_bits:
                bits -= to_bits
                ret.append((acc >> bits) & maxv)
        if pad and bits:
            ret.append((acc << (to_bits - bits)) & maxv)
        return ret

    if hex is None or not hex.startswith('0x'):
        return 'Invalid input'

    hex = hex[2:]

    data = bytes.fromhex(hex)
    data5bit = bech32_convertbits(list(data), 8, 5)

    if data5bit is None:
        return 'Data conversion failed'

    checksum = bech32_create_checksum(hrp, data5bit)
    
    return hrp + '1' + ''.join([CHARSET[d] for d in data5bit + checksum])

{% endmacro %}

{% macro create_udf_int_to_binary() %}

def int_to_binary(num):
    num = int(num)
    is_negative = num < 0
    if is_negative:
        num = -num

    binary_string = bin(num)[2:]

    if is_negative:
        inverted_string = "".join("1" if bit == "0" else "0" for bit in binary_string)

        carry = 1
        result = ""
        for i in range(len(inverted_string) - 1, -1, -1):
            if inverted_string[i] == "1" and carry == 1:
                result = "0" + result
            elif inverted_string[i] == "0" and carry == 1:
                result = "1" + result 
                carry = 0
            else:
                result = inverted_string[i] + result

        binary_string = result 

    return binary_string 

{% endmacro %}

{% macro create_udf_binary_to_int() %}

def binary_to_int(binary):

  for char in binary:
    if char not in "01":
      raise ValueError("Input string must be a valid binary string.")
      
  integer = 0

  for i, digit in enumerate(binary[::-1]):
    digit_int = int(digit)

    integer += digit_int * 2**i

  return str(integer)
    
{% endmacro %}