from PIL import Image
import os

# brings each pixel from 0-255 to 0-3, in preparation for encoding
# // performs integer division, effectively chopping off any decimals
def downgrade_color_depth(imageData):
    newImageData = []           # create new empty array
    for pixel in imageData:
        newImageData.append((   # modify the pixel data and copy it to the new array
            pixel[0]//64,   # red component
            pixel[1]//64,   # green component
            pixel[2]//64    # blue component
        ))
    return newImageData

def bincode(bignum, smallnum):
    if (smallnum > 3):
        # 3 is the max value that can be stored in 2 bits
        raise ValueError("smallnum must be 3 or less")
    if (bignum > 255):
        raise ValueError("bignum must be 255 or less")

    bigbin = format(bignum, '08b')      # formats bignum as 8 bits (w/ leading 0s if needed)
    smallbin = format(smallnum, '02b')  # formats smallnum as 2 bits (also w/ leading 0s)
    newbin = bigbin[:6]+smallbin        # replaces the last 2 bits of bigbin with smallbin
    return int(newbin, 2)               # returns the binary value as an integer

def binextract(value):
    if (value > 255):
        raise ValueError("value must be 255 or less")

    binvalue = format(value, "08b")     # converts the integer value to an 8 bit binary string
    secretvalue = binvalue[-2:]         # gets the last two bits from the string
    return int(secretvalue, 2)          # returns the last two bits as an integer

def encode(publicImageFilename, privateImageFilename):
    publicImage = Image.open(publicImageFilename)
    privateImage = Image.open(privateImageFilename)

    publicImageData = publicImage.get_flattened_data()
    privateImageData = privateImage.get_flattened_data()

    privateDowngrade = downgrade_color_depth(privateImageData)
    encodedImageData = []
    for i in range(len(publicImageData)):
        newPixel = (
            bincode(publicImageData[i][0], privateDowngrade[i][0]),
            bincode(publicImageData[i][1], privateDowngrade[i][1]),
            bincode(publicImageData[i][2], privateDowngrade[i][2])
        )
        encodedImageData.append(newPixel)

    returnImage = Image.new("RGB", publicImage.size)
    returnImage.putdata(encodedImageData)

    return returnImage

def decode(secretImageFilename):
    # multiplying the secret values (0-3) will bring them back to 0-255, normalizing them
    normalizeCoeff = 85

    secretImage = Image.open(secretImageFilename)
    secretImageData = secretImage.get_flattened_data()
    decodedImageData = []

    for i in range(len(secretImageData)):
        decodePixel = (
            binextract(secretImageData[i][0])*normalizeCoeff,
            binextract(secretImageData[i][1])*normalizeCoeff,
            binextract(secretImageData[i][2])*normalizeCoeff
        )
        decodedImageData.append(decodePixel)

    returnImage = Image.new("RGB", secretImage.size)
    returnImage.putdata(decodedImageData)

    return returnImage

# grab all the needed vars from environment variables
pubImagePath = os.getenv("PUBLIC_IMAGE_PATH")
secImagePath = os.getenv("SECRET_IMAGE_PATH")
decImagePath = os.getenv("DECODE_IMAGE_PATH")
mode = os.getenv("MODE")

# encoding mode
if mode == "e":
    encodedImage = encode(pubImagePath, secImagePath)
    encodedImage.save(pubImagePath+"_pysten")

# decoding mode
if mode == "d":
    decodedImage = decode(decImagePath)
    decodedImage.save(decImagePath+"_decoded")