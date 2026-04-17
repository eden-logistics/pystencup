# Configuration constants
STANDARD_INPUT_IMAGE_PATH = "input/myphoto.png"
STANDARD_SECRET_AUDIO_PATH = "input/myaudio.wav"
OUTPUT_ENCODED_IMAGE = "output/encoded_image.png"
OUTPUT_EXTRACTED_AUDIO = "output/extracted_audio.wav"

from algorithms import image_lsb_audio_steganography

# Dictionary to store algorithms
ALGORITHMS = {
    1: {
        "name": "Image LSB Steganography (Hide Audio in Image)",
        "encode": image_lsb_audio_steganography.encode,
        "decode": image_lsb_audio_steganography.decode,
        "default_input_file": STANDARD_INPUT_IMAGE_PATH,
        "default_secret_file": STANDARD_SECRET_AUDIO_PATH,
        "default_output_file": OUTPUT_ENCODED_IMAGE,
        "default_decoded_file": OUTPUT_EXTRACTED_AUDIO,
        "carrier_type": "image",
        "payload_type": "audio",
    }
}