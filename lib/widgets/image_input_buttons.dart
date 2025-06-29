import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

void log(String message, {String tag = 'Picker', String emoji = '📸'}) {
  debugPrint('\x1B[1;33m[$emoji $tag] $message\x1B[0m');
}

class ImageInputButtons extends StatelessWidget {
  final void Function(Uint8List) onImageSelected;

  const ImageInputButtons({super.key, required this.onImageSelected});

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      log("Camera button clicked");

      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        log("Image loaded (${bytes.lengthInBytes} bytes)");
        onImageSelected(bytes);
      } else {
        log("No image selected", emoji: '⚠️');
      }
    } catch (e) {
      log("Error: $e", emoji: '⚠️');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.camera_alt),
          label: const Text("Camera"),
          onPressed: () => _pickImage(ImageSource.camera),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.photo_library),
          label: const Text("Gallery"),
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }
}
