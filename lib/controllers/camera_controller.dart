import 'dart:typed_data';
import 'package:camera/camera.dart';

import 'package:snapmeal/services/tflite_service.dart';

class CameraHandler {
  final TFLiteService _tfliteService = TFLiteService();
  CameraController? _controller;

  bool get isReady => _controller != null && _controller!.value.isInitialized;
  CameraController? get controller => _controller;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final rearCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    _controller = CameraController(
      rearCamera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _controller!.initialize();
  }

  Future<void> disposeCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
  }

  Future<void> initializeModel() async => _tfliteService.init();

  bool get isModelReady => _tfliteService.isReady;

  Future<List<String>> predict() async {
    final file = await _controller!.takePicture();
    Uint8List bytes = await file.readAsBytes();
    return await _tfliteService.classifyImage(bytes);
  }
}

// EOF
