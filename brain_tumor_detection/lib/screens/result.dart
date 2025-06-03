import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/image.dart';
import '../screens/home.dart';

class Prediction {
  final Rect rect;
  final String name;
  final double confidence;

  Prediction({
    required this.rect,
    required this.name,
    required this.confidence,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    final List<double> box = List<double>.from(json['bbox']);

    final double x1 = box[0];
    final double y1 = box[1];
    final double x2 = box[2];
    final double y2 = box[3];

    final double width = x2 - x1;
    final double height = y2 - y1;

    return Prediction(
      rect: Rect.fromLTWH(x1, y1, width, height),
      name: json['name'],
      confidence: json['confidence'],
    );
  }
}

class PredictionResult {
  List<Prediction> predictions;
  PredictionResult({required this.predictions});
}

class ResultScreen extends StatefulWidget {
  static final route = '/result';
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<Prediction> predictions = [];
  bool isLoading = true;
  String? errorMessage;
  ui.Image? originalImage;
  double originalImageWidth = 0;
  double originalImageHeight = 0;

  void _postImage() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final dio = Dio();
    final imageModel = Provider.of<ImageModel>(context, listen: false);

    if (imageModel.image != null) {
      FormData data = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageModel.image!.path,
            filename: "image.jpg"),
      });

      try {
        final res =
            await dio.post('${dotenv.env['API_ENDPOINT']}/predict', data: data);

        final List<dynamic> jsonList = res.data['predictions'];

        setState(() {
          predictions = jsonList.map((e) => Prediction.fromJson(e)).toList();
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _postImage();
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = Provider.of<ImageModel>(context).image;
    if (imageFile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No image selected'),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, HomeScreen.route);
                },
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detection Results'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _postImage,
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Debug Info'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Predictions: ${predictions.length}'),
                        Text('Loading: $isLoading'),
                        Text('Error: ${errorMessage ?? "None"}'),
                        Text(
                            'Original Image: ${originalImageWidth.toInt()} x ${originalImageHeight.toInt()}'),
                        SizedBox(height: 10),
                        Text('Predictions:'),
                        ...predictions.map((p) => Text(
                            '${p.name}: ${p.rect} (${(p.confidence * 100).toStringAsFixed(1)}%)')),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Uint8List>(
        future: imageFile.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final imageBytes = snapshot.data!;

          return FutureBuilder<ui.Image>(
            future: decodeImageFromList(imageBytes),
            builder: (context, imageSnapshot) {
              if (!imageSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final uiImage = imageSnapshot.data!;
              originalImageWidth = uiImage.width.toDouble();
              originalImageHeight = uiImage.height.toDouble();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final availableHeight = constraints.maxHeight;

                  // Calculate scaling to fit the image within available space while maintaining aspect ratio
                  final imageAspectRatio =
                      originalImageWidth / originalImageHeight;
                  final availableAspectRatio = availableWidth / availableHeight;

                  double displayWidth, displayHeight;
                  if (imageAspectRatio > availableAspectRatio) {
                    // Image is wider relative to available space
                    displayWidth = availableWidth;
                    displayHeight = availableWidth / imageAspectRatio;
                  } else {
                    // Image is taller relative to available space
                    displayHeight = availableHeight;
                    displayWidth = availableHeight * imageAspectRatio;
                  }

                  // Calculate scale factors
                  final scaleX = displayWidth / originalImageWidth;
                  final scaleY = displayHeight / originalImageHeight;

                  return Center(
                    child: Container(
                      margin: EdgeInsets.all(20.0),
                      width: displayWidth,
                      height: displayHeight,
                      child: Stack(
                        children: [
                          // Display the image
                          Image.memory(
                            imageBytes,
                            width: displayWidth,
                            height: displayHeight,
                            fit: BoxFit.contain,
                          ),

                          // Loading overlay
                          if (isLoading)
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                        color: Colors.white),
                                    SizedBox(height: 16),
                                    Text(
                                      'Detecting objects...',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Error overlay
                          if (errorMessage != null && !isLoading)
                            Container(
                              color: Colors.red.withOpacity(0.8),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error,
                                        color: Colors.white, size: 48),
                                    SizedBox(height: 16),
                                    Text(
                                      'Error: $errorMessage',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _postImage,
                                      child: Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Draw bounding boxes
                          if (!isLoading && errorMessage == null)
                            ...predictions.asMap().entries.map((entry) {
                              int index = entry.key;
                              Prediction prediction = entry.value;

                              final rect = prediction.rect;
                              final scaledLeft = rect.left * scaleX;
                              final scaledTop = rect.top * scaleY;
                              final scaledWidth = rect.width * scaleX;
                              final scaledHeight = rect.height * scaleY;

                              // Generate different colors for different predictions
                              final colors = [
                                Colors.red,
                                Colors.green,
                                Colors.blue,
                                Colors.orange,
                                Colors.purple,
                                Colors.yellow
                              ];
                              final color = colors[index % colors.length];

                              return Positioned(
                                left: scaledLeft,
                                top: scaledTop,
                                child: Container(
                                  width: scaledWidth,
                                  height: scaledHeight,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: color,
                                      width: 3,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Label background
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            "${prediction.name} ${(prediction.confidence * 100).toStringAsFixed(1)}%",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLoading && errorMessage == null)
                Text(
                  'Detected ${predictions.length} objects',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, HomeScreen.route);
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text('Take Another Photo'),
                      style: ButtonStyle(
                        iconColor: WidgetStateProperty.all(Colors.white),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                        padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _postImage,
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ButtonStyle(
                      iconColor: WidgetStateProperty.all(Colors.white),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                      padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
