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

  const ShaderPreset({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.settings,
    required this.imagePath,
    this.thumbnailData,
    this.sortMethod,
    this.isHiddenFromSlideshow = false,
  });

  /// Create a map representation for storage
  Map<String, dynamic> toMap() {
    try {
      // First get the settings map, which now safely handles Color objects
      final settingsMap = settings.toMap();

      return {
        'id': id,
        'name': name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'settings': settingsMap,
        'imagePath': imagePath,
        'sortMethod': sortMethod?.index,
        'isHiddenFromSlideshow': isHiddenFromSlideshow,
        // Thumbnail is stored separately
      };
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
    );
  }
}
