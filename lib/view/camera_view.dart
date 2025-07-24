import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:snapmeal/controllers/camera_controller.dart';
import 'package:snapmeal/controllers/tflite_controller.dart';
import 'package:snapmeal/view/ingredient_view.dart';

const kPrimaryBlue = Color(0xFF3B82F6);

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final CameraHandler _cameraHandler = CameraHandler();
  final TFLiteHandler _tfliteHandler = TFLiteHandler();

  bool isDetecting = false;
  bool isModelReady = false;
  List<String> _ingredients = [];

  Future<void>? _cameraInitFuture;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _cameraInitFuture = _cameraHandler.initializeCamera();
    await _cameraInitFuture;

    await _tfliteHandler.loadModel();
    if (mounted) {
      setState(() {
        isModelReady = _tfliteHandler.isModelLoaded;
      });
    }
  }

  Future<void> _takePicture() async {
    if (!_cameraHandler.isReady || isDetecting) return;
    setState(() => isDetecting = true);

    try {
      final file = await _cameraHandler.captureImage();
      final imageBytes = await file.readAsBytes();
      final predictions = await _tfliteHandler.classifyImage(imageBytes);

      await _cameraHandler.disposeCamera();

      if (!mounted) return;

      final updatedIngredients = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (_) => IngredientView(
            predictions: predictions,
            existingIngredients: _ingredients,
            onReset: () {
              setState(() => _ingredients = []);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      );

      if (!mounted) return;

      if (updatedIngredients != null) {
        setState(() => _ingredients = updatedIngredients);
      }

      _cameraInitFuture = _cameraHandler.initializeCamera();
      await _cameraInitFuture;

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => isDetecting = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      final predictions = await _tfliteHandler.classifyImage(imageBytes);

      // Dispose the camera before navigating
      await _cameraHandler.disposeCamera();

      final updatedIngredients = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (_) => IngredientView(
            predictions: predictions,
            existingIngredients: _ingredients,
            onReset: () {
              setState(() => _ingredients = []);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      );

      if (updatedIngredients != null && mounted) {
        setState(() => _ingredients = updatedIngredients);
      }

      // Re-initialize the camera after returning
      _cameraInitFuture = _cameraHandler.initializeCamera();
      await _cameraInitFuture;
      if (mounted) setState(() {});
    } else {
      debugPrint('🟡 No image selected.');
    }
  }

  @override
  void dispose() {
    _cameraHandler.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              children: const [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.chefHat, color: kPrimaryBlue, size: 32),
                    SizedBox(width: 8),
                    Text(
                      "SnapMeal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  "Snap ingredients, discover recipes",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300, width: 4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FutureBuilder(
                    future: _cameraInitFuture,
                    builder: (context, snapshot) {
                      final controller = _cameraHandler.controller;
                      if (snapshot.connectionState == ConnectionState.done &&
                          controller != null &&
                          controller.value.isInitialized) {
                        return CameraPreview(controller);
                      }
                      return const Center(
                        child: CircularProgressIndicator(color: kPrimaryBlue),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: isModelReady ? _takePicture : null,
                  icon: const Icon(LucideIcons.camera),
                  label: Text(isModelReady ? "Take Photo" : "Loading Model…"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: isModelReady ? _pickImageFromGallery : null,
                  icon: const Icon(LucideIcons.upload),
                  label: const Text("Upload from Gallery"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                    side: const BorderSide(color: kPrimaryBlue, width: 2),
                    foregroundColor: kPrimaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    await _cameraHandler.disposeCamera();

                    final updatedIngredients =
                        await Navigator.push<List<String>>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IngredientView(
                              predictions: [],
                              existingIngredients: _ingredients,
                              onReset: () {
                                setState(() => _ingredients = []);
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              },
                            ),
                          ),
                        );

                    if (!mounted) return;

                    if (updatedIngredients != null) {
                      setState(() => _ingredients = updatedIngredients);
                    }

                    _cameraInitFuture = _cameraHandler.initializeCamera();
                    await _cameraInitFuture;

                    if (mounted) setState(() {});
                  },
                  icon: const Icon(LucideIcons.utensils, color: kPrimaryBlue),
                  label: const Text(
                    "View Ingredients List",
                    style: TextStyle(
                      color: kPrimaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: kPrimaryBlue.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// EOF
