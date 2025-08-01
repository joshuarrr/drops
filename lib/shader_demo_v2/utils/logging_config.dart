/// Central configuration for logging in shader settings
///
/// This file provides a single place to control logging verbosity
/// across all shader effect settings classes.

import '../models/background_settings.dart';
import '../models/music_settings.dart';
import '../models/effect_settings.dart';
import '../models/color_settings.dart';
import '../models/noise_settings.dart';
import '../models/ripple_settings.dart';
import '../models/blur_settings.dart';
import '../models/text_layout_settings.dart';
import '../models/chromatic_settings.dart';
import '../models/rain_settings.dart';
import '../models/text_fx_settings.dart';
import '../models/targetable_effect_settings.dart';

class LoggingConfig {
  /// Master switch for all settings logging
  static bool _loggingEnabled = false;

  /// Get current logging state
  static bool get isLoggingEnabled => _loggingEnabled;

  /// Configure logging for all settings classes
  static void configureLogging({bool enableLogging = false}) {
    _loggingEnabled = enableLogging;
    // Disable verbose logging for all settings classes
    BackgroundSettings.enableLogging = enableLogging;
    MusicSettings.enableLogging = enableLogging;
    ShaderSettings.enableLogging = enableLogging;
    ColorSettings.enableLogging = enableLogging;
    NoiseSettings.enableLogging = enableLogging;
    RippleSettings.enableLogging = enableLogging;
    BlurSettings.enableLogging = enableLogging;
    TextLayoutSettings.enableLogging = enableLogging;
    ChromaticSettings.enableLogging = enableLogging;
    RainSettings.enableLogging = enableLogging;
    TextFXSettings.enableLogging = enableLogging;
    TargetableEffectSettings.enableLogging = enableLogging;
  }

  /// Disable all logging (useful for production or when music is playing)
  static void disableAllLogging() {
    configureLogging(enableLogging: false);
  }

  /// Enable all logging (useful for debugging)
  static void enableAllLogging() {
    configureLogging(enableLogging: true);
  }
}
