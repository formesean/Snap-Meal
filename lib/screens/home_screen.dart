import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/tflite_service.dart';
import '../widgets/image_input_buttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TFLiteService _tfliteService = TFLiteService();
  List<String> _detected = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tfliteService.init();
  }

  Future<void> _handleImage(Uint8List imageBytes) async {
    debugPrint("[SnapMeal] Handling image for classification...");
    setState(() {
      _isLoading = true;
      _detected = [];
    });

    final results = await _tfliteService.classifyImage(imageBytes);
    setState(() {
      _isLoading = false;
      _detected = results;
    });
    debugPrint("[SnapMeal] Detected ingredients: $_detected");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SnapMeal")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ImageInputButtons(onImageSelected: _handleImage),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (_detected.isNotEmpty) ...[
              const Text(
                "Detected Ingredients:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: _detected.map((e) => Chip(label: Text(e))).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
