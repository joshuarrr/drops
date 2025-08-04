import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as ui;
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

  /// Capture a screenshot using RenderRepaintBoundary - V1's working approach
  static Future<Uint8List?> _capturePreview(GlobalKey? key) async {
    try {
      // If no key provided, skip thumbnail capture
      if (key == null) {
        print('No preview key provided, skipping thumbnail capture');
        return null;
      }

      final RenderObject? renderObject = key.currentContext?.findRenderObject();

      if (renderObject == null) {
        return null;
      }

      // Create RepaintBoundary dynamically like V1
      RenderRepaintBoundary? boundary;

      if (renderObject is RenderRepaintBoundary) {
        boundary = renderObject;
      } else {
        return null;
      }

      // Use high pixel ratio for better quality thumbnails
      const double pixelRatio = 2.0;

      // Use SchedulerBinding to capture after next frame like V1
      final completer = Completer<Uint8List?>();

      SchedulerBinding.instance.addPostFrameCallback((_) async {
        ui.Image? image;
        try {
          // Capture at high resolution
          image = await boundary!.toImage(pixelRatio: pixelRatio);

          final ByteData? byteData = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );

          if (byteData == null) {
            completer.complete(null);
            return;
          }

          final result = byteData.buffer.asUint8List();
          completer.complete(result);
        } catch (e) {
          print('Error capturing preview in post-frame: $e');
          completer.complete(null);
        } finally {
          // Dispose of the image
          image?.dispose();
        }
      });

      return completer.future;
    } catch (e) {
      print('Error in _capturePreview: $e');
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
