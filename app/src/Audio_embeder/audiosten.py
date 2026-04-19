import algorithms.image_lsb_audio_steganography as audiosten
import os

# grab all the needed vars from environment variables
imagePath = os.getenv("IMAGE_PATH")
audioPath = os.getenv("AUDIO_PATH")
decodePath = os.getenv("DECODE_PATH")
mode = os.getenv("MODE")

# imagePath = "C:\\Users\\jtmcf\\StudioProjects\\pystencup\\app\\src\\Audio_embeder\\input\\myphoto.png"
# audioPath = "C:\\Users\\jtmcf\\StudioProjects\\pystencup\\app\\src\\Audio_embeder\\input\\myaudio.wav"
# decodePath = ""
# mode = "e"

# encoding mode
if mode == "e":
    try:
        audiosten.encode(imagePath, os.getcwd()+"/pysten_output.png", audioPath)
    except Exception as e:
        print(e)

# decoding mode
if mode == "d":
    try: 
        if not os.path.exists("output"):
            os.mkdir("output")
        for file in os.scandir("output"):
            os.remove(file.path)
        path = audiosten.decode(decodePath, output_audio_path="output/outputFile")
        print("saved audio to " + path)
    except Exception as e:
        print(e)