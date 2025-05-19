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
        final double margin = isFitMode ? 30.0 : 0.0;

        // Create the image widget for both sizes
        Widget imageWidget = imagePath.isEmpty
            ? SizedBox(width: screenWidth, height: screenHeight)
            : Image.asset(
                imagePath,
                fit: settings.textLayoutSettings.fillScreen
                    ? BoxFit.cover
                    : BoxFit.contain,
                width: screenWidth,
                height: screenHeight,
              );

        // Use Stack to ensure proper layout
        return Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Use Positioned.fill to ensure the image remains full-sized
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: screenWidth,
                    height: screenHeight,
                    padding: EdgeInsets.all(isFitMode ? margin : 0),
                    child: imageWidget,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
