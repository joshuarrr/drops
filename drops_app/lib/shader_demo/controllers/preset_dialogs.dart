import 'package:flutter/material.dart';
import '../models/shader_preset.dart';
import '../models/effect_settings.dart';
import '../views/preset_dialog.dart';
import 'preset_controller.dart';

/// Handles showing dialogs for saving and loading shader presets
class PresetDialogs {
  /// Show dialog to save a preset
  static void showSavePresetDialog({
    required BuildContext context,
    required ShaderSettings settings,
    required String imagePath,
    required GlobalKey previewKey,
  }) {
    // Store a reference to the scaffold context before showing the dialog
    final scaffoldContext = context;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => SavePresetDialog(
        onSave: (name) async {
          try {
            final preset = await PresetController.savePreset(
              name: name,
              settings: settings,
              imagePath: imagePath,
              previewKey: previewKey,
            );

            // Use the stored scaffold context instead of the dialog context
            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
              SnackBar(
                content: Text('Preset "$name" saved successfully'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          } catch (e) {
            debugPrint('Error saving preset: $e');
            // Use the stored scaffold context instead of the dialog context
            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
              SnackBar(
                content: Text('Error saving preset: ${e.toString()}'),
                backgroundColor: Theme.of(scaffoldContext).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
      ),
    );
  }

  /// Show dialog to load a preset
  /// Returns a Future that completes when the dialog is closed
  static Future<void> showLoadPresetDialog({
    required BuildContext context,
    required Function(ShaderPreset) onPresetLoaded,
  }) {
    // Store a reference to the scaffold context before showing the dialog
    final scaffoldContext = context;

    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => PresetsDialog(
        onLoad: (preset) {
          // Apply preset
          onPresetLoaded(preset);

          // Show confirmation
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(
              content: Text('Preset "${preset.name}" loaded'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
