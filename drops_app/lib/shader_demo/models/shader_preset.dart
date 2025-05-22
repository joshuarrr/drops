import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'effect_settings.dart';

/// Enum representing different sort methods for presets
enum PresetSortMethod { dateNewest, alphabetical, reverseAlphabetical, random }

/// Model for storing shader presets with a thumbnail
class ShaderPreset {
  /// Unique identifier for this preset
  final String id;

  /// User-defined name for the preset
  final String name;

  /// Date when this preset was created
  final DateTime createdAt;

  /// Complete shader settings for this preset
  final ShaderSettings settings;

  /// Selected image path for this preset
  final String imagePath;

  /// Optional thumbnail image data
  final Uint8List? thumbnailData;

  /// Current sort method applied when this preset was selected
  final PresetSortMethod? sortMethod;

  /// Whether this preset should be hidden from slideshows
  final bool isHiddenFromSlideshow;

  /// Additional settings that need to be directly accessible
  final Map<String, dynamic>? specificSettings;

  ShaderPreset({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.settings,
    required this.imagePath,
    this.thumbnailData,
    this.sortMethod,
    this.isHiddenFromSlideshow = false,
    this.specificSettings,
  }) {
    // Only log preset creation when it has specific settings
    // to avoid excessive logging during bulk loading
    assert(() {
      if (specificSettings != null) {
        debugPrint('Creating ShaderPreset: $name');
        debugPrint(
          '  with specificSettings: ${specificSettings!.keys.join(', ')}',
        );
      }
      return true;
    }());
  }

  /// Get margin value with consistent fallback
  double getMargin() {
    if (specificSettings != null &&
        specificSettings!.containsKey('fitScreenMargin')) {
      return (specificSettings!['fitScreenMargin'] as num).toDouble();
    }
    // Default to settings value if no specific override
    return settings.textLayoutSettings.fitScreenMargin;
  }

  /// Get fillScreen value with consistent fallback
  bool getFillScreen() {
    if (specificSettings != null &&
        specificSettings!.containsKey('fillScreen')) {
      return specificSettings!['fillScreen'] as bool;
    }
    // Default to settings value if no specific override
    return settings.fillScreen;
  }

  /// Create a map representation for storage
  Map<String, dynamic> toMap() {
    try {
      // First get the settings map, which now safely handles Color objects
      final settingsMap = settings.toMap();

      // Start with the base map
      final resultMap = {
        'id': id,
        'name': name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'settings': settingsMap,
        'imagePath': imagePath,
        'sortMethod': sortMethod?.index,
        'isHiddenFromSlideshow': isHiddenFromSlideshow,
        // Thumbnail is stored separately
      };

      // Add any specific settings that should be directly accessible
      if (specificSettings != null) {
        resultMap.addAll(specificSettings!);
        // Only log when specificSettings exist to reduce log noise
        debugPrint('ShaderPreset.toMap: Adding specificSettings to $name:');
        if (specificSettings!.containsKey('fitScreenMargin')) {
          debugPrint('  margin: ${specificSettings!['fitScreenMargin']}');
        }
        if (specificSettings!.containsKey('fillScreen')) {
          debugPrint('  fillScreen: ${specificSettings!['fillScreen']}');
        }
      }

      return resultMap;
    } catch (e) {
      debugPrint('Error serializing ShaderPreset: $e');
      // Return minimal data to avoid complete failure
      return {
        'id': id,
        'name': name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'settings': {'textEnabled': false}, // Minimal fallback
        'imagePath': imagePath,
        'isHiddenFromSlideshow': isHiddenFromSlideshow,
      };
    }
  }

  /// Create a new instance from a map
  factory ShaderPreset.fromMap(
    Map<String, dynamic> map, {
    Uint8List? thumbnail,
  }) {
    // Convert the sort method index to enum value if it exists
    PresetSortMethod? sortMethod;
    if (map['sortMethod'] != null) {
      sortMethod = PresetSortMethod.values[map['sortMethod'] as int];
    }

    // Extract specific settings (filtering out known keys)
    final knownKeys = [
      'id',
      'name',
      'createdAt',
      'settings',
      'imagePath',
      'sortMethod',
      'isHiddenFromSlideshow',
    ];

    final specificSettings = Map<String, dynamic>.fromEntries(
      map.entries.where((entry) => !knownKeys.contains(entry.key)),
    );

    return ShaderPreset(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      settings: ShaderSettings.fromMap(
        Map<String, dynamic>.from(map['settings'] as Map),
      ),
      imagePath: map['imagePath'] as String,
      thumbnailData: thumbnail,
      sortMethod: sortMethod,
      isHiddenFromSlideshow: map['isHiddenFromSlideshow'] as bool? ?? false,
      specificSettings: specificSettings.isNotEmpty ? specificSettings : null,
    );
  }

  /// Create a copy with updated values
  ShaderPreset copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    ShaderSettings? settings,
    String? imagePath,
    Uint8List? thumbnailData,
    PresetSortMethod? sortMethod,
    bool? isHiddenFromSlideshow,
    Map<String, dynamic>? specificSettings,
  }) {
    return ShaderPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
      imagePath: imagePath ?? this.imagePath,
      thumbnailData: thumbnailData ?? this.thumbnailData,
      sortMethod: sortMethod ?? this.sortMethod,
      isHiddenFromSlideshow:
          isHiddenFromSlideshow ?? this.isHiddenFromSlideshow,
      specificSettings: specificSettings ?? this.specificSettings,
    );
  }
}
