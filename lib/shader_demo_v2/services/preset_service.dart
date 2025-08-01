import '../models/preset.dart';
import '../models/effect_settings.dart';
import 'storage_service.dart';

/// Preset service with single responsibility: preset CRUD operations
/// Implements context-aware positioning and smart deduplication
class PresetService {
  /// Load all saved presets from storage
  static Future<List<Preset>> loadAllPresets() async {
    await StorageService.initialize();

    final presetIds = StorageService.getAllPresetIds();
    final presets = <Preset>[];

    for (final id in presetIds) {
      final presetData = StorageService.loadPreset(id);
      if (presetData != null) {
        try {
          final preset = Preset.fromJson(presetData);
          presets.add(preset);
        } catch (e) {
          // Continue loading other presets even if one fails
        }
      }
    }

    // Sort by creation date (newest first)
    presets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return presets;
  }

  /// Save a named preset
  static Future<Preset?> saveNamedPreset({
    required String name,
    required ShaderSettings settings,
    required String imagePath,
    String? thumbnailBase64,
  }) async {
    try {
      final preset = Preset.fromCurrent(
        name: name,
        settings: settings,
        imagePath: imagePath,
        thumbnailBase64: thumbnailBase64,
      );

      final success = await StorageService.savePreset(
        preset.id,
        preset.toJson(),
      );

      if (success && thumbnailBase64 != null) {
        // Save thumbnail separately
        await StorageService.savePresetThumbnail(preset.id, thumbnailBase64);
      }

      return success ? preset : null;
    } catch (e) {
      return null;
    }
  }

  /// Update an existing preset
  static Future<bool> updatePreset(Preset preset) async {
    try {
      final success = await StorageService.savePreset(
        preset.id,
        preset.toJson(),
      );

      if (success && preset.thumbnailBase64 != null) {
        await StorageService.savePresetThumbnail(
          preset.id,
          preset.thumbnailBase64!,
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Delete a preset
  static Future<bool> deletePreset(String presetId) async {
    try {
      return await StorageService.removePreset(presetId);
    } catch (e) {
      return false;
    }
  }

  /// Save the current untitled state
  static Future<bool> saveUntitledState({
    required ShaderSettings settings,
    required String imagePath,
    String? basePresetId,
  }) async {
    try {
      final untitledData = {
        'settings': settings.toMap(),
        'imagePath': imagePath,
        'basePresetId': basePresetId,
        'lastModified': DateTime.now().toIso8601String(),
      };

      return await StorageService.saveUntitledState(untitledData);
    } catch (e) {
      return false;
    }
  }

  /// Load the untitled state
  static Future<Map<String, dynamic>?> loadUntitledState() async {
    try {
      await StorageService.initialize();
      return StorageService.loadUntitledState();
    } catch (e) {
      return null;
    }
  }

  /// Clear the untitled state (after saving or resetting)
  static Future<bool> clearUntitledState() async {
    try {
      return await StorageService.clearUntitledState();
    } catch (e) {
      return false;
    }
  }

  /// Check if current settings match any saved preset exactly (smart deduplication)
  static bool isUntitledDuplicate({
    required ShaderSettings currentSettings,
    required String currentImage,
    required List<Preset> savedPresets,
  }) {
    for (final preset in savedPresets) {
      if (preset.hasIdenticalContent(
        Preset.untitled(settings: currentSettings, imagePath: currentImage),
      )) {
        return true;
      }
    }
    return false;
  }

  /// Get context-aware navigator order
  /// Positions untitled relative to base preset for intuitive navigation
  /// Applies smart deduplication - hides untitled if identical to any saved preset
  static List<Preset> getNavigatorOrder({
    required List<Preset> savedPresets,
    Preset? untitledPreset,
    String? basePresetId,
  }) {
    // No untitled preset to show
    if (untitledPreset == null) {
      return savedPresets;
    }

    // Smart deduplication - hide untitled if it matches any saved preset exactly
    final isDuplicate = isUntitledDuplicate(
      currentSettings: untitledPreset.settings,
      currentImage: untitledPreset.imagePath,
      savedPresets: savedPresets,
    );

    if (isDuplicate) {
      // Untitled is identical to a saved preset, so hide it
      return savedPresets;
    }

    // If no base preset, add untitled at the beginning
    if (basePresetId == null) {
      return [untitledPreset, ...savedPresets];
    }

    // Find base preset position
    final baseIndex = savedPresets.indexWhere((p) => p.id == basePresetId);

    if (baseIndex == -1) {
      // Base preset not found, add at beginning
      return [untitledPreset, ...savedPresets];
    }

    // Insert untitled after base preset for context-aware clustering
    final result = List<Preset>.from(savedPresets);
    result.insert(baseIndex + 1, untitledPreset);
    return result;
  }

  /// Calculate where untitled should be positioned relative to base preset
  /// Enhanced for better clustering of similar designs
  static int calculateUntitledPosition({
    required List<Preset> savedPresets,
    String? basePresetId,
  }) {
    if (basePresetId == null || savedPresets.isEmpty) return 0;

    final baseIndex = savedPresets.indexWhere((p) => p.id == basePresetId);

    if (baseIndex == -1) {
      // Base preset not found, position at beginning
      return 0;
    }

    // For clustering: position untitled immediately after base preset
    // This creates clusters of related designs (original → variations)
    // Future enhancement: could consider similarity scoring for smarter positioning
    return baseIndex + 1;
  }

  /// Rename an existing preset
  static Future<bool> renamePreset(String presetId, String newName) async {
    try {
      final presetData = StorageService.loadPreset(presetId);
      if (presetData == null) return false;

      final preset = Preset.fromJson(presetData);
      final updatedPreset = preset.copyWith(name: newName);

      return await updatePreset(updatedPreset);
    } catch (e) {
      return false;
    }
  }

  /// Load preset thumbnail on-demand
  static String? loadPresetThumbnail(String presetId) {
    return StorageService.loadPresetThumbnail(presetId);
  }

  /// Save preset thumbnail
  static Future<bool> savePresetThumbnail(
    String presetId,
    String base64Data,
  ) async {
    return await StorageService.savePresetThumbnail(presetId, base64Data);
  }

  /// Get storage statistics for debugging
  static Map<String, int> getStorageStats() {
    return StorageService.getStorageStats();
  }

  /// Create a copy of an existing preset
  static Future<Preset?> duplicatePreset(
    String presetId, {
    String? newName,
  }) async {
    try {
      final presetData = StorageService.loadPreset(presetId);
      if (presetData == null) return null;

      final originalPreset = Preset.fromJson(presetData);
      final duplicatedPreset = Preset.fromCurrent(
        name: newName ?? '${originalPreset.name} Copy',
        settings: originalPreset.settings,
        imagePath: originalPreset.imagePath,
        thumbnailBase64: originalPreset.thumbnailBase64,
      );

      final success = await StorageService.savePreset(
        duplicatedPreset.id,
        duplicatedPreset.toJson(),
      );

      if (success && duplicatedPreset.thumbnailBase64 != null) {
        await StorageService.savePresetThumbnail(
          duplicatedPreset.id,
          duplicatedPreset.thumbnailBase64!,
        );
      }

      return success ? duplicatedPreset : null;
    } catch (e) {
      return null;
    }
  }

  /// Validate preset name (ensure it's unique)
  static Future<bool> isNameUnique(
    String name, {
    String? excludePresetId,
  }) async {
    final presets = await loadAllPresets();
    return !presets.any(
      (preset) =>
          preset.name.toLowerCase() == name.toLowerCase() &&
          preset.id != excludePresetId,
    );
  }
}
