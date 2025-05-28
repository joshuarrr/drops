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

  /// Save a new preset
  static Future<ShaderPreset> savePreset({
    required String name,
    required ShaderSettings settings,
    required String imagePath,
    required GlobalKey previewKey,
    PresetSortMethod? sortMethod,
    Map<String, dynamic>? specificSettings,
  }) async {
    try {
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
  static Future<Uint8List?> _capturePreview(GlobalKey key) async {
    try {
      debugPrint('Starting capture of preview with key: ${key.toString()}');

      final RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('Could not find RenderRepaintBoundary');
        return null;
      }

      // Instead of a fixed delay, use SchedulerBinding to capture after the next frame
      // This ensures we capture after all rendering is complete
      final completer = Completer<Uint8List?>();

      SchedulerBinding.instance.addPostFrameCallback((_) async {
        try {
          debugPrint('Capturing preview on next frame');

          // Instead of using an arbitrary fractional pixelRatio (which can lead to
          // cropped output on some iOS devices – see Flutter issue #131738), use
          // the device‐native devicePixelRatio. This keeps the raster size an
          // integer multiple of the logical size and eliminates the top-left crop
          // bug observed on iOS simulators.
          final double dpr = ui.window.devicePixelRatio;

          // Capture the repaint boundary at the device pixel ratio so the whole
          // screen is included without artefacts.
          final ui.Image image = await boundary.toImage(pixelRatio: dpr);

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
          // Commented out to reduce log spam when music is playing
          // debugPrint('Captured preview successfully: ${result.length} bytes');
          completer.complete(result);
        } catch (e) {
          debugPrint('Error capturing preview in post-frame: $e');
          completer.complete(null);
        }
      });

      return completer.future;
    } catch (e) {
      debugPrint('Error capturing preview: $e');
      return null;
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
  static Future<ShaderPreset> updatePreset({
    required String id,
    required ShaderSettings settings,
    required GlobalKey previewKey,
    String? imagePath,
    PresetSortMethod? sortMethod,
    Map<String, dynamic>? specificSettings,
  }) async {
    try {
      // Get existing preset
      final existing = await getPresetById(id);
      if (existing == null) {
        throw Exception('Preset not found: $id');
      }

      // Capture a thumbnail if the preview key is provided
      Uint8List? thumbnailData;
      if (previewKey.currentContext != null) {
        try {
          final boundary =
              previewKey.currentContext!.findRenderObject()
                  as RenderRepaintBoundary;
          debugPrint('Starting capture of preview with key: $previewKey');

          // Use SchedulerBinding instead of delay
          final completer = Completer<Uint8List?>();

          SchedulerBinding.instance.addPostFrameCallback((_) async {
            try {
              debugPrint('Capturing preview on next frame');

              final ui.Image image = await boundary.toImage(pixelRatio: 0.5);
              final ByteData? byteData = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );

              if (byteData != null) {
                final Uint8List bytes = byteData.buffer.asUint8List();
                debugPrint(
                  'Successfully captured image: ${image.width}x${image.height}',
                );
                // Commented out to reduce log spam when music is playing
                // debugPrint(
                //   'Captured preview successfully: ${bytes.length} bytes',
                // );
                completer.complete(bytes);
              } else {
                completer.complete(null);
              }
            } catch (e) {
              debugPrint('Error capturing preview in post-frame: $e');
              completer.complete(null);
            }
          });

          thumbnailData = await completer.future;
        } catch (e) {
          debugPrint('Error capturing preview: $e');
        }
      }

      // Use existing or provided values
      final updatedImagePath = imagePath ?? existing.imagePath;
      final updatedSortMethod = sortMethod ?? existing.sortMethod;

      // Create updated preset
      final preset = existing.copyWith(
        settings: settings,
        imagePath: updatedImagePath,
        thumbnailData: thumbnailData ?? existing.thumbnailData,
        sortMethod: updatedSortMethod,
        specificSettings: specificSettings,
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
            'sortMethod': updatedSortMethod?.index,
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
    }
  }
}
