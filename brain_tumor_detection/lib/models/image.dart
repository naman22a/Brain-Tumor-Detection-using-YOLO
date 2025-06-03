import 'dart:io';

import 'package:flutter/material.dart';

class ImageModel with ChangeNotifier {
  File? _image;

  File? get image => _image;

  void setImage(File? img) {
    _image = img;
    notifyListeners();
  }
}
