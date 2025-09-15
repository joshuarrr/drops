import 'package:flutter/material.dart';

// Enum representing shader aspects that can be toggled
enum ShaderAspect {
  background,
  color,
  blur,
  image,
  text,
  noise,
  textfx,
  rain,
  chromatic,
  ripple,
  music,
  cymatics,
  sketch,
  edge,
}

// Helper extension for working with ShaderAspects
extension ShaderAspectExtension on ShaderAspect {
  String get label {
    switch (this) {
      case ShaderAspect.background:
        return 'BG Color';
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
      case ShaderAspect.textfx:
        return 'Text FX';
      case ShaderAspect.rain:
        return 'Rain';
      case ShaderAspect.chromatic:
        return 'Chroma';
      case ShaderAspect.ripple:
        return 'Ripple';
      case ShaderAspect.music:
        return 'Music';
      case ShaderAspect.cymatics:
        return 'Cymatics';
      case ShaderAspect.sketch:
        return 'Sketch';
      case ShaderAspect.edge:
        return 'Edge';
    }
  }

  IconData get icon {
    switch (this) {
      case ShaderAspect.background:
        return Icons.wallpaper;
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
      case ShaderAspect.textfx:
        return Icons.format_paint;
      case ShaderAspect.rain:
        return Icons.water_drop;
      case ShaderAspect.chromatic:
        return Icons.blur_on;
      case ShaderAspect.ripple:
        return Icons.water;
      case ShaderAspect.music:
        return Icons.music_note;
      case ShaderAspect.cymatics:
        return Icons.radar;
      case ShaderAspect.sketch:
        return Icons.brush;
      case ShaderAspect.edge:
        return Icons.line_weight;
    }
  }
}
