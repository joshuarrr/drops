import 'package:flutter/material.dart';
import '../models/effect_settings.dart';
import '../utils/logging_utils.dart';

class ImageContainer extends StatelessWidget {
  final String imagePath;
  final ShaderSettings settings;

  // Cached margin values to avoid rebuilds
  final double? cachedMargin;
  final bool? cachedFillScreen;

  // Static variables to track last logged values to avoid duplicate logging
  static double? _lastLoggedMargin;
  static bool? _lastLoggedFillScreen;
  static DateTime? _lastLogTime;

  // Minimum time between logs of the same values (milliseconds)
  static const int _logThrottleMs = 500;

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
          // Get current time
          final now = DateTime.now();

          // Check if values have changed from cached or static last logged values
          final valuesChanged =
              cachedMargin != margin || cachedFillScreen != settings.fillScreen;

          // Check if we're outside the throttle period or values have changed
          final shouldLog =
              valuesChanged &&
              (_lastLogTime == null ||
                  _lastLoggedMargin != margin ||
                  _lastLoggedFillScreen != settings.fillScreen ||
                  now.difference(_lastLogTime!).inMilliseconds >
                      _logThrottleMs);

          if (shouldLog) {
            debugPrint(
              'ImageContainer: applying margin=${margin.toStringAsFixed(1)}, fillScreen=${settings.fillScreen}',
            );

            // Update last logged values
            _lastLoggedMargin = margin;
            _lastLoggedFillScreen = settings.fillScreen;
            _lastLogTime = now;
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
