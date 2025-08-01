import 'package:flutter/material.dart';
import '../models/effect_settings.dart';

class ImageContainer extends StatefulWidget {
  final String imagePath;
  final ShaderSettings settings;

  const ImageContainer({
    Key? key,
    required this.imagePath,
    required this.settings,
  }) : super(key: key);

  @override
  State<ImageContainer> createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  // Cache the last built widget and the values that created it
  Widget? _cachedWidget;
  String? _lastImagePath;
  bool? _lastFillScreen;
  double? _lastMargin;
  double? _lastScreenWidth;
  double? _lastScreenHeight;

  // Static logging control to reduce noise
  static int _logCount = 0;
  static const int _maxLogs =
      2; // Only log first 2 builds to verify it's working

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final bool fillScreen = widget.settings.fillScreen;
        final double margin = fillScreen
            ? 0.0
            : widget.settings.textLayoutSettings.fitScreenMargin;

        // Check if we can use cached widget
        if (_cachedWidget != null &&
            _lastImagePath == widget.imagePath &&
            _lastFillScreen == fillScreen &&
            _lastMargin == margin &&
            _lastScreenWidth == screenWidth &&
            _lastScreenHeight == screenHeight) {
          // Return cached widget - no rebuild needed
          return _cachedWidget!;
        }

        // Log only for debugging (very limited)
        if (_logCount < _maxLogs) {
          // debugPrint(
            'ImageContainer: building new widget - margin=${margin.toStringAsFixed(1)}, fillScreen=$fillScreen',
          );
          _logCount++;
        }

        // Calculate image dimensions
        final bool isFitMode = !fillScreen;
        final double imageWidth = isFitMode
            ? screenWidth - (margin * 2)
            : screenWidth;
        final double imageHeight = isFitMode
            ? screenHeight - (margin * 2)
            : screenHeight;

        // Create the image widget
        Widget imageWidget = widget.imagePath.isEmpty
            ? SizedBox(width: imageWidth, height: imageHeight)
            : Image.asset(
                widget.imagePath,
                fit: fillScreen ? BoxFit.cover : BoxFit.contain,
                width: imageWidth,
                height: imageHeight,
              );

        // Create and cache the container
        _cachedWidget = Container(
          width: screenWidth,
          height: screenHeight,
          padding: isFitMode ? EdgeInsets.all(margin) : EdgeInsets.zero,
          child: Center(child: imageWidget),
        );

        // Update cached values
        _lastImagePath = widget.imagePath;
        _lastFillScreen = fillScreen;
        _lastMargin = margin;
        _lastScreenWidth = screenWidth;
        _lastScreenHeight = screenHeight;

        return _cachedWidget!;
      },
    );
  }
}
