import 'package:flutter/foundation.dart';
import '../models/effect_settings.dart';
import '../services/storage_service.dart';

/// Simplified preset model for V2
/// Focuses on data representation, business logic handled by services
@immutable
class Preset {
  final String id;
  final String name;
  final DateTime createdAt;
  final ShaderSettings settings;
  final String imagePath;
  final String? thumbnailBase64; // Optional thumbnail data
  final bool isUntitled;

  const Preset({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.settings,
    required this.imagePath,
    this.thumbnailBase64,
    this.isUntitled = false,
  });

  /// Create an untitled preset for tracking unsaved changes
  factory Preset.untitled({
    required ShaderSettings settings,
    required String imagePath,
  }) {
    return Preset(
      id: 'untitled',
      name: 'Untitled',
      createdAt: DateTime.now(),
      settings: settings,
      imagePath: imagePath,
      thumbnailBase64: null,
      isUntitled: true,
    );
  }

  /// Create a named preset from current state
  factory Preset.fromCurrent({
    required String name,
    required ShaderSettings settings,
    required String imagePath,
    String? thumbnailBase64,
  }) {
    return Preset(
      id: _generateId(),
      name: name,
      createdAt: DateTime.now(),
      settings: settings,
      imagePath: imagePath,
      thumbnailBase64: thumbnailBase64,
      isUntitled: false,
    );
  }

  /// Create preset from JSON data (for import/export)
  factory Preset.fromJson(Map<String, dynamic> json) {
    return Preset(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      settings: ShaderSettings.fromMap(
        json['settings'] as Map<String, dynamic>,
      ),
      imagePath: json['imagePath'] as String,
      thumbnailBase64: json['thumbnail'] as String?,
      isUntitled: json['isUntitled'] as bool? ?? false,
    );
  }

  /// Convert to JSON for export/storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'settings': settings.toMap(),
      'imagePath': imagePath,
      if (thumbnailBase64 != null) 'thumbnail': thumbnailBase64,
      'isUntitled': isUntitled,
    };
  }

  /// Copy with updated values
  Preset copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    ShaderSettings? settings,
    String? imagePath,
    String? thumbnailBase64,
    bool? clearThumbnail = false,
    bool? isUntitled,
  }) {
    return Preset(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
      imagePath: imagePath ?? this.imagePath,
      thumbnailBase64: clearThumbnail == true
          ? null
          : (thumbnailBase64 ?? this.thumbnailBase64),
      isUntitled: isUntitled ?? this.isUntitled,
    );
  }

  /// Check if this preset has the same content as another (for deduplication)
  bool hasIdenticalContent(Preset other) {
    // Compare settings by serialization for now (can be optimized later)
    return _mapsEqual(settings.toMap(), other.settings.toMap()) &&
        imagePath == other.imagePath;
  }

  /// Helper to compare maps for equality
  bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  /// Check if preset has a thumbnail (in memory or storage)
  bool get hasThumbnail {
    // Check in-memory first
    if (thumbnailBase64 != null && thumbnailBase64!.isNotEmpty) {
      return true;
    }

    // Check storage for saved thumbnail
    final stored = StorageService.loadPresetThumbnail(id);
    return stored != null && stored.isNotEmpty;
  }

  /// Get thumbnail data from memory or storage
  String? get effectiveThumbnailBase64 {
    // Return in-memory thumbnail if available
    if (thumbnailBase64 != null && thumbnailBase64!.isNotEmpty) {
      return thumbnailBase64;
    }

    // Fall back to storage
    return StorageService.loadPresetThumbnail(id);
  }

  /// Get display name (handles untitled case)
  String get displayName => isUntitled ? 'Untitled' : name;

  /// Generate a unique ID for new presets
  static String _generateId() {
    return 'preset_${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  /// Generate random string for ID uniqueness
  static String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      length,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }

  @override
  String toString() {
    return 'Preset(id: $id, name: $name, isUntitled: $isUntitled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Preset &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.settings == settings &&
        other.imagePath == imagePath &&
        other.thumbnailBase64 == thumbnailBase64 &&
        other.isUntitled == isUntitled;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      createdAt,
      settings,
      imagePath,
      thumbnailBase64,
      isUntitled,
    );
  }
}
