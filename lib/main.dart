import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'ObjectDetection.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MainApp(camera: firstCamera));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.camera});

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ObjectDetection(camera: camera),
    );
  }
}
