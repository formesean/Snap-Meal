import 'dart:typed_data';

import 'package:snapmeal/services/tflite_service.dart';

class TFLiteHandler {
  final TFLiteService _tfliteService = TFLiteService();

  bool get isModelLoaded => _tfliteService.isReady;

  Future<void> loadModel() async {
    await _tfliteService.init();
  }

  Future<List<String>> classifyImage(Uint8List imageBytes) async {
    return await _tfliteService.classifyImage(imageBytes);
  }
}

// EOF
