import 'shader_controller.dart';

/// Bridge class to provide static access to ShaderController methods
/// This allows V1 widget patterns to work with V2 architecture
class EffectControls {
  static ShaderController? _currentController;

  /// Set the current controller instance
  static void setController(ShaderController? controller) {
    _currentController = controller;
  }

  /// Get the current controller
  static ShaderController? get currentController => _currentController;

  /// Load presets for a specific aspect
  static Future<List<Map<String, dynamic>>> loadPresetsForAspect(
    dynamic aspect,
  ) async {
    return _currentController?.loadPresetsForAspect(aspect.toString()) ?? [];
  }

  /// Delete preset and update
  static Future<bool> deletePresetAndUpdate(dynamic aspect, String name) async {
    return _currentController?.deletePresetAndUpdate(aspect.toString(), name) ??
        false;
  }

  /// Refresh presets
  static void refreshPresets() {
    _currentController?.refreshPresets();
  }

  /// Set music volume
  static void setMusicVolume(double volume) {
    _currentController?.setMusicVolume(volume);
  }

  /// Debug music controller state (V2 doesn't have this, return null)
  static Map<String, dynamic>? Function()? get debugMusicControllerState =>
      null;
}
