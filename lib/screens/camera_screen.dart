import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:snapmeal/services/tflite_service.dart';
import 'ingredient_screen.dart';

const kPrimaryBlue = Color(0xFF3B82F6);

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  final TFLiteService _tfliteService = TFLiteService();

  bool _isCameraInitializing = false;
  bool _isCameraInitialized = false;
  bool _isModelReady = false;
  bool isDetecting = false;

  List<String> _ingredients = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeModel();
  }

  Future<void> _initializeCamera() async {
    if (_isCameraInitializing) return;
    _isCameraInitializing = true;

    try {
      if (_isCameraInitialized && _cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
        _isCameraInitialized = false;
      }

      final cameras = await availableCameras();
      final rearCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      _cameraController = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize camera: $e');
    } finally {
      _isCameraInitializing = false;
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
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        isDetecting)
      return;

    setState(() => isDetecting = true);
    try {
      final file = await _cameraController!.takePicture();
      final imageBytes = await file.readAsBytes();
      final predictions = await _tfliteService.classifyImage(imageBytes);

      await _cameraController!.dispose();
      _cameraController = null;
      _isCameraInitialized = false;

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

      await _initializeCamera();
    } catch (e) {
      debugPrint('❌ Error taking picture: $e');
    } finally {
      if (mounted) setState(() => isDetecting = false);
    }
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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
                const SizedBox(height: 4),
                const Text(
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
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300, width: 4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _isCameraInitialized && _cameraController != null
                      ? CameraPreview(_cameraController!)
                      : const Center(
                          child: CircularProgressIndicator(color: kPrimaryBlue),
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
                  onPressed: _isModelReady ? _takePicture : null,
                  icon: const Icon(LucideIcons.camera),
                  label: Text(_isModelReady ? "Take Photo" : "Loading Model…"),
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
                    if (_cameraController != null) {
                      await _cameraController!.dispose();
                      _cameraController = null;
                      _isCameraInitialized = false;
                    }

                    final updatedIngredients =
                        await Navigator.push<List<String>>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IngredientsScreen(
                              predictions: [],
                              existingIngredients: _ingredients,
                            ),
                          ),
                        );

                    if (updatedIngredients != null) {
                      setState(() {
                        _ingredients = updatedIngredients;
                      });
                    }

                    await _initializeCamera();
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
