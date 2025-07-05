import 'package:flutter/material.dart';
import 'screens/camera_screen.dart';

const kPrimaryBlue = Color(0xFF3B82F6);
void main() {
  runApp(const SnapMealApp());
}

class SnapMealApp extends StatelessWidget {
  const SnapMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap Meal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: kPrimaryBlue,
        scaffoldBackgroundColor: const Color(0xFFF0F9FF),
      ),
      home: const CameraScreen(),
    );
  }
}
