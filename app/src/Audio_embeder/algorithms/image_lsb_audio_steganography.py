import os
import struct
from PIL import Image
from utils.logging_util import setup_logger

logger = setup_logger(__name__)

MAGIC = b"ASTEG"  # Audio STEGanography marker


def bytes_to_bits(data: bytes) -> str:
    """Convert bytes to a string of bits."""
    return ''.join(f'{byte:08b}' for byte in data)


def bits_to_bytes(bits: str) -> bytes:
    """Convert a string of bits back to bytes."""
    if len(bits) % 8 != 0:
        raise ValueError("Bit string length must be a multiple of 8.")
    return bytes(int(bits[i:i + 8], 2) for i in range(0, len(bits), 8))


def build_payload(audio_bytes: bytes, extension: str) -> bytes:
    """
    Build payload format:
    [MAGIC:5 bytes][AUDIO_LEN:4 bytes][EXT_LEN:1 byte][EXT bytes][AUDIO bytes]
    """
    ext_bytes = extension.encode("utf-8")

    if len(ext_bytes) > 255:
        raise ValueError("File extension is too long.")

    return MAGIC + struct.pack(">I", len(audio_bytes)) + bytes([len(ext_bytes)]) + ext_bytes + audio_bytes


def parse_header_from_bits(bitstream: str):
    """
    Parse the payload header from a bitstream.

    Returns:
        audio_length (int)
        extension (str)
        payload_start_bit_index (int)
    """
    magic_bits_len = 5 * 8
    length_bits_len = 4 * 8
    ext_len_bits_len = 1 * 8

    header_min_bits = magic_bits_len + length_bits_len + ext_len_bits_len
    if len(bitstream) < header_min_bits:
        raise ValueError("Bitstream is too short to contain a valid header.")

    magic = bits_to_bytes(bitstream[:magic_bits_len])
    if magic != MAGIC:
        raise ValueError("No hidden audio payload found in this image.")

    start = magic_bits_len
    end = start + length_bits_len
    audio_length = struct.unpack(">I", bits_to_bytes(bitstream[start:end]))[0]

    start = end
    end = start + ext_len_bits_len
    ext_len = bits_to_bytes(bitstream[start:end])[0]

    ext_bits_len = ext_len * 8
    start = end
    end = start + ext_bits_len

    if len(bitstream) < end:
        raise ValueError("Bitstream ended before extension data was complete.")

    extension = bits_to_bytes(bitstream[start:end]).decode("utf-8") if ext_len > 0 else ""

    payload_start_bit_index = end
    return audio_length, extension, payload_start_bit_index


def encode(input_file_path, output_file_path, secret_audio_path):
    """
    Hide an audio file inside a PNG image using 1 LSB per RGB channel.

    :param input_file_path: Path to carrier image
    :param output_file_path: Path to output encoded image
    :param secret_audio_path: Path to secret audio file
    """
    try:
        logger.info("Encoding starts...")

        if not os.path.exists(input_file_path):
            raise FileNotFoundError(f"Carrier image not found: {input_file_path}")

        if not os.path.exists(secret_audio_path):
            raise FileNotFoundError(f"Secret audio file not found: {secret_audio_path}")

        image = Image.open(input_file_path).convert("RGB")
        width, height = image.size

        with open(secret_audio_path, "rb") as audio_file:
            audio_bytes = audio_file.read()

        extension = os.path.splitext(secret_audio_path)[1].lower().lstrip(".")
        payload = build_payload(audio_bytes, extension)
        payload_bits = bytes_to_bits(payload)

        capacity_bits = width * height * 3
        required_bits = len(payload_bits)

        logger.info(f"Image capacity: {capacity_bits} bits")
        logger.info(f"Required capacity: {required_bits} bits")

        if required_bits > capacity_bits:
            raise ValueError(
                "The secret audio file is too large to fit inside this image."
            )

        pixels = list(image.getdata())
        flat_channels = []

        for pixel in pixels:
            flat_channels.extend(pixel[:3])

        for i, bit in enumerate(payload_bits):
            flat_channels[i] = (flat_channels[i] & 0xFE) | int(bit)

        new_pixels = [
            tuple(flat_channels[i:i + 3])
            for i in range(0, len(flat_channels), 3)
        ]

        encoded_image = Image.new("RGB", (width, height))
        encoded_image.putdata(new_pixels)

        os.makedirs(os.path.dirname(output_file_path), exist_ok=True)

        # Always save as PNG to preserve LSB data
        if not output_file_path.lower().endswith(".png"):
            logger.warning("Output file extension changed to .png for safe lossless storage.")
            output_file_path = os.path.splitext(output_file_path)[0] + ".png"

        encoded_image.save(output_file_path, "PNG")
        logger.info(f"Successfully encoded audio into image: {output_file_path}")

    except Exception as e:
        logger.error(f"Error during encoding: {e}")


def decode(input_file_path, output_audio_path=None):
    """
    Extract hidden audio from an encoded image.

    :param input_file_path: Path to encoded image
    :param output_audio_path: Optional output audio path
    :return: Saved output path if successful, else None
    """
    try:
        logger.info("Decoding starts...")

        if not os.path.exists(input_file_path):
            raise FileNotFoundError(f"Encoded image not found: {input_file_path}")

        image = Image.open(input_file_path).convert("RGB")
        pixels = list(image.getdata())

        flat_channels = []
        for pixel in pixels:
            flat_channels.extend(pixel[:3])

        bitstream = ''.join(str(channel & 1) for channel in flat_channels)

        audio_length, extension, payload_start_bit_index = parse_header_from_bits(bitstream)

        audio_bits_len = audio_length * 8
        payload_end_bit_index = payload_start_bit_index + audio_bits_len

        if payload_end_bit_index > len(bitstream):
            raise ValueError("Encoded image does not contain the full hidden audio payload.")

        audio_bits = bitstream[payload_start_bit_index:payload_end_bit_index]
        audio_bytes = bits_to_bytes(audio_bits)

        if output_audio_path is None or not output_audio_path.strip():
            ext = extension if extension else "bin"
            output_audio_path = f"output/extracted_audio.{ext}"
        else:
            # If user gave a path without extension, append the recovered one
            base, current_ext = os.path.splitext(output_audio_path)
            if not current_ext and extension:
                output_audio_path = f"{output_audio_path}.{extension}"

        os.makedirs(os.path.dirname(output_audio_path), exist_ok=True)

        with open(output_audio_path, "wb") as output_file:
            output_file.write(audio_bytes)

        logger.info(f"Successfully extracted hidden audio to: {output_audio_path}")
        return output_audio_path

    except Exception as e:
        logger.error(f"Error during decoding: {e}")
        return None