import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:snapmeal/services/tflite_service.dart';
import 'ingredient_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  final TFLiteService _tfliteService = TFLiteService();

  bool _isCameraInitialized = false;
  bool _isModelReady = false;
  bool isDetecting = false;

  List<String> _ingredients = []; // ingredients list

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeModel();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final rearCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      rearCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  Future<void> _initializeModel() async {
    await _tfliteService.init();
    if (mounted && _tfliteService.isReady) {
      setState(() => _isModelReady = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Failed to load TFLite model')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_cameraController.value.isInitialized || isDetecting) return;

    setState(() => isDetecting = true);
    try {
      final file = await _cameraController.takePicture();
      final imageBytes = await file.readAsBytes();
      final predictions = await _tfliteService.classifyImage(imageBytes);

      if (!mounted) return;

      final updatedIngredients = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (_) => IngredientsScreen(
            predictions: predictions,
            existingIngredients: _ingredients,
          ),
        ),
      );

      if (updatedIngredients != null) {
        setState(() {
          _ingredients = updatedIngredients;
        });
      }
    } catch (e) {
      log('Error taking picture: $e', emoji: '❌');
    } finally {
      if (mounted) setState(() => isDetecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F3),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300, width: 4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _isCameraInitialized
                      ? CameraPreview(_cameraController)
                      : const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _isModelReady ? _takePicture : null,
                  icon: const Icon(LucideIcons.camera),
                  label: Text(_isModelReady ? "Take Photo" : "Loading Model…"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📷 Upload not implemented yet'),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.upload),
                  label: const Text("Upload from Gallery"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    side: const BorderSide(width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
