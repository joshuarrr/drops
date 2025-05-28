import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/shader_preset.dart';
import '../models/image_category.dart';
import '../controllers/preset_controller.dart';
import '../utils/logging_utils.dart';

/// Result class for cleanup operation that returns both the ID and presets
class CleanupResult {
  final String? id;
  final List<ShaderPreset>? presets;

  CleanupResult({this.id, this.presets});
}

/// Service for managing shader presets with additional functionality
class PresetService {
  static const String _logTag = "PresetService";

  /// Save current state as an untitled preset
  static Future<ShaderPreset?> saveUntitledPreset({
    required ShaderSettings settings,
    required String imagePath,
    required GlobalKey previewKey,
    Map<String, dynamic>? specificSettings,
  }) async {
    try {
      // Use a fixed name "Untitled" for the session preset
      const String presetName = "Untitled";

      // Log the background color being saved
      EffectLogger.log(
        'Saving untitled preset with background color: 0x${settings.backgroundSettings.backgroundColor.value.toRadixString(16).padLeft(8, '0')}',
      );

      // Create specific settings with current values if not provided
      final Map<String, dynamic> actualSpecificSettings =
          specificSettings ??
          {
            'fillScreen': settings.fillScreen,
            'fitScreenMargin': settings.textLayoutSettings.fitScreenMargin,
          };

      // Get all existing presets to check if "Untitled" already exists
      final allPresets = await PresetController.getAllPresets();
      final existingUntitledPreset = allPresets
          .where((p) => p.name == presetName)
          .toList();

      // If an "Untitled" preset already exists, update it instead of creating a new one
      if (existingUntitledPreset.isNotEmpty) {
        EffectLogger.log(
          'Found existing untitled preset - updating instead of creating new',
        );
        final preset = existingUntitledPreset.first;

        // Update the existing preset
        final updatedPreset = await updatePresetWithImagePath(
          id: preset.id,
          settings: settings,
          imagePath: imagePath,
          previewKey: previewKey,
          specificSettings: actualSpecificSettings,
        );

        return updatedPreset;
      } else {
        EffectLogger.log('No existing untitled preset found - creating new');
        // Save as a new preset with the specific settings
        final newPreset = await PresetController.savePreset(
          name: presetName,
          settings: settings,
          imagePath: imagePath,
          previewKey: previewKey,
          specificSettings: actualSpecificSettings,
        );

        EffectLogger.log(
          'New untitled preset created with ID: ${newPreset.id}',
        );
        return newPreset;
      }
    } catch (e, stack) {
      EffectLogger.log(
        'Error saving untitled preset: $e',
        level: LogLevel.error,
      );
      debugPrint(stack.toString());
      return null;
    }
  }

  /// Update an existing preset with new settings and image path
  static Future<ShaderPreset> updatePresetWithImagePath({
    required String id,
    required ShaderSettings settings,
    required String imagePath,
    required GlobalKey previewKey,
    Map<String, dynamic>? specificSettings,
  }) async {
    // Log the background color being updated
    EffectLogger.log(
      'Updating preset $id with background color: 0x${settings.backgroundSettings.backgroundColor.value.toRadixString(16).padLeft(8, '0')}',
    );

    // Also log the current image settings for debugging
    EffectLogger.log(
      '  with specificSettings: fillScreen=${settings.fillScreen}, fitScreenMargin=${settings.textLayoutSettings.fitScreenMargin}',
      level: LogLevel.info,
    );

    // Get the existing preset data
    final existing = await PresetController.getPresetById(id);
    if (existing == null) {
      throw Exception('Preset not found: $id');
    }

    // Merge existing specificSettings with new ones
    Map<String, dynamic> updatedSpecificSettings = {};

    // Preserve existing specificSettings if available
    if (existing.specificSettings != null) {
      updatedSpecificSettings.addAll(existing.specificSettings!);
      // Log what we're preserving
      EffectLogger.log(
        '  Preserving existing specificSettings: ${existing.specificSettings}',
        level: LogLevel.debug,
      );
    }

    // Add new specificSettings if provided
    if (specificSettings != null) {
      updatedSpecificSettings.addAll(specificSettings);
      // Log what we're adding
      EffectLogger.log(
        '  Adding new specificSettings: $specificSettings',
        level: LogLevel.debug,
      );
    }

    // Always ensure critical values are set from current settings
    updatedSpecificSettings['fitScreenMargin'] =
        settings.textLayoutSettings.fitScreenMargin;
    updatedSpecificSettings['fillScreen'] = settings.fillScreen;

    // Log the final settings being used
    EffectLogger.log(
      '  Final specificSettings: fillScreen=${updatedSpecificSettings['fillScreen']}, fitScreenMargin=${updatedSpecificSettings['fitScreenMargin']}',
      level: LogLevel.info,
    );

    // Update the preset using the new method that accepts imagePath and specificSettings
    final updatedPreset = await PresetController.updatePreset(
      id: id,
      settings: settings,
      previewKey: previewKey,
      imagePath: imagePath,
      specificSettings: updatedSpecificSettings,
    );

    return updatedPreset;
  }

  /// Save changes immediately to current preset or create a new untitled preset
  static Future<void> saveChangesImmediately({
    required ShaderSettings settings,
    required String imagePath,
    required GlobalKey previewKey,
    required String? currentUntitledPresetId,
    required List<ShaderPreset> availablePresets,
    required bool hasUnsavedChanges,
    required Function(String) onPresetIdChanged,
    required Function(int) onPresetIndexChanged,
    required Function() onPresetsReloaded,
  }) async {
    try {
      // If we don't have unsaved changes, nothing to do
      if (!hasUnsavedChanges) {
        // Don't log this message as it appears too frequently
        return;
      }

      // Always extract important settings that need to be directly accessible
      final double currentMargin = settings.textLayoutSettings.fitScreenMargin;
      final bool currentFillScreen = settings.fillScreen;

      final Map<String, dynamic> specificSettings = {
        'fillScreen': currentFillScreen,
        'fitScreenMargin': currentMargin,
      };

      EffectLogger.log(
        'Updating preset with margin: $currentMargin, fillScreen: $currentFillScreen',
        level: LogLevel.info,
      );

      // If we already have a current untitled preset for this session, update it
      if (currentUntitledPresetId != null) {
        EffectLogger.log(
          'UPDATING EXISTING UNTITLED PRESET: $currentUntitledPresetId',
        );

        // Find the preset with this ID
        final existingPresetIndex = availablePresets.indexWhere(
          (p) => p.id == currentUntitledPresetId,
        );

        if (existingPresetIndex >= 0) {
          final existingPreset = availablePresets[existingPresetIndex];

          // Update the existing untitled preset with specificSettings
          await updatePresetWithImagePath(
            id: existingPreset.id,
            settings: settings,
            imagePath: imagePath,
            previewKey: previewKey,
            specificSettings: specificSettings,
          );

          // Set as current preset
          onPresetIndexChanged(existingPresetIndex);

          // Force reload presets to ensure we have the latest version
          onPresetsReloaded();
          return;
        }
      }

      // If we don't have a current untitled preset for this session, create one
      EffectLogger.log('CREATING NEW UNTITLED PRESET FOR SESSION');
      final newPreset = await saveUntitledPreset(
        settings: settings,
        imagePath: imagePath,
        previewKey: previewKey,
        specificSettings: specificSettings,
      );

      if (newPreset != null) {
        // Store the ID of the untitled preset for this session
        onPresetIdChanged(newPreset.id);

        // Find new preset index
        final newIndex = availablePresets.indexWhere(
          (p) => p.id == newPreset.id,
        );

        if (newIndex >= 0) {
          onPresetIndexChanged(newIndex);
        }

        EffectLogger.log('Created new preset with ID: ${newPreset.id}');

        // Force reload presets
        onPresetsReloaded();
      }
    } catch (e) {
      EffectLogger.log(
        'Error saving changes immediately: $e',
        level: LogLevel.error,
      );
    }
  }

  /// Clean up duplicate "Untitled" presets and return both the ID and the presets list
  static Future<CleanupResult>
  cleanupDuplicateUntitledPresetsWithReturn() async {
    try {
      // Get all existing presets
      final allPresets = await PresetController.getAllPresets();

      // Find all presets named "Untitled"
      final untitledPresets = allPresets
          .where((p) => p.name == "Untitled")
          .toList();

      EffectLogger.log('Found ${untitledPresets.length} "Untitled" presets');

      String? keepId;

      // If we have more than one, keep only the most recent one
      if (untitledPresets.length > 1) {
        // Sort by creation date (newest first)
        untitledPresets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Keep the first one (most recent)
        final keepPreset = untitledPresets.first;
        keepId = keepPreset.id;

        EffectLogger.log('Keeping most recent "Untitled" preset: $keepId');

        // Delete all others
        for (int i = 1; i < untitledPresets.length; i++) {
          final toDelete = untitledPresets[i];
          EffectLogger.log(
            'Deleting duplicate "Untitled" preset: ${toDelete.id}',
          );
          await PresetController.deletePreset(toDelete.id);
        }
      } else if (untitledPresets.length == 1) {
        // If we have exactly one, use its ID
        keepId = untitledPresets.first.id;
      }

      // Return both the ID and the full list of presets
      // Sort presets by created date (newest first) before returning
      allPresets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return CleanupResult(id: keepId, presets: allPresets);
    } catch (e) {
      EffectLogger.log(
        'Error cleaning up duplicate presets: $e',
        level: LogLevel.error,
      );
      return CleanupResult(id: null, presets: null);
    }
  }

  /// Clean up duplicate "Untitled" presets, keeping only the most recent one
  static Future<String?> cleanupDuplicateUntitledPresets() async {
    try {
      final result = await cleanupDuplicateUntitledPresetsWithReturn();
      return result.id;
    } catch (e) {
      EffectLogger.log(
        'Error in legacy cleanup method: $e',
        level: LogLevel.error,
      );
      return null;
    }
  }
}
