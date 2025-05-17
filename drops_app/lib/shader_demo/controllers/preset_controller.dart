import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  /// Get all saved presets
  static Future<List<ShaderPreset>> getAllPresets() async {
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

    // Sort by most recent
    presets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return presets;
  }

  /// Save a new preset
  static Future<ShaderPreset> savePreset({
    required String name,
    required ShaderSettings settings,
    required String imagePath,
    required GlobalKey previewKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Generate unique ID
      final id = const Uuid().v4();
      final now = DateTime.now();

      // Create thumbnail from the current view
      final Uint8List? thumbnailData = await _capturePreview(previewKey);

      // Create the preset
      final preset = ShaderPreset(
        id: id,
        name: name,
        createdAt: now,
        settings: settings,
        imagePath: imagePath,
        thumbnailData: thumbnailData,
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
            'settings': {'textEnabled': false},
            'imagePath': preset.imagePath,
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
      final RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('Could not find RenderRepaintBoundary');
        return null;
      }

      // Wait a frame to ensure all animations and shader effects are properly rendered
      await Future.delayed(const Duration(milliseconds: 100));

      // Instead of using an arbitrary fractional pixelRatio (which can lead to
      // cropped output on some iOS devices – see Flutter issue #131738), use
      // the device‐native devicePixelRatio. This keeps the raster size an
      // integer multiple of the logical size and eliminates the top-left crop
      // bug observed on iOS simulators.

      final double dpr = ui.window.devicePixelRatio;

      // Capture the repaint boundary at the device pixel ratio so the whole
      // screen is included without artefacts.
      final ui.Image image = await boundary.toImage(pixelRatio: dpr);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        debugPrint('Could not convert image to bytes');
        return null;
      }

      return byteData.buffer.asUint8List();
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
}
