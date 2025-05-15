import 'package:flutter/material.dart';

// Enum representing shader aspects that can be toggled
enum ShaderAspect { color, blur, image, text, noise }

// Helper extension for working with ShaderAspects
extension ShaderAspectExtension on ShaderAspect {
  String get label {
    switch (this) {
      case ShaderAspect.color:
        return 'Color';
      case ShaderAspect.blur:
        return 'Shatter';
      case ShaderAspect.image:
        return 'Image';
      case ShaderAspect.text:
        return 'Text';
      case ShaderAspect.noise:
        return 'Waves';
    }
  }

  IconData get icon {
    switch (this) {
      case ShaderAspect.color:
        return Icons.color_lens;
      case ShaderAspect.blur:
        return Icons.grain;
      case ShaderAspect.image:
        return Icons.photo_size_select_large;
      case ShaderAspect.text:
        return Icons.text_fields;
      case ShaderAspect.noise:
        return Icons.waves;
    }
  }
}
