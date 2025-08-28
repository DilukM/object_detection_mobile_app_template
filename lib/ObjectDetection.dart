import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'BoundingBox.dart';

class ObjectDetection extends StatefulWidget {
  final CameraDescription camera;
  const ObjectDetection({super.key, required this.camera});

  @override
  _ObjectDetectionState createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  String label = '';
  double _confidence = 0.4;
  bool _isProcessingPaused = false;
  bool isInterpreterBusy = false;

  List<dynamic>? _recognitions;

  @override
  void initState() {
    super.initState();

    // Initialize camera controller
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize().then((_) async {
      await _tfLiteInit();
      if (!_isProcessingPaused) {
        await _startStreaming();
      }
    });
  }

  Future<void> _startStreaming() async {
    await _controller.startImageStream((CameraImage image) {
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    if (mounted && !_isProcessingPaused) {
      if (isInterpreterBusy) {
        return;
      }
      isInterpreterBusy = true;
      try {
        final recognitions = await _detectObjectsOnFrame(image);

        // Check if recognitions are valid and not empty
        if (recognitions != null && recognitions.isNotEmpty) {
          setState(() {
            _recognitions = recognitions;
          });
        } else {
          setState(() {
            _recognitions = [];
          });
        }
      } catch (e) {
        print('Error processing image: $e');
      } finally {
        isInterpreterBusy = false;
      }
    }
  }

  Future<List<dynamic>?> _detectObjectsOnFrame(CameraImage image) async {
    try {
      // Call the TFLite model
      final result = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResultsPerClass: 2,
        threshold: 0.4, // Adjust threshold as needed
      );

      // Check if the result is valid
      if (result != null && result.isNotEmpty) {
        return result;
      } else {
        return [];
      }
    } catch (e) {
      print('Error during object detection: $e');
      return []; // Return an empty list to prevent app crash
    }
  }

  Future<void> _tfLiteInit() async {
    try {
      String modelPath = 'assets/ssd_mobilenet.tflite';
      String labelPath = 'assets/ssd_mobilenet.txt';

      await Tflite.loadModel(
        model: modelPath,
        labels: labelPath,
        numThreads: 1,
        isAsset: true,
      );
    } catch (e) {
      print('Error loading TFLite model: $e');

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CameraPreview(_controller), // Display the camera feed

                      if (_recognitions != null)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: BoundingBoxPainter(
                              _recognitions!,
                              _controller
                                  .value
                                  .previewSize!
                                  .height, // Image width from detection
                              _controller
                                  .value
                                  .previewSize!
                                  .width, // Image height from detection
                              _confidence,
                            ),
                          ),
                        ),

                      Positioned(
                        top: 40,
                        left: 10,
                        child: IconButton(
                          onPressed: () {
                            _isProcessingPaused
                                ? Navigator.pop(context)
                                : _controller.stopImageStream().then((_) {
                                    Navigator.pop(context);
                                  });
                            setState(() {
                              _isProcessingPaused = true;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 22.0),
                          child: Text(
                            'Accuracy',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Slider(
                                inactiveColor: Colors.grey,
                                activeColor: Color.fromARGB(255, 1, 237, 13),
                                value: _confidence,
                                min: 0,
                                max: 1,
                                onChanged: (value) async {
                                  setState(() {
                                    _confidence = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              '${(_confidence * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_isProcessingPaused) {
                        _startStreaming();
                        setState(() {
                          _isProcessingPaused = false;
                        });
                      } else {
                        _controller.stopImageStream();

                        setState(() {
                          _isProcessingPaused = true;
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      height: 50,
                      width: MediaQuery.of(context).size.width / 1.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: <Color>[
                            Color.fromARGB(255, 134, 253, 144),
                            Color.fromARGB(255, 1, 237, 21),
                          ],
                          tileMode: TileMode.mirror,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _isProcessingPaused
                              ? 'Start Detection'
                              : 'Stop Detection',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}


