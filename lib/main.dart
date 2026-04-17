// ALWAYS PULL BEFORE YOU PUSH

import 'package:flutter/material.dart';
import 'package:serious_python/serious_python.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';

// void main() {
//   runApp(const MyApp());
// }

// main root entry point for the app
void main() {
  runApp(
    // routes are individual pages within the app, which must be listed in here
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/image_to_image': (context) => const MyApp(),
      },
    ),
  ); //MaterialApp
}

// Homepage
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to the PystenCup!'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      ), // AppBar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/image_to_image');
              },
              child: const Text("Image > Image Encoding"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/image_to_image');
              },
              child: const Text("Image > Image Decoding"),
            ),
            SizedBox(height: 25.0),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Audio > Image Encoding"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Audio > Image Decoding"),
            ),
            SizedBox(height: 25.0),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Text > Image Encoding"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Text > Image Decoding"),
            ),
          ],
        ),
      ),
    );
  }
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
  File? _secretImage;
  File? _publicImage;
  final _picker = ImagePicker();

  // function to select secret image
  void _pickSecret() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _secretImage = File(pickedFile.path);
      setState(() {});
    }
  }

  // function to select public image
  void _pickPublic() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _publicImage = File(pickedFile.path);
      setState(() {});
    }
  }

  // helper function for picking an image
  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {});
    }
  }

  void _genImage(BuildContext context) async {
    // image objects, just using them to check that the resolution is the same
    final pubObject = await decodeImageFromList(
      _publicImage!.readAsBytesSync(),
    );
    final secObject = await decodeImageFromList(
      _secretImage!.readAsBytesSync(),
    );
    // check that images are the same resolution
    if (pubObject.width != secObject.width ||
        pubObject.height != secObject.height) {
      _showToast(context, "Error: Images must be the same resolution");
    } else {
      // run the python script
      // await SeriousPython.run();
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

  void _showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
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
              onPressed: _pickSecret,
              child: _secretImage == null
                  ? Text("Upload Secret Image")
                  : Text("Secret Image Selected!"),
            ),
            ElevatedButton(
              onPressed: _pickPublic,
              child: _publicImage == null
                  ? Text("Upload Public Image")
                  : Text("Public Image Selected!"),
            ),
            if (_secretImage != null && _publicImage != null)
              ElevatedButton(
                onPressed: () {
                  _genImage(context);
                },
                child: Text("Generate Image"),
              ),
          ],
        ),
      ),
    );
  }
}
