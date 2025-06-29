import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

void log(String message, {String tag = 'TFLite', String emoji = '🧠'}) {
  debugPrint('\x1B[1;36m[$emoji $tag] $message\x1B[0m');
}

class TFLiteService {
  late final Interpreter _interpreter;
  late final List<String> _labels;

  Future<void> init() async {
    log("Initializing model...");
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');
    final rawLabels = await rootBundle.loadString('assets/labels.txt');
    _labels = rawLabels.split('\n');
    log("Model and labels loaded: ${_labels.length} labels");
  }

  Future<List<String>> classifyImage(Uint8List imageBytes) async {
    log("Starting classification...");
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      log("Failed to decode image", emoji: '⚠️');
      return [];
    }

    final resized = img.copyResize(decoded, width: 513, height: 513);
    final input = Uint8List(1 * 513 * 513 * 3);
    int idx = 0;

    for (int y = 0; y < 513; y++) {
      for (int x = 0; x < 513; x++) {
        final pixel = resized.getPixelSafe(x, y); // returns PixelUint8

        input[idx++] = pixel.r.toInt();
        input[idx++] = pixel.g.toInt();
        input[idx++] = pixel.b.toInt();
      }
    }

    final output = List.generate(
      1,
      (_) => List.generate(
        513,
        (_) => List.generate(513, (_) => List.filled(26, 0.0)),
      ),
    );

    log("Running inference...");
    _interpreter.run(input.reshape([1, 513, 513, 3]), output);

    final counts = <int, int>{};
    for (var y = 0; y < 513; y++) {
      for (var x = 0; x < 513; x++) {
        final classScores = output[0][y][x]; // List<double> of length 26
        int maxIdx = 0;
        double maxVal = classScores[0];
        for (int c = 1; c < classScores.length; c++) {
          if (classScores[c] > maxVal) {
            maxVal = classScores[c];
            maxIdx = c;
          }
        }
        counts[maxIdx] = (counts[maxIdx] ?? 0) + 1;
      }
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topLabels = sorted
        .take(3)
        .map((e) => _labels[e.key])
        .where((label) => label != 'background')
        .toList();

    log("Classification complete: $topLabels", emoji: '✅');
    return topLabels;
  }
}
