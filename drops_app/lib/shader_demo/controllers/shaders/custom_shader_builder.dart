import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

/// Simplified shader builder that uses a callback to draw with a canvas
class CustomShaderBuilder extends StatelessWidget {
  final Widget child;
  final void Function(BuildContext, ui.Image, Size, Canvas) callback;

  const CustomShaderBuilder({
    super.key,
    required this.child,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSampler(
      (image, size, canvas) => callback(context, image, size, canvas),
      child: child,
    );
  }
}
