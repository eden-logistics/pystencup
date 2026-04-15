from PIL import Image
import os

def decode(secretImageFilename):
    # multiplying the secret values (0-3) will bring them back to 0-255, normalizing them
    normalizeCoeff = 85
    print("Trying to open image")
    secretImage = Image.open(secretImageFilename).convert("RGB")
    secretImageData = secretImage.getdata()
    print("flattened data!")
    decodedImageData = []

    print("actual image decoder")
    for i in range(len(secretImageData)):
        decodePixel = (
            (secretImageData[i][0]//64)*normalizeCoeff,
            (secretImageData[i][1]//64)*normalizeCoeff,
            (secretImageData[i][2]//64)*normalizeCoeff
        )
        decodedImageData.append(decodePixel)

    print("create new image object")
    returnImage = Image.new("RGB", secretImage.size)
    returnImage.putdata(decodedImageData)

    print("Return image")
    return returnImage

inputImagePath = os.getenv("INPUT_IMAGE_FILEPATH")
outputImagePath = os.getenv("OUTPUT_IMAGE_FILEPATH")
outputImageName = os.getenv("OUTPUT_IMAGE_NAME")
# print(f"Input: {inputImagePath}\nOutput: {outputImagePath}/{outputImageName}")
try:
    print("Decoding Image...")
    outputImage = decode(inputImagePath)
    print("Decoded Image!")
    outputImage.save(f"{outputImagePath}/{outputImageName}")
    print(f"saved image to {outputImagePath}/{outputImageName}!")
except Exception as e:
    print(e)