import 'package:flutter/material.dart';

// Enum representing shader aspects that can be toggled
enum ShaderAspect { color, blur }

// Helper extension for working with ShaderAspects
extension ShaderAspectExtension on ShaderAspect {
  String get label {
    switch (this) {
      case ShaderAspect.color:
        return 'Color';
      case ShaderAspect.blur:
        return 'Blur';
    }
  }

  IconData get icon {
    switch (this) {
      case ShaderAspect.color:
        return Icons.color_lens;
      case ShaderAspect.blur:
        return Icons.grain;
    }
  }
}
