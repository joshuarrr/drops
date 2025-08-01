import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/shader_settings.dart';
import '../models/color_settings.dart';

/// Simple controller for V3 demo
class ShaderController extends ChangeNotifier {
  // Settings
  ShaderSettings _settings;

  // UI state
  bool _showControls = true;

  // Constructor
  ShaderController({ShaderSettings? settings, String? initialImage})
    : _settings =
          settings ??
          ShaderSettings(
            colorEnabled: true,
            colorSettings: ColorSettings(
              hue: 0.5,
              saturation: 0.5,
              lightness: 0.0,
            ),
            imageEnabled: true,
            selectedImage:
                initialImage ??
                'assets/img/covers/Adrianne-Lenker-Live-at-Revoultion-Hall.webp',
          );

  // Getters
  ShaderSettings get settings => _settings;
  bool get showControls => _showControls;

  // Toggle controls visibility
  void toggleControls() {
    _showControls = !_showControls;
    notifyListeners();
  }

  // Update settings
  void updateSettings(ShaderSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  // Update color settings
  void updateColorSettings(ColorSettings newColorSettings) {
    final newSettings = _settings.copyWith(colorSettings: newColorSettings);
    updateSettings(newSettings);
  }

  // Toggle color animation
  void toggleColorAnimation(bool animated) {
    // Only update if the value actually changed
    if (_settings.colorSettings.colorAnimated != animated) {
      debugPrint('[V3] Toggling color animation to $animated');
      final newColorSettings = _settings.colorSettings.copyWith(
        colorAnimated: animated,
      );
      updateColorSettings(newColorSettings);
    }
  }

  // Update color hue
  void updateColorHue(double hue) {
    final newColorSettings = _settings.colorSettings.copyWith(hue: hue);
    updateColorSettings(newColorSettings);
  }

  // Update color saturation
  void updateColorSaturation(double saturation) {
    final newColorSettings = _settings.colorSettings.copyWith(
      saturation: saturation,
    );
    updateColorSettings(newColorSettings);
  }

  // Update color lightness
  void updateColorLightness(double lightness) {
    final newColorSettings = _settings.colorSettings.copyWith(
      lightness: lightness,
    );
    updateColorSettings(newColorSettings);
  }

  // Toggle color effect
  void toggleColorEffect(bool enabled) {
    // Only update if the value actually changed
    if (_settings.colorEnabled != enabled) {
      debugPrint('[V3] Toggling color effect to $enabled');
      final newSettings = _settings.copyWith(colorEnabled: enabled);
      updateSettings(newSettings);
    }
  }
}
