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
  static String? _lastLoggedImagePath;
  static int _logsThisSession = 0;
  static const int _maxLogsPerSession = 3;

  // Minimum time between logs of the same values (milliseconds) - made even more aggressive
  static const int _logThrottleMs = 30000; // 30 seconds

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

        // Only log in debug mode and with extremely limited frequency
        assert(() {
          // Get current time
          final now = DateTime.now();

          // Check if values have changed from cached or static last logged values
          final valuesChanged =
              cachedMargin != margin ||
              cachedFillScreen != settings.fillScreen ||
              _lastLoggedImagePath != imagePath;

          // Very aggressive throttling:
          // 1. Only log if outside the throttle period
          // 2. Only log a maximum number of times per session
          // 3. Only log if values have actually changed
          final shouldLog =
              valuesChanged &&
              _logsThisSession < _maxLogsPerSession &&
              (_lastLogTime == null ||
                  now.difference(_lastLogTime!).inMilliseconds >
                      _logThrottleMs);

          if (shouldLog) {
            // This is now handled by the central logging system
            debugPrint(
              'ImageContainer: applying margin=${margin.toStringAsFixed(1)}, fillScreen=${settings.fillScreen}',
            );

            // Update last logged values and count
            _lastLoggedMargin = margin;
            _lastLoggedFillScreen = settings.fillScreen;
            _lastLoggedImagePath = imagePath;
            _lastLogTime = now;
            _logsThisSession++;
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
          padding: isFitMode ? EdgeInsets.all(margin) : EdgeInsets.zero,
          child: Center(child: imageWidget),
        );
      },
    );
  }
}
