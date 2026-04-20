from text_exec import *
import os
from pathlib import Path
print("Hello! Starting to encode your file!")
try:
    # input vars
    publicText = os.getenv("PUBLIC_TEXT")
    secretText = os.getenv("SECRET_TEXT")

    # output vars
    inputText = os.getenv("INPUT_TEXT")
    inputTextFile = os.getenv("INPUT_TEXT_FILE")

    mode = os.getenv("MODE")

    finalText = ""

    if mode == "e":
        finalText = encode_text(publicText, secretText)

    if mode == "d":
        if inputText == "":
            inputText = read_from_file(inputTextFile)
        finalText = decode_text(inputText)

    if finalText == "" or finalText == None:
        finalText = "No secret text found!"

    save_to_file("outputFile.txt", finalText)

except Exception as e:
    print(e)