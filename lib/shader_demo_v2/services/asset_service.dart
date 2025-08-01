import 'dart:convert';
import 'package:flutter/services.dart';
import '../utils/logging_utils.dart';

/// Service for loading assets such as images and music
class AssetService {
  /// Load image assets from the asset manifest
  static Future<Map<String, List<String>>> loadImageAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final dynamic manifestJson = json.decode(manifestContent);

      // Support both the legacy and the v2 manifest structure introduced in recent Flutter versions.
      // In the legacy format `manifestJson` is a Map<String, dynamic> whose keys are the asset paths.
      // In the new format it looks like {"version": ..., "assets": { <path>: { ... } }}.
      Iterable<String> assetKeys = [];
      if (manifestJson is Map<String, dynamic>) {
        if (manifestJson.containsKey('assets') &&
            manifestJson['assets'] is Map<String, dynamic>) {
          assetKeys = (manifestJson['assets'] as Map<String, dynamic>).keys;
        } else {
          assetKeys = manifestJson.keys;
        }
      }

      final covers =
          assetKeys
              .where((path) => path.startsWith('assets/img/covers/'))
              .toList()
            ..sort();

      final artists =
          assetKeys
              .where((path) => path.startsWith('assets/img/artists/'))
              .toList()
            ..sort();

      return {'covers': covers, 'artists': artists};
    } catch (e, stack) {
      EffectLogger.log(
        'Failed to load asset manifest: $e',
        level: LogLevel.error,
      );
      EffectLogger.log(stack.toString(), level: LogLevel.error);
      return {'covers': [], 'artists': []};
    }
  }

  /// Load music tracks from the asset manifest
  static Future<List<String>> loadMusicTracks() async {
    EffectLogger.log('Loading music tracks from assets directory');
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final dynamic manifestJson = json.decode(manifestContent);

      // Get asset keys using the same approach as image loading
      Iterable<String> assetKeys = [];
      if (manifestJson is Map<String, dynamic>) {
        if (manifestJson.containsKey('assets') &&
            manifestJson['assets'] is Map<String, dynamic>) {
          assetKeys = (manifestJson['assets'] as Map<String, dynamic>).keys;
        } else {
          assetKeys = manifestJson.keys;
        }
      }

      // Filter for music files - look for assets/music/ with common audio extensions
      final musicExtensions = ['.mp3', '.wav', '.aac', '.ogg', '.flac'];
      final musicTracks =
          assetKeys
              .where(
                (path) =>
                    path.startsWith('assets/music/') &&
                    musicExtensions.any(
                      (ext) => path.toLowerCase().endsWith(ext),
                    ),
              )
              .toList()
            ..sort();

      if (musicTracks.isNotEmpty) {
        EffectLogger.log('Found ${musicTracks.length} music tracks:');
      } else {
        EffectLogger.log(
          'No music tracks found in assets directory',
          level: LogLevel.warning,
        );
      }

      return musicTracks;
    } catch (e, stack) {
      EffectLogger.log('Error loading music tracks: $e', level: LogLevel.error);
      EffectLogger.log(stack.toString(), level: LogLevel.error);
      return [];
    }
  }
}
