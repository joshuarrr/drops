import 'package:flutter/material.dart';
import '../models/effect_settings.dart';

class ImageContainer extends StatelessWidget {
  final String imagePath;
  final ShaderSettings settings;

  const ImageContainer({
    Key? key,
    required this.imagePath,
    required this.settings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get the screen dimensions
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Use the margin setting from textLayoutSettings when in Fit mode
        final bool isFitMode = !settings.textLayoutSettings.fillScreen;
        // Always read margin directly from settings
        final double margin = isFitMode
            ? settings.textLayoutSettings.fitScreenMargin
            : 0.0;

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
                fit: settings.textLayoutSettings.fillScreen
                    ? BoxFit.cover
                    : BoxFit.contain,
                width: imageWidth,
                height: imageHeight,
              );

        // Create a container with the proper size and padding
        return Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.black,
          child: Center(child: imageWidget),
        );
      },
    );
  }
}
