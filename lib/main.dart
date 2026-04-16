// ALWAYS PULL BEFORE YOU PUSH

import 'package:flutter/material.dart';
import 'package:serious_python/serious_python.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steganography Tool',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Steganography Tool'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // image picker vars
  File? _image;
  final _picker = ImagePicker();

  // android default download dir
  final _downloadDir = "/storage/emulated/0/Download";

  // helper function for picking an image
  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {});
    }
  }

  // runs the python script for creating an image preview
  void _genPreview() async {
    // make sure the image is there
    if (_image == null) {
      throw (Stream.error("No image to make look like crap!"));
    }
    // directory where the image is / where the output is saved
    final imageDir = _image!.parent;

    // run the python file
    await SeriousPython.run(
      "app/app.zip", // directory where the app is
      appFileName: "ImagePreview.py", // python file to run
      environmentVariables: {
        // info to be passed to python
        "INPUT_IMAGE_FILEPATH": _image!.path,
        "OUTPUT_IMAGE_FILEPATH": imageDir.path,
        "OUTPUT_IMAGE_NAME": "outputImage.png",
      },
    );
    var newImage = File("${imageDir.path}/outputImage.png");
    _image = newImage;
    setState(() {});
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text("File saved to gallery"),
        action: SnackBarAction(
          label: 'Close',
          onPressed: scaffold.hideCurrentSnackBar,
        ),
      ),
    );
  }

  void _downloadFile() async {
    final result = await SaverGallery.saveFile(
      filePath: _image!.path,
      fileName: "outputImage.png",
      skipIfExists: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            ElevatedButton(
              onPressed: _genPreview,
              child: Text("Generate Preview"),
            ),
            _image == null
                ? Text("Please upload an image")
                : Image.file(_image!),
            if (_image != null)
              ElevatedButton(
                onPressed: _downloadFile,
                child: (Text("Download Output")),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _pickImage();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
