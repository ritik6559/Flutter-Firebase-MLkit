// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:image_picker/image_picker.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String selectedItem = '';

  File? pickedImage;
  var imageFile;

  var result = '';

  bool isImageLoaded = false;
  bool isFaceDetected = false;

  List<Rect> rect = [];

  getImageFromGallery() async {
    final ImagePicker imagePicker = ImagePicker();
    var tempStore = await imagePicker.pickImage(source: ImageSource.gallery);

    imageFile = await tempStore!.readAsBytes();
    imageFile = await decodeImageFromList(imageFile);

    setState(() {
      pickedImage = File(tempStore.path);
      isImageLoaded = true;
      isFaceDetected = false;

      imageFile = imageFile;
    });
  }

  Future<void> readTextfromanImage() async {
    if (pickedImage == null) return;
    result = '';

    final GoogleVisionImage visionImage =
        GoogleVisionImage.fromFile(pickedImage!);
    final TextRecognizer textRecognizer =
        GoogleVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    String text = '';
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        text += '${line.text}\n';
      }
    }

    setState(() {
      result = text;
    });

    textRecognizer.close();
  }

  decodeBarCode() async {
    result = '';
    GoogleVisionImage myImage = GoogleVisionImage.fromFile(pickedImage!);
    BarcodeDetector barcodeDetector = GoogleVision.instance.barcodeDetector();
    List<Barcode> barCodes = await barcodeDetector.detectInImage(myImage);

    for (Barcode readableCode in barCodes) {
      setState(() {
        result = readableCode.displayValue!;
      });
    }
  }

  Future labelsread() async {
    print("yo");
    result = '';
    GoogleVisionImage myImage = GoogleVisionImage.fromFile(pickedImage!);
    final ImageLabeler labeler = GoogleVision.instance.imageLabeler();
    final List<ImageLabel> labels = await labeler.processImage(myImage);

    for (ImageLabel label in labels) {
      print("yes");
      final String text = label.text.toString();
      final double confidence = label.confidence!;
      setState(() {
        result = result + ' ' + ' $text     $confidence\n';
      });
      print(text);
    }
  }

  Future detectFace() async {
    result = '';
    GoogleVisionImage myImage = GoogleVisionImage.fromFile(pickedImage!);
    FaceDetector faceDetector = GoogleVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(myImage);

    if (rect.isNotEmpty) {
      rect = [];
    }

    for (Face face in faces) {
      rect.add(face.boundingBox);
    }

    setState(() {
      isFaceDetected = true;
    });
  }

  void detectMLFeature(String selectedFeature) {
    switch (selectedFeature) {
      case 'Text Scanner':
        readTextfromanImage();
        break;
      case 'Barcode Scanner':
        decodeBarCode();
        break;
      case 'Label Scanner':
        labelsread();
        break;
      case 'Face Detection':
        detectFace();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    selectedItem = ModalRoute.of(context)!.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(selectedItem),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Colors.blue,
              ),
            ),
            onPressed: getImageFromGallery,
            child: const Icon(
              Icons.add_a_photo,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),
          isImageLoaded && !isFaceDetected
              ? Center(
                  child: Container(
                    height: 250.0,
                    width: 250.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(pickedImage!), fit: BoxFit.cover)),
                  ),
                )
              : isImageLoaded && isFaceDetected
                  ? Center(
                      child: Container(
                        child: FittedBox(
                          child: SizedBox(
                            width: imageFile.width.toDouble(),
                            height: imageFile.height.toDouble(),
                            child: CustomPaint(
                              painter: FacePainter(
                                rect: rect,
                                imageFile: imageFile,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
          const SizedBox(height: 30),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                result,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => detectMLFeature(selectedItem),
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Rect> rect;
  var imageFile;

  FacePainter({
    required this.rect,
    required this.imageFile,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    for (Rect rectange in rect) {
      canvas.drawRect(
        rectange,
        Paint()
          ..color = Colors.teal
          ..strokeWidth = 12.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
