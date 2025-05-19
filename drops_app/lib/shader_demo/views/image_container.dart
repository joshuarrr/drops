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

        return Container(
          color: Colors.black,
          width: screenWidth,
          height: screenHeight,
          alignment: Alignment.center,
          child: imagePath.isEmpty
              ? const SizedBox.shrink()
              : Center(
                  // Add Center widget to ensure proper alignment
                  child: Padding(
                    // Make sure Padding is always applied when in Fit mode with explicit EdgeInsets.all
                    padding: isFitMode
                        ? EdgeInsets.all(margin)
                        : EdgeInsets.zero,
                    child: Image.asset(
                      imagePath,
                      alignment: Alignment.center,
                      fit: settings.textLayoutSettings.fillScreen
                          ? BoxFit.cover
                          : BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
