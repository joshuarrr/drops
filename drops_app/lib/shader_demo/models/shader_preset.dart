import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'effect_settings.dart';

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

  const ShaderPreset({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.settings,
    required this.imagePath,
    this.thumbnailData,
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
      };
    }
  }

  /// Create a new instance from a map
  factory ShaderPreset.fromMap(
    Map<String, dynamic> map, {
    Uint8List? thumbnail,
  }) {
    return ShaderPreset(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      settings: ShaderSettings.fromMap(
        Map<String, dynamic>.from(map['settings'] as Map),
      ),
      imagePath: map['imagePath'] as String,
      thumbnailData: thumbnail,
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
  }) {
    return ShaderPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
      imagePath: imagePath ?? this.imagePath,
      thumbnailData: thumbnailData ?? this.thumbnailData,
    );
  }
}
