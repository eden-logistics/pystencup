# pystencup

A flutter app for steganography

If you're reading this, sorry for the mess.

(Everything's built off the default flutter app template with a lot of comments)

## Info
- The main frontend code is under lib/main.dart.
- Dependencies are under pubspec.yaml.
- python code is under app/src
  - if you change the python code, be sure to run `dart run serious_python:main package app/src -p Android` before building (packages the python code to be run in the app)

## To Build
You'll need
- Flutter
- Android phone OR emulator
- Probably android studio (which you'll need for the emulator anyway)

For an actual android phone plugged in via USB:
- Download flutter on your PC
- On your phone go to settings > system info > find the build number setting and tap it 7 times
  - (yes that's real and it will enable developer mode)
- plug your phone into your pc and run `flutter devices` and make sure you can see your phone on there
- run `flutter run -d [name of device]` and wait for it to build