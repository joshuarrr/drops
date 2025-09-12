import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as ui;
import 'package:screenshot/screenshot.dart';
import 'package:flutter_native_screenshot_plus/flutter_native_screenshot_plus.dart';
import 'dart:io';
import '../models/preset.dart';
import 'storage_service.dart';

/// Service for generating and caching preset thumbnails using V1's RepaintBoundary approach
/// Creates RepaintBoundary dynamically during capture, not constantly in the UI
class ThumbnailService {
  static final Map<String, String> _thumbnailCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheValidDuration = Duration(hours: 24);

  /// Generate thumbnail for a preset using actual screenshot capture
  /// This should be called when the preset is actually rendered on screen
  static Future<String?> capturePresetThumbnail({
    required Preset preset,
    required GlobalKey previewKey,
  }) async {
    try {
      final thumbnailData = await _capturePreview(previewKey);
      if (thumbnailData == null) {
        return null;
      }

      // Convert to base64
      final base64String = base64Encode(thumbnailData);

      // Cache the result
      _thumbnailCache[preset.id] = base64String;
      _cacheTimestamps[preset.id] = DateTime.now();

      // Store in persistent storage
      await StorageService.savePresetThumbnail(preset.id, base64String);

      return base64String;
    } catch (e) {
      print('Error capturing thumbnail for preset ${preset.name}: $e');
      return null;
    }
  }

  /// Get or generate thumbnail for a preset (used by preset menu)
  static Future<String?> getOrGenerateThumbnail(Preset preset) async {
    // Check memory cache first
    if (_thumbnailCache.containsKey(preset.id)) {
      final cached = _thumbnailCache[preset.id];
      final timestamp = _cacheTimestamps[preset.id];

      if (cached != null &&
          timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheValidDuration) {
        return cached;
      }
    }

    // Check persistent storage
    final stored = StorageService.loadPresetThumbnail(preset.id);
    if (stored != null) {
      _thumbnailCache[preset.id] = stored;
      _cacheTimestamps[preset.id] = DateTime.now();
      return stored;
    }

    // No thumbnail available - return null (will show placeholder)
    return null;
  }

  /// Public method to capture preview using a GlobalKey
  static Future<Uint8List?> capturePreview(GlobalKey? key) async {
    return _capturePreview(key);
  }

  /// Capture a screenshot using Screenshot package
  static Future<Uint8List?> _capturePreview(GlobalKey? key) async {
    try {
      print('🖼️ [ThumbnailService] Starting native screenshot capture...');

      // Use flutter_native_screenshot_plus to capture the actual screen
      final String? screenshotPath = await FlutterNativeScreenshotPlus()
          .takeScreenshot();

      print('🖼️ [ThumbnailService] Screenshot path: $screenshotPath');

      if (screenshotPath != null) {
        // Read the screenshot file
        final File screenshotFile = File(screenshotPath);
        final Uint8List imageBytes = await screenshotFile.readAsBytes();

        print(
          '🖼️ [ThumbnailService] Screenshot captured: ${imageBytes.length} bytes',
        );

        // Clean up the temporary file
        await screenshotFile.delete();

        return imageBytes;
      } else {
        print('🖼️ [ThumbnailService] Screenshot path is null');
      }
    } catch (e) {
      print('🖼️ [ThumbnailService] Error in _capturePreview: $e');
      return null;
    }
  }

  /// Clear all cached thumbnails
  static void clearCache() {
    _thumbnailCache.clear();
    _cacheTimestamps.clear();
  }

  /// Clear cache for a specific preset
  static void clearCacheForPreset(String presetId) {
    _thumbnailCache.remove(presetId);
    _cacheTimestamps.remove(presetId);
  }
}
