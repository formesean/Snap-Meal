import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

void log(String message, {String tag = 'TFLite', String emoji = '🧠'}) {
  debugPrint('\x1B[1;36m[$emoji $tag] $message\x1B[0m');
}

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  int _inputSize = 224;

  bool get isReady => _interpreter != null && _labels.isNotEmpty;

  Future<void> init() async {
    try {
      log("Initializing model...");
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      final rawLabels = await rootBundle.loadString('assets/labels.txt');
      _labels = rawLabels
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();
      log("Model and labels loaded: ${_labels.length} labels");
    } catch (e) {
      log("❌ Failed to initialize TFLite model: $e", emoji: "⚠️");
    }
  }

  Future<List<String>> classifyImage(Uint8List imageBytes) async {
    if (!isReady) {
      log("❌ TFLite model is not ready yet", emoji: "🚫");
      return [];
    }

    log("Starting classification...");

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      log("Failed to decode image", emoji: '⚠️');
      return [];
    }

    final resized = img.copyResize(
      decoded,
      width: _inputSize,
      height: _inputSize,
    );
    final input = Float32List(_inputSize * _inputSize * 3);
    int idx = 0;

    // Normalize and flatten image data to [0.0, 1.0]
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixelSafe(x, y);
        input[idx++] = pixel.r / 255.0;
        input[idx++] = pixel.g / 255.0;
        input[idx++] = pixel.b / 255.0;
      }
    }

    final inputTensor = input.reshape([1, _inputSize, _inputSize, 3]);
    final outputTensor = List.filled(
      _labels.length,
      0.0,
    ).reshape([1, _labels.length]);

    log("Running inference...");
    _interpreter!.run(inputTensor, outputTensor);

    final scores = outputTensor[0] as List<double>;

    // Get top 3 predictions
    final top = scores.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topLabels = top.take(3).map((e) {
      final label = _labels[e.key];
      final confidence = (e.value * 100).toStringAsFixed(1);
      return '$label ($confidence%)';
    }).toList();

    log("Classification complete: $topLabels", emoji: '✅');
    return topLabels;
  }
}
