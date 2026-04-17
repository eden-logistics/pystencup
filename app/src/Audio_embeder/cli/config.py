import os
from algorithms import image_lsb_audio_steganography

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(BASE_DIR)

CONFIG = {
    "name": "Image LSB Steganography (Hide Audio in Image)",
    "encode": image_lsb_audio_steganography.encode,
    "decode": image_lsb_audio_steganography.decode,
    "default_input_file": os.path.join(PROJECT_ROOT, "input", "myphoto.png"),
    "default_secret_file": os.path.join(PROJECT_ROOT, "input", "myaudio.wav"),
    "default_output_file": os.path.join(PROJECT_ROOT, "output", "encoded_image.png"),
    "default_decoded_file": os.path.join(PROJECT_ROOT, "output", "extracted_audio.wav"),
}