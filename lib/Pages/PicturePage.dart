import 'package:duvalsx/Providers/PictureProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../Constants.dart';

class PicturePage extends StatefulWidget {
  const PicturePage({Key? key}) : super(key: key);

  @override
  State<PicturePage> createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage>{
  bool textScanning = false;

  XFile? imageFile;
  String? imagePath;

  String scannedText = "";

  @override
  void initState(){
    super.initState();
    getLastExtract();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  void deactivate() {
    if(imagePath != null){
      cacheLastExtract();
    }
    super.deactivate();
  }

  cacheLastExtract() async{
    final pictureProvider = Provider.of<PictureProvider>(context, listen: false);
    print("test:  $imagePath || $scannedText");
    await pictureProvider.setLastExtract(imagePath!, scannedText);
  }

  getLastExtract(){
    final pictureProvider = Provider.of<PictureProvider>(context, listen: false);
    pictureProvider.getLastExtract();
    setState(() {
      imagePath = pictureProvider.path;
      scannedText = pictureProvider.extract!;
    });
    print("testInit:  $imagePath || $scannedText");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: thirdcolor,
      appBar: AppBar(
        backgroundColor: thirdcolor,
        title: const Text(
          "Duvals",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'PopBold',
              fontSize: 18
          ),
        ),
        elevation: 0.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                width: MediaQuery.of(context).size.width,
                height: 300,
                decoration:
                BoxDecoration(
                  image: imagePath != null
                    ? DecorationImage(
                    image: FileImage(File(imagePath!)),
                    fit: BoxFit.fill) : null,
                    color: foothcolor,
                    borderRadius: BorderRadius.circular(5.0),
                    //border: Border.all(color: Colors.grey,)
                ),
                child: Center(
                  child: textScanning == false
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          getImage(ImageSource.gallery);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 25,
                          child: Icon(
                              Icons.image,
                              size: 30,
                              color: color2
                          ),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      InkWell(
                        onTap: (){
                          getImage(ImageSource.camera);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 25,
                          child: Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: color3
                          ),
                        ),
                      ),
                    ],
                  )
                  : const CircularProgressIndicator(),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: SelectableText(
                scannedText,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'PopBold',
                    fontSize: 14
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          textScanning = true;
          imageFile = pickedImage;
          imagePath = imageFile?.path;
        });
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      setState(() {
        textScanning = false;
        imageFile = null;
        scannedText = "Error occured while scanning";
      });
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
      }
    }
    textScanning = false;
    setState(() {});
  }
}
