import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../screens/result.dart';
import '../models/image.dart';

class HomeScreen extends StatefulWidget {
  static final route = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();

  void takePhoto() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (!mounted) return;
    if (pickedImage != null) {
      Provider.of<ImageModel>(context, listen: false)
          .setImage(File(pickedImage.path));
      Navigator.pushNamed(context, ResultScreen.route);
    }
  }

  void pickFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (pickedImage != null) {
      Provider.of<ImageModel>(context, listen: false)
          .setImage(File(pickedImage.path));
      Navigator.pushNamed(context, ResultScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Brain Tumor Detection using YOLO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue),
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                ),
              ),
              onPressed: takePhoto,
              child: Text(
                'Take a photo',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue),
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                ),
              ),
              onPressed: pickFromGallery,
              child: Text(
                'Pick from gallery',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
