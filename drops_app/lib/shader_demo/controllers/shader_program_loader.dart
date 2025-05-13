import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

/// Helper class to load and manage shader programs
class ShaderProgramLoader {
  // Singleton instance
  static final ShaderProgramLoader _instance = ShaderProgramLoader._internal();

  // Factory constructor
  factory ShaderProgramLoader() {
    return _instance;
  }

  // Private constructor
  ShaderProgramLoader._internal();

  // Cached shader programs
  ui.FragmentProgram? _colorShaderProgram;
  ui.FragmentProgram? _blurShaderProgram;

  // Get color shader program
  Future<ui.FragmentProgram> get colorShaderProgram async {
    if (_colorShaderProgram == null) {
      _colorShaderProgram = await ui.FragmentProgram.fromAsset(
        'assets/shaders/color_effect.frag',
      );
    }
    return _colorShaderProgram!;
  }

  // Get blur shader program
  Future<ui.FragmentProgram> get blurShaderProgram async {
    if (_blurShaderProgram == null) {
      _blurShaderProgram = await ui.FragmentProgram.fromAsset(
        'assets/shaders/blur_effect.frag',
      );
    }
    return _blurShaderProgram!;
  }
}
