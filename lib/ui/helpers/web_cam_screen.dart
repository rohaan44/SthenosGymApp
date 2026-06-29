import 'package:app/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WebCameraScreen extends StatefulWidget {
  const WebCameraScreen({super.key});

  @override
  State<WebCameraScreen> createState() => _WebCameraScreenState();
}

class _WebCameraScreenState extends State<WebCameraScreen> {
  late CameraController controller;
  bool isInitialized = false;
  int cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    controller = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();

    if (mounted) {
      setState(() {
        isInitialized = true;
      });
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length <= 1) return;

    cameraIndex = (cameraIndex + 1) % cameras.length;

    await controller.dispose();

    await initializeCamera();
  }

  Future<void> capture() async {
    final file = await controller.takePicture();

    if (mounted) {
      Navigator.pop(context, file);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(controller),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                FloatingActionButton(
                  heroTag: "switch",
                  onPressed: switchCamera,
                  child: const Icon(Icons.flip_camera_ios),
                ),

                FloatingActionButton.large(
                  heroTag: "capture",
                  onPressed: capture,
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}