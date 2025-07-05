import 'package:flutter/material.dart';
import 'screens/camera_screen.dart';

void main() {
  runApp(const SnapMealApp());
}

class SnapMealApp extends StatelessWidget {
  const SnapMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapMeal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
      ),
      home: const CameraScreen(),
    );
  }
}
