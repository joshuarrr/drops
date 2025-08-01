import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/shader_preset.dart';
import '../models/effect_settings.dart';
import 'effect_controller.dart';
import '../controllers/shaders/noise_effect_shader.dart';

/// Controller for managing shader presets
class PresetController {
  static const String _presetListKey = 'shader_presets_list';
  static const String _presetPrefix = 'shader_preset_';
  static const String _thumbnailPrefix = 'shader_preset_thumb_';

  /// Get all saved presets with optional sorting
  static Future<List<ShaderPreset>> getAllPresets({
    PresetSortMethod? sortMethod,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final presetIds = prefs.getStringList(_presetListKey) ?? [];

    final List<ShaderPreset> presets = [];

    for (final id in presetIds) {
      final presetJson = prefs.getString('$_presetPrefix$id');
      final thumbData = prefs.getString('$_thumbnailPrefix$id');

      if (presetJson != null) {
        final presetMap = jsonDecode(presetJson) as Map<String, dynamic>;
        Uint8List? thumbnail;

        if (thumbData != null) {
          try {
            thumbnail = base64Decode(thumbData);
          } catch (e) {
            debugPrint('Failed to decode thumbnail: $e');
          }
        }

        presets.add(ShaderPreset.fromMap(presetMap, thumbnail: thumbnail));
      }
    }

    // Apply sort method if provided, otherwise default to newest first
    if (sortMethod != null) {
      _sortPresets(presets, sortMethod);
    } else {
      // Default sort by most recent
      presets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return presets;
  }

  /// Sort presets based on the specified sort method
  static void _sortPresets(
    List<ShaderPreset> presets,
    PresetSortMethod sortMethod,
  ) {
    switch (sortMethod) {
      case PresetSortMethod.dateNewest:
        presets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case PresetSortMethod.alphabetical:
        presets.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case PresetSortMethod.reverseAlphabetical:
        presets.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case PresetSortMethod.random:
        presets.shuffle();
        break;
    }
  }

  /// Generate the next automatic preset name (e.g., "Preset 1", "Preset 2")
  static Future<String> generateAutomaticPresetName() async {
    final presets = await getAllPresets();

    // Find all preset names that match the pattern "Preset N"
    final regex = RegExp(r'^Preset (\d+)$');
    final usedNumbers = <int>[];

    for (final preset in presets) {
      final match = regex.firstMatch(preset.name);
      if (match != null) {
        final number = int.tryParse(match.group(1) ?? '');
        if (number != null) {
          usedNumbers.add(number);
        }
      }
    }

    // Find the next available number
    int nextNumber = 1;
    if (usedNumbers.isNotEmpty) {
      usedNumbers.sort();
      // Find first gap or use the next number after the highest
      for (int i = 0; i < usedNumbers.length; i++) {
        if (i + 1 < usedNumbers[i]) {
          nextNumber = i + 1;
          break;
        }
      }
      if (nextNumber == 1) {
        // No gaps found, use next number
        nextNumber = usedNumbers.last + 1;
      }
    }

    return 'Preset $nextNumber';
  }

  /// Save a new preset with the given settings
  static Future<ShaderPreset> savePreset({
    required String name,
    required ShaderSettings settings,
    required String imagePath,
    required GlobalKey? previewKey,
    PresetSortMethod? sortMethod,
    Map<String, dynamic>? specificSettings,
  }) async {
    try {
      // Enable memory protection for animated shaders during preset saving
      NoiseEffectShader.setPresetSaving(true);

      // Log text settings to help debug
      debugPrint(
        'Saving preset with text enabled: ${settings.textLayoutSettings.textEnabled}',
      );
      if (settings.textLayoutSettings.textEnabled) {
        debugPrint(
          'Text content - Title: "${settings.textLayoutSettings.textTitle}"',
        );
        debugPrint(
          'Text content - Subtitle: "${settings.textLayoutSettings.textSubtitle}"',
        );
        debugPrint(
          'Text content - Artist: "${settings.textLayoutSettings.textArtist}"',
        );
      }

      final prefs = await SharedPreferences.getInstance();

      // Generate unique ID
      final id = const Uuid().v4();
      final now = DateTime.now();

      // Create thumbnail from the current view
      final Uint8List? thumbnailData = await _capturePreview(previewKey);

      // Create the preset with sort method
      final preset = ShaderPreset(
        id: id,
        name: name,
        createdAt: now,
        settings: settings,
        imagePath: imagePath,
        thumbnailData: thumbnailData,
        sortMethod: sortMethod,
        specificSettings: specificSettings,
      );

      // Save preset data - handle Color serialization
      try {
        // Convert Color objects to integer values in settings before serializing
        final Map<String, dynamic> presetMap = preset.toMap();

        // Use a separate try block specifically for JSON encoding
        String presetJson;
        try {
          presetJson = jsonEncode(presetMap);
        } catch (jsonError) {
          debugPrint('JSON encoding error: $jsonError');

          // Create a simpler version without any complex objects
          final fallbackMap = {
            'id': preset.id,
            'name': preset.name,
            'createdAt': preset.createdAt.millisecondsSinceEpoch,
            'settings': {
              // Ensure we preserve critical settings with their actual values
              'imageEnabled': settings.imageEnabled,
              'backgroundSettings': {
                'backgroundEnabled':
                    settings.backgroundSettings.backgroundEnabled,
                'backgroundColor':
                    settings.backgroundSettings.backgroundColor.value,
                'backgroundAnimated':
                    settings.backgroundSettings.backgroundAnimated,
                'backgroundAnimOptions': settings
                    .backgroundSettings
                    .backgroundAnimOptions
                    .toMap(),
              },
              // Include other settings too
              'colorSettings': settings.colorSettings.toMap(),
              'blurSettings': settings.blurSettings.toMap(),
              'noiseSettings': settings.noiseSettings.toMap(),
              'textfxSettings': settings.textfxSettings.toMap(),
              'textLayoutSettings': settings.textLayoutSettings.toMap(),
              'rainSettings': settings.rainSettings.toMap(),
              'chromaticSettings': settings.chromaticSettings.toMap(),
              'rippleSettings': settings.rippleSettings.toMap(),
              'musicSettings': settings.musicSettings.toMap(),
              'cymaticsSettings': settings.cymaticsSettings.toMap(),
            },
            'imagePath': preset.imagePath,
            'sortMethod': sortMethod?.index,
            // Include any specific settings if available
            if (specificSettings != null) ...specificSettings,
          };
          presetJson = jsonEncode(fallbackMap);
        }

        await prefs.setString('$_presetPrefix$id', presetJson);
      } catch (e) {
        debugPrint('Error saving preset: $e');
        throw Exception('Failed to save preset: $e');
      }

      // Save thumbnail separately (if available)
      if (thumbnailData != null) {
        final thumbBase64 = base64Encode(thumbnailData);
        await prefs.setString('$_thumbnailPrefix$id', thumbBase64);
      }

      // Add to list of presets
      final presetIds = prefs.getStringList(_presetListKey) ?? [];
      if (!presetIds.contains(id)) {
        presetIds.add(id);
        await prefs.setStringList(_presetListKey, presetIds);
      }

      return preset;
    } catch (e) {
      debugPrint('Error saving preset: $e');
      throw Exception('Failed to save preset: $e');
    } finally {
      // Always disable memory protection when done
      NoiseEffectShader.setPresetSaving(false);
    }
  }

  /// Delete a preset
  static Future<bool> deletePreset(String id) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove from list
    final presetIds = prefs.getStringList(_presetListKey) ?? [];
    if (presetIds.contains(id)) {
      presetIds.remove(id);
      await prefs.setStringList(_presetListKey, presetIds);
    }

    // Remove data and thumbnail
    await prefs.remove('$_presetPrefix$id');
    await prefs.remove('$_thumbnailPrefix$id');

    return true;
  }

  /// Capture a preview of the current shader effect
  static Future<Uint8List?> _capturePreview(GlobalKey? key) async {
    try {
      // Enable memory protection for animated shaders during thumbnail capture
      NoiseEffectShader.setPresetSaving(true);
      EffectController.setPresetCapturing(true);

      // If no key provided, skip thumbnail capture
      if (key == null) {
        debugPrint('No preview key provided, skipping thumbnail capture');
        return null;
      }

      debugPrint('Starting capture of preview with key: ${key.toString()}');

      final RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('Could not find RenderRepaintBoundary');
        return null;
      }

      // Use a higher pixel ratio for better quality thumbnails in the UI
      // Increased from 0.25 to 2.0 for much better visual quality
      const double pixelRatio = 2.0; // High resolution for UI thumbnails

      // Instead of a fixed delay, use SchedulerBinding to capture after the next frame
      // This ensures we capture after all rendering is complete
      final completer = Completer<Uint8List?>();

      SchedulerBinding.instance.addPostFrameCallback((_) async {
        ui.Image? image;
        try {
          debugPrint('Capturing preview on next frame');

          // Capture at high resolution for quality thumbnails
          image = await boundary.toImage(pixelRatio: pixelRatio);

          debugPrint(
            'Successfully captured image: ${image.width}x${image.height}',
          );

          final ByteData? byteData = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );

          if (byteData == null) {
            debugPrint('Could not convert image to bytes');
            completer.complete(null);
            return;
          }

          final result = byteData.buffer.asUint8List();
          completer.complete(result);
        } catch (e) {
          debugPrint('Error capturing preview in post-frame: $e');
          completer.complete(null);
        } finally {
          // Manually dispose of the image to free memory
          image?.dispose();

          // Force a garbage collection after image capture
          await Future.delayed(Duration.zero);
        }
      });

      return completer.future;
    } catch (e) {
      debugPrint('Error capturing preview: $e');
      return null;
    } finally {
      // Always disable memory protection when done
      NoiseEffectShader.setPresetSaving(false);
      EffectController.setPresetCapturing(false);
    }
  }

  /// Generate a preview widget using preset settings
  static Widget buildPresetPreview({
    required ShaderPreset preset,
    double size = 100,
  }) {
    // If there's a thumbnail, use it
    if (preset.thumbnailData != null) {
      return Container(
        color: Colors.black,
        width: size,
        height: size,
        alignment: Alignment.center,
        child: Image.memory(preset.thumbnailData!, fit: BoxFit.cover),
      );
    }

    // Otherwise build a mini-preview using the image path
    return Container(
      color: Colors.black,
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Image.asset(preset.imagePath, fit: BoxFit.cover),
    );
  }

  /// Toggle the hidden state of a preset for slideshows
  static Future<ShaderPreset> toggleHiddenState(String id) async {
    final prefs = await SharedPreferences.getInstance();

    // Get the preset data
    final presetJson = prefs.getString('$_presetPrefix$id');
    if (presetJson == null) {
      throw Exception('Preset not found');
    }

    // Parse the preset
    final presetMap = jsonDecode(presetJson) as Map<String, dynamic>;
    final thumbData = prefs.getString('$_thumbnailPrefix$id');
    Uint8List? thumbnail;

    if (thumbData != null) {
      try {
        thumbnail = base64Decode(thumbData);
      } catch (e) {
        debugPrint('Failed to decode thumbnail: $e');
      }
    }

    final preset = ShaderPreset.fromMap(presetMap, thumbnail: thumbnail);

    // Create an updated preset with toggled visibility
    final updatedPreset = preset.copyWith(
      isHiddenFromSlideshow: !preset.isHiddenFromSlideshow,
    );

    // Save the updated preset
    try {
      final Map<String, dynamic> updatedMap = updatedPreset.toMap();
      final updatedJson = jsonEncode(updatedMap);
      await prefs.setString('$_presetPrefix$id', updatedJson);
      return updatedPreset;
    } catch (e) {
      debugPrint('Error updating preset hidden state: $e');
      throw Exception('Failed to update preset: $e');
    }
  }

  /// Get a preset by ID
  static Future<ShaderPreset?> getPresetById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final presetJson = prefs.getString('$_presetPrefix$id');
    final thumbData = prefs.getString('$_thumbnailPrefix$id');

    if (presetJson != null) {
      final presetMap = jsonDecode(presetJson) as Map<String, dynamic>;
      Uint8List? thumbnail;

      if (thumbData != null) {
        try {
          thumbnail = base64Decode(thumbData);
        } catch (e) {
          debugPrint('Failed to decode thumbnail: $e');
        }
      }

      return ShaderPreset.fromMap(presetMap, thumbnail: thumbnail);
    }

    return null;
  }

  /// Update an existing preset
  static Future<ShaderPreset?> updatePreset({
    required String id,
    required ShaderSettings settings,
    String? imagePath,
    GlobalKey? previewKey,
    PresetSortMethod? sortMethod,
    Map<String, dynamic>? specificSettings,
  }) async {
    try {
      // Enable memory protection for animated shaders during preset updating
      NoiseEffectShader.setPresetSaving(true);

      // Get existing preset
      final existing = await getPresetById(id);
      if (existing == null) {
        throw Exception('Preset not found');
      }

      // Capture new thumbnail if previewKey is provided
      Uint8List? thumbnailData;
      if (previewKey != null) {
        thumbnailData = await _capturePreview(previewKey);
      }

      // Use new imagePath if provided, otherwise keep existing
      final updatedImagePath = imagePath ?? existing.imagePath;

      // Merge specificSettings properly
      Map<String, dynamic> updatedSpecificSettings = {};
      if (existing.specificSettings != null) {
        updatedSpecificSettings.addAll(existing.specificSettings!);
      }
      if (specificSettings != null) {
        updatedSpecificSettings.addAll(specificSettings);
      }

      // Use new sort method if provided, otherwise keep existing
      final updatedSortMethod = sortMethod ?? existing.sortMethod;

      // Create updated preset
      final preset = existing.copyWith(
        settings: settings,
        imagePath: updatedImagePath,
        thumbnailData: thumbnailData ?? existing.thumbnailData,
        sortMethod: updatedSortMethod,
        specificSettings: updatedSpecificSettings,
      );

      // Debug to verify
      debugPrint(
        'Saving preset with fillScreen=${updatedSpecificSettings['fillScreen']}',
      );

      // Save to storage
      final prefs = await SharedPreferences.getInstance();
      try {
        // Convert Color objects to integer values in settings before serializing
        final Map<String, dynamic> presetMap = preset.toMap();

        // Use a separate try block specifically for JSON encoding
        String presetJson;
        try {
          presetJson = jsonEncode(presetMap);
        } catch (jsonError) {
          debugPrint('JSON encoding error: $jsonError');

          // Create a simpler version without any complex objects
          final fallbackMap = {
            'id': preset.id,
            'name': preset.name,
            'createdAt': preset.createdAt.millisecondsSinceEpoch,
            'settings': {
              // Ensure we preserve critical settings with their actual values
              'imageEnabled': settings.imageEnabled,
              'backgroundSettings': {
                'backgroundEnabled':
                    settings.backgroundSettings.backgroundEnabled,
                'backgroundColor':
                    settings.backgroundSettings.backgroundColor.value,
                'backgroundAnimated':
                    settings.backgroundSettings.backgroundAnimated,
                'backgroundAnimOptions': settings
                    .backgroundSettings
                    .backgroundAnimOptions
                    .toMap(),
              },
              // Include other settings too
              'colorSettings': settings.colorSettings.toMap(),
              'blurSettings': settings.blurSettings.toMap(),
              'noiseSettings': settings.noiseSettings.toMap(),
              'textfxSettings': settings.textfxSettings.toMap(),
              'textLayoutSettings': settings.textLayoutSettings.toMap(),
              'rainSettings': settings.rainSettings.toMap(),
              'chromaticSettings': settings.chromaticSettings.toMap(),
              'rippleSettings': settings.rippleSettings.toMap(),
              'musicSettings': settings.musicSettings.toMap(),
              'cymaticsSettings': settings.cymaticsSettings.toMap(),
            },
            'imagePath': preset.imagePath,
            'sortMethod': sortMethod?.index,
            // Include any specific settings if available
            if (specificSettings != null) ...specificSettings,
          };
          presetJson = jsonEncode(fallbackMap);
        }

        await prefs.setString('$_presetPrefix$id', presetJson);
      } catch (e) {
        debugPrint('Error saving preset: $e');
        throw Exception('Failed to update preset: $e');
      }

      // Save thumbnail separately (if available)
      if (thumbnailData != null) {
        final thumbBase64 = base64Encode(thumbnailData);
        await prefs.setString('$_thumbnailPrefix$id', thumbBase64);
      }

      return preset;
    } catch (e) {
      debugPrint('Error updating preset: $e');
      throw Exception('Failed to update preset: $e');
    } finally {
      // Always disable memory protection when done
      NoiseEffectShader.setPresetSaving(false);
    }
  }

  /// Regenerate thumbnails for all existing presets with higher resolution
  static Future<int> regenerateAllThumbnails({
    required GlobalKey previewKey,
    required Function(ShaderSettings, String) applyPresetSettings,
    Function(int, int)? onProgress,
  }) async {
    try {
      final presets = await getAllPresets();
      int regeneratedCount = 0;

      debugPrint(
        'Starting thumbnail regeneration for ${presets.length} presets',
      );

      for (int i = 0; i < presets.length; i++) {
        final preset = presets[i];

        // Notify progress if callback provided
        onProgress?.call(i + 1, presets.length);

        try {
          debugPrint('Regenerating thumbnail for preset: ${preset.name}');

          // Apply the preset settings to the shader
          applyPresetSettings(preset.settings, preset.imagePath);

          // Wait a bit for the shader to render
          await Future.delayed(const Duration(milliseconds: 500));

          // Capture new high-resolution thumbnail
          final newThumbnailData = await _capturePreview(previewKey);

          if (newThumbnailData != null) {
            // Save the new thumbnail
            final prefs = await SharedPreferences.getInstance();
            final thumbBase64 = base64Encode(newThumbnailData);
            await prefs.setString('$_thumbnailPrefix${preset.id}', thumbBase64);

            regeneratedCount++;
            debugPrint('✓ Regenerated thumbnail for: ${preset.name}');
          } else {
            debugPrint('✗ Failed to capture thumbnail for: ${preset.name}');
          }
        } catch (e) {
          debugPrint('Error regenerating thumbnail for ${preset.name}: $e');
        }
      }

      debugPrint(
        'Thumbnail regeneration complete: $regeneratedCount/${presets.length} updated',
      );
      return regeneratedCount;
    } catch (e) {
      debugPrint('Error during thumbnail regeneration: $e');
      return 0;
    }
  }

  /// Regenerate thumbnail for a specific preset
  static Future<bool> regenerateThumbnail({
    required String presetId,
    required GlobalKey previewKey,
    required Function(ShaderSettings, String) applyPresetSettings,
  }) async {
    try {
      // Enable memory protection for animated shaders during thumbnail regeneration
      NoiseEffectShader.setPresetSaving(true);

      final preset = await getPresetById(presetId);
      if (preset == null) {
        debugPrint('Preset not found: $presetId');
        return false;
      }

      debugPrint('Regenerating thumbnail for preset: ${preset.name}');

      // Apply the preset settings to the shader
      applyPresetSettings(preset.settings, preset.imagePath);

      // Wait a bit for the shader to render
      await Future.delayed(const Duration(milliseconds: 500));

      // Capture new high-resolution thumbnail
      final newThumbnailData = await _capturePreview(previewKey);

      if (newThumbnailData != null) {
        // Save the new thumbnail
        final prefs = await SharedPreferences.getInstance();
        final thumbBase64 = base64Encode(newThumbnailData);
        await prefs.setString('$_thumbnailPrefix$presetId', thumbBase64);

        debugPrint('✓ Successfully regenerated thumbnail for: ${preset.name}');
        return true;
      } else {
        debugPrint('✗ Failed to capture thumbnail for: ${preset.name}');
        return false;
      }
    } catch (e) {
      debugPrint('Error regenerating thumbnail for preset $presetId: $e');
      return false;
    } finally {
      // Always disable memory protection when done
      NoiseEffectShader.setPresetSaving(false);
    }
  }
}
