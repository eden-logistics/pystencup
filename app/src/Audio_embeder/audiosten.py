import algorithms.image_lsb_audio_steganography as audiosten
import os

# grab all the needed vars from environment variables
imagePath = os.getenv("IMAGE_PATH")
audioPath = os.getenv("AUDIO_PATH")
decodePath = os.getenv("DECODE_PATH")
mode = os.getenv("MODE")

# encoding mode
if mode == "e":
    try:
        audiosten.encode(imagePath, "pysten_output.png", audioPath)
        print("saved image to "+os.getcwd())
    except Exception as e:
        print(e)

# decoding mode
if mode == "d":
    try: 
        path = audiosten.decode(decodePath, output_audio_path="output/outputFile")
        print("saved audio to " + path)
    except Exception as e:
        print(e)