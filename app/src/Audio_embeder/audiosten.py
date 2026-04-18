import algorithms.image_lsb_audio_steganography as audiosten
import os

# grab all the needed vars from environment variables
imagePath = os.getenv("IMAGE_PATH")
audioPath = os.getenv("AUDIO_PATH")
decodePath = os.getenv("DECODE_PATH")
mode = os.getenv("MODE")

# encoding mode
if mode == "e":
    audiosten.encode(imagePath, "pysten_output.png", audioPath)
    print("saved image to "+os.getcwd())

# decoding mode
if mode == "d":
    path = audiosten.decode(decodePath)
    print("saved audio to " + path)