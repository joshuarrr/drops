import 'package:flutter/material.dart';
import '../models/shader_preset.dart';
import '../models/effect_settings.dart';
import '../views/preset_dialog.dart';
import 'preset_controller.dart';
import '../services/preset_service.dart';

/// Handles showing dialogs for saving and loading shader presets
class PresetDialogs {
  /// Show dialog to save a preset
  static Future<void> showSavePresetDialog({
    required BuildContext context,
    required ShaderSettings settings,
    required String imagePath,
    GlobalKey? previewKey,
    ShaderPreset? currentPreset,
  }) {
    // Store a reference to the scaffold context before showing the dialog
    final scaffoldContext = context;

    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => SavePresetDialog(
        onSave: (name) async {
          try {
            // If we have a current preset and the name matches, update instead of creating new
            if (currentPreset != null && currentPreset.name == name) {
              await PresetController.updatePreset(
                id: currentPreset.id,
                settings: settings,
                previewKey: previewKey,
              );

              // Show success message
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text('Preset "$name" updated successfully'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  backgroundColor: Theme.of(
                    scaffoldContext,
                  ).colorScheme.surface,
                  elevation: 6,
                ),
              );
            } else {
              // Create a new preset
              // Always use PresetController.savePreset for user-initiated saves
              // This ensures proper validation and error handling
              await PresetController.savePreset(
                name: name,
                settings: settings,
                imagePath: imagePath,
                previewKey:
                    previewKey, // This can be null - controller will handle it
              );

              // Show success message
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text('Preset "$name" saved successfully'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  backgroundColor: Theme.of(
                    scaffoldContext,
                  ).colorScheme.surface,
                  elevation: 6,
                ),
              );
            }
          } catch (e) {
            debugPrint('Error saving preset: $e');
            // Use the stored scaffold context instead of the dialog context
            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
              SnackBar(
                content: Text(
                  'Error saving preset: ${e.toString()}',
                  style: TextStyle(
                    color: Theme.of(scaffoldContext).colorScheme.onError,
                  ),
                ),
                backgroundColor: Theme.of(scaffoldContext).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        initialName: currentPreset?.name,
        isUpdate: currentPreset != null,
      ),
    );
  }

  /// Show dialog to update an existing preset
  static Future<void> showUpdatePresetDialog({
    required BuildContext context,
    required ShaderPreset preset,
    required ShaderSettings newSettings,
    GlobalKey? previewKey,
  }) {
    // Store a reference to the scaffold context before showing the dialog
    final scaffoldContext = context;

    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AlertDialog(
        title: const Text('Update Preset'),
        content: Text(
          'Do you want to update "${preset.name}" with the current settings?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                // Update the preset
                if (previewKey == null) {
                  // Use the service method that handles null previewKey
                  await PresetService.updatePresetWithImagePath(
                    id: preset.id,
                    settings: newSettings,
                    imagePath: preset.imagePath,
                    previewKey: null,
                  );
                } else {
                  // Use the controller method with the previewKey
                  await PresetController.updatePreset(
                    id: preset.id,
                    settings: newSettings,
                    previewKey: previewKey,
                  );
                }

                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Preset "${preset.name}" updated successfully',
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    backgroundColor: Theme.of(
                      scaffoldContext,
                    ).colorScheme.surface,
                    elevation: 6,
                  ),
                );
              } catch (e) {
                debugPrint('Error updating preset: $e');
                Navigator.pop(context);

                // Show error message
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error updating preset: ${e.toString()}',
                      style: TextStyle(
                        color: Theme.of(scaffoldContext).colorScheme.onError,
                      ),
                    ),
                    backgroundColor: Theme.of(
                      scaffoldContext,
                    ).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
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
              backgroundColor: Theme.of(scaffoldContext).colorScheme.surface,
              elevation: 6,
            ),
          );
        },
      ),
    );
  }
}
