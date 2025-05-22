import 'package:flutter/material.dart';
import '../models/effect_settings.dart';
import '../utils/logging_utils.dart';

class ImageContainer extends StatelessWidget {
  final String imagePath;
  final ShaderSettings settings;

  // Cached margin values to avoid rebuilds
  final double? cachedMargin;
  final bool? cachedFillScreen;

  const ImageContainer({
    Key? key,
    required this.imagePath,
    required this.settings,
    this.cachedMargin,
    this.cachedFillScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get the screen dimensions
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Determine if we're in Fit mode or Fill mode
        final bool isFitMode = !settings.fillScreen;

        // Get the margin setting from textLayoutSettings
        final double margin = isFitMode
            ? settings.textLayoutSettings.fitScreenMargin
            : 0.0;

        // Only log in debug mode and avoid excessive logging
        assert(() {
          // Only log if the values are different from cached values or cache is not available
          if (cachedMargin != margin ||
              cachedFillScreen != settings.fillScreen) {
            debugPrint(
              'ImageContainer: applying margin=${margin.toStringAsFixed(1)}, fillScreen=${settings.fillScreen}',
            );
          }
          return true;
        }());

        // Calculate image dimensions accounting for margins
        final double imageWidth = isFitMode
            ? screenWidth - (margin * 2)
            : screenWidth;
        final double imageHeight = isFitMode
            ? screenHeight - (margin * 2)
            : screenHeight;

        // Create the image widget
        Widget imageWidget = imagePath.isEmpty
            ? SizedBox(width: imageWidth, height: imageHeight)
            : Image.asset(
                imagePath,
                fit: settings.fillScreen ? BoxFit.cover : BoxFit.contain,
                width: imageWidth,
                height: imageHeight,
              );

        // Create a container with the proper size and padding
        return Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.black,
          padding: isFitMode ? EdgeInsets.all(margin) : EdgeInsets.zero,
          child: Center(child: imageWidget),
        );
      },
    );
  }
}
