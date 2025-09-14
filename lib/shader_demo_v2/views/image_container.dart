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
  // Removed caching variables to ensure image toggling works correctly

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

        // Removed caching check to ensure image visibility toggle works correctly

        // Log only for debugging (very limited)

        // Calculate image dimensions
        final bool isFitMode = !fillScreen;
        final double imageWidth = isFitMode
            ? screenWidth - (margin * 2)
            : screenWidth;
        final double imageHeight = isFitMode
            ? screenHeight - (margin * 2)
            : screenHeight;

        // Create the image widget
        // Log the image path for debugging (disabled to prevent spam)
        // debugPrint('ImageContainer: imagePath="${widget.imagePath}"');

        // Check if the path is valid
        Widget imageWidget;
        if (widget.imagePath.isEmpty) {
          debugPrint('ImageContainer: Empty path, showing empty container');
          imageWidget = SizedBox(width: imageWidth, height: imageHeight);
        } else {
          try {
            imageWidget = Image.asset(
              widget.imagePath,
              fit: fillScreen ? BoxFit.cover : BoxFit.contain,
              width: imageWidth,
              height: imageHeight,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('ImageContainer: Error loading image: $error');
                return Container(
                  width: imageWidth,
                  height: imageHeight,
                  color: Colors.red.withOpacity(0.3),
                  child: Center(
                    child: Text(
                      'Error loading image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            );
          } catch (e) {
            debugPrint('ImageContainer: Exception loading image: $e');
            imageWidget = Container(
              width: imageWidth,
              height: imageHeight,
              color: Colors.red.withOpacity(0.3),
              child: Center(
                child: Text(
                  'Error loading image',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        }

        // Create the container with background color if enabled
        final backgroundColor = widget.settings.backgroundEnabled
            ? widget.settings.backgroundSettings.backgroundColor
            : Colors.black;

        return Container(
          width: screenWidth,
          height: screenHeight,
          color: backgroundColor,
          padding: isFitMode ? EdgeInsets.all(margin) : EdgeInsets.zero,
          child: Center(child: imageWidget),
        );
      },
    );
  }
}
