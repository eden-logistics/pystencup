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
        '/image_to_image_encode': (context) => const MyApp(),
        '/image_to_image_decode': (context) => const ImageDecode(),
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
                Navigator.pushNamed(context, '/image_to_image_encode');
              },
              child: const Text("Image > Image Encoding"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/image_to_image_decode');
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

// ---------------------------
// IMAGE TO IMAGE ENCODE PAGE
// ---------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steganography Tool',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Image > Image Encoding'),
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
  File? _finalImage;
  final _picker = ImagePicker();

  // var for removing the generate button while the image is baking
  var _isGenerating = false;

  // function to select secret image
  void _pickSecret() async {
    _secretImage = await _pickImage();
    setState(() {});
  }

  // function to select public image
  void _pickPublic() async {
    _publicImage = await _pickImage();
    setState(() {});
  }

  // helper function for picking an image
  Future<File> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return File(pickedFile!.path);
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
      _isGenerating = true;
      _finalImage = null;
      setState(() {});
      await SeriousPython.run(
        "app/app.zip",
        appFileName: "Image_embedder/imagesten.py",
        environmentVariables: {
          "PUBLIC_IMAGE_PATH": _publicImage!.path,
          "SECRET_IMAGE_PATH": _secretImage!.path,
          "DECODE_IMAGE_PATH": "",
          "MODE": "e",
        },
      );
      _isGenerating = false;
      _finalImage = File(
        "/data/data/com.example.pystencup/files/flet/app/Image_embedder/pysten_output.png",
      );
      setState(() {});
    }
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

  void _downloadFile(context) async {
    if (_finalImage != null) {
      final result = await SaverGallery.saveFile(
        filePath: _finalImage!.path,
        fileName: "pysten_output.png",
        skipIfExists: false,
      );
      _showToast(context, result.toString());
      print(_finalImage!.path);
    }
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
            if (_secretImage != null && _publicImage != null && !_isGenerating)
              ElevatedButton(
                onPressed: () {
                  _genImage(context);
                },
                child: Text("Generate Image"),
              ),
            if (_finalImage != null)
              ElevatedButton(
                onPressed: () {
                  _downloadFile(context);
                },
                child: Text("Download Image"),
              ),
            SizedBox(height: 25),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/");
              },
              child: Text("Return to homescreen"),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------
// IMAGE TO IMAGE DECODE PAGE
// ---------------------------
class ImageDecode extends StatelessWidget {
  const ImageDecode({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steganography Tool',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const ImageDecodePage(title: 'Image > Image Decoding'),
    );
  }
}

class ImageDecodePage extends StatefulWidget {
  const ImageDecodePage({super.key, required this.title});

  final String title;

  @override
  State<ImageDecodePage> createState() => _ImageDecodePageState();
}

class _ImageDecodePageState extends State<ImageDecodePage> {
  // image picker vars
  File? _inputImage;
  File? _finalImage;
  final _picker = ImagePicker();

  var _isGenerating = false;

  // function to select input image
  void _pickPublic() async {
    _inputImage = await _pickImage();
    setState(() {});
  }

  // helper function for picking an image
  Future<File> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return File(pickedFile!.path);
  }

  void _genImage(BuildContext context) async {
    _isGenerating = true;
    _finalImage = null;
    setState(() {});
    await SeriousPython.run(
      "app/app.zip",
      appFileName: "Image_embedder/imagesten.py",
      environmentVariables: {
        "PUBLIC_IMAGE_PATH": "",
        "SECRET_IMAGE_PATH": "",
        "DECODE_IMAGE_PATH": _inputImage!.path,
        "MODE": "d",
      },
    );
    _isGenerating = false;
    _finalImage = File(
      "/data/data/com.example.pystencup/files/flet/app/Image_embedder/pysten_decode.png",
    );
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
    if (_finalImage != null) {
      final result = await SaverGallery.saveFile(
        filePath: _finalImage!.path,
        fileName: "pysten_decode.png",
        skipIfExists: false,
      );
    }
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
              onPressed: () {
                _pickPublic();
              },
              child: _inputImage == null
                  ? Text("Upload Image")
                  : Text("Image Uploaded!"),
            ),
            if (_inputImage != null && !_isGenerating)
              ElevatedButton(
                onPressed: () {
                  _genImage(context);
                },
                child: Text("Decode Image"),
              ),
            if (_finalImage != null)
              ElevatedButton(
                onPressed: _downloadFile,
                child: Text("Download Image"),
              ),
            SizedBox(height: 25),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/");
              },
              child: Text("Return to homescreen"),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------
// AUDIO TO IMAGE ENCODE PAGE
// ---------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steganography Tool',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Image > Image Encoding'),
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
  File? _finalImage;
  final _picker = ImagePicker();

  // var for removing the generate button while the image is baking
  var _isGenerating = false;

  // function to select secret image
  void _pickSecret() async {
    _secretImage = await _pickImage();
    setState(() {});
  }

  // function to select public image
  void _pickPublic() async {
    _publicImage = await _pickImage();
    setState(() {});
  }

  // helper function for picking an image
  Future<File> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return File(pickedFile!.path);
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
      _isGenerating = true;
      _finalImage = null;
      setState(() {});
      await SeriousPython.run(
        "app/app.zip",
        appFileName: "Image_embedder/imagesten.py",
        environmentVariables: {
          "PUBLIC_IMAGE_PATH": _publicImage!.path,
          "SECRET_IMAGE_PATH": _secretImage!.path,
          "DECODE_IMAGE_PATH": "",
          "MODE": "e",
        },
      );
      _isGenerating = false;
      _finalImage = File(
        "/data/data/com.example.pystencup/files/flet/app/Image_embedder/pysten_output.png",
      );
      setState(() {});
    }
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

  void _downloadFile(context) async {
    if (_finalImage != null) {
      final result = await SaverGallery.saveFile(
        filePath: _finalImage!.path,
        fileName: "pysten_output.png",
        skipIfExists: false,
      );
      _showToast(context, result.toString());
      print(_finalImage!.path);
    }
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
            if (_secretImage != null && _publicImage != null && !_isGenerating)
              ElevatedButton(
                onPressed: () {
                  _genImage(context);
                },
                child: Text("Generate Image"),
              ),
            if (_finalImage != null)
              ElevatedButton(
                onPressed: () {
                  _downloadFile(context);
                },
                child: Text("Download Image"),
              ),
            SizedBox(height: 25),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/");
              },
              child: Text("Return to homescreen"),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------
// AUDIO TO IMAGE DECODE PAGE
// ---------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steganography Tool',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Image > Image Encoding'),
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
  File? _finalImage;
  final _picker = ImagePicker();

  // var for removing the generate button while the image is baking
  var _isGenerating = false;

  // function to select secret image
  void _pickSecret() async {
    _secretImage = await _pickImage();
    setState(() {});
  }

  // function to select public image
  void _pickPublic() async {
    _publicImage = await _pickImage();
    setState(() {});
  }

  // helper function for picking an image
  Future<File> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return File(pickedFile!.path);
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
      _isGenerating = true;
      _finalImage = null;
      setState(() {});
      await SeriousPython.run(
        "app/app.zip",
        appFileName: "Image_embedder/imagesten.py",
        environmentVariables: {
          "PUBLIC_IMAGE_PATH": _publicImage!.path,
          "SECRET_IMAGE_PATH": _secretImage!.path,
          "DECODE_IMAGE_PATH": "",
          "MODE": "e",
        },
      );
      _isGenerating = false;
      _finalImage = File(
        "/data/data/com.example.pystencup/files/flet/app/Image_embedder/pysten_output.png",
      );
      setState(() {});
    }
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

  void _downloadFile(context) async {
    if (_finalImage != null) {
      final result = await SaverGallery.saveFile(
        filePath: _finalImage!.path,
        fileName: "pysten_output.png",
        skipIfExists: false,
      );
      _showToast(context, result.toString());
      print(_finalImage!.path);
    }
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
            if (_secretImage != null && _publicImage != null && !_isGenerating)
              ElevatedButton(
                onPressed: () {
                  _genImage(context);
                },
                child: Text("Generate Image"),
              ),
            if (_finalImage != null)
              ElevatedButton(
                onPressed: () {
                  _downloadFile(context);
                },
                child: Text("Download Image"),
              ),
            SizedBox(height: 25),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/");
              },
              child: Text("Return to homescreen"),
            ),
          ],
        ),
      ),
    );
  }
}
