import 'package:flutter/material.dart';

/// Image container widget for V3 demo
class ImageContainer extends StatelessWidget {
  final String imagePath;

  const ImageContainer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Simple image display with asset path
    return Image.asset(imagePath, fit: BoxFit.contain);
  }
}
