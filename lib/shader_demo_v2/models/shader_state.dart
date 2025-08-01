import 'package:flutter/foundation.dart';
import '../models/effect_settings.dart';
import '../models/preset.dart';

/// Single source of truth for all shader demo V2 state
/// This replaces the complex state management from V1
@immutable
class ShaderState {
  /// Core editing state
  final ShaderSettings settings;
  final String selectedImage;
  final bool controlsVisible;

  /// Preset context - tracks what user is editing relative to
  final List<Preset> savedPresets;
  final Preset? basePreset; // What user started editing from
  final bool hasUnsavedChanges;

  /// Navigation context - manages context-aware preset ordering
  final int currentPosition; // Position in navigator
  final List<Preset> navigatorOrder; // Context-aware preset order

  /// Music and audio state
  final bool musicPlaying;
  final double musicPosition;

  const ShaderState({
    required this.settings,
    required this.selectedImage,
    this.controlsVisible = true,
    this.savedPresets = const [],
    this.basePreset,
    this.hasUnsavedChanges = false,
    this.currentPosition = 0,
    this.navigatorOrder = const [],
    this.musicPlaying = false,
    this.musicPosition = 0.0,
  });

  /// Create initial state with default settings
  factory ShaderState.initial() {
    return ShaderState(
      settings: ShaderSettings.defaults,
      selectedImage: '',
      controlsVisible: true,
      savedPresets: const [],
      basePreset: null,
      hasUnsavedChanges: false,
      currentPosition: 0,
      navigatorOrder: const [],
      musicPlaying: false,
      musicPosition: 0.0,
    );
  }

  /// Copy with updated values - supports partial updates
  ShaderState copyWith({
    ShaderSettings? settings,
    String? selectedImage,
    bool? controlsVisible,
    List<Preset>? savedPresets,
    Preset? basePreset,
    bool? clearBasePreset = false,
    bool? hasUnsavedChanges,
    int? currentPosition,
    List<Preset>? navigatorOrder,
    bool? musicPlaying,
    double? musicPosition,
  }) {
    return ShaderState(
      settings: settings ?? this.settings,
      selectedImage: selectedImage ?? this.selectedImage,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      savedPresets: savedPresets ?? this.savedPresets,
      basePreset: clearBasePreset == true
          ? null
          : (basePreset ?? this.basePreset),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      currentPosition: currentPosition ?? this.currentPosition,
      navigatorOrder: navigatorOrder ?? this.navigatorOrder,
      musicPlaying: musicPlaying ?? this.musicPlaying,
      musicPosition: musicPosition ?? this.musicPosition,
    );
  }

  /// Check if current settings are different from base preset
  bool get hasChangesFromBase {
    if (basePreset == null) return hasUnsavedChanges;

    // Compare current settings with base preset settings
    return !_settingsEqual(settings, basePreset!.settings);
  }

  /// Check if current settings match any saved preset exactly
  bool get matchesAnySavedPreset {
    return savedPresets.any(
      (preset) =>
          _settingsEqual(settings, preset.settings) &&
          selectedImage == preset.imagePath,
    );
  }

  /// Get the untitled preset representation if it should be shown
  Preset? get untitledPreset {
    if (!hasUnsavedChanges || matchesAnySavedPreset) return null;

    return Preset.untitled(settings: settings, imagePath: selectedImage);
  }

  /// Helper to compare shader settings for exact equality
  bool _settingsEqual(ShaderSettings a, ShaderSettings b) {
    // Compare settings by serialization for accurate equality check
    return _mapsEqual(a.toMap(), b.toMap());
  }

  /// Helper to compare maps for equality
  bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'ShaderState(settings: $settings, image: $selectedImage, '
        'controlsVisible: $controlsVisible, hasUnsaved: $hasUnsavedChanges, '
        'position: $currentPosition/${navigatorOrder.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShaderState &&
        other.settings == settings &&
        other.selectedImage == selectedImage &&
        other.controlsVisible == controlsVisible &&
        listEquals(other.savedPresets, savedPresets) &&
        other.basePreset == basePreset &&
        other.hasUnsavedChanges == hasUnsavedChanges &&
        other.currentPosition == currentPosition &&
        listEquals(other.navigatorOrder, navigatorOrder) &&
        other.musicPlaying == musicPlaying &&
        other.musicPosition == musicPosition;
  }

  @override
  int get hashCode {
    return Object.hash(
      settings,
      selectedImage,
      controlsVisible,
      Object.hashAll(savedPresets),
      basePreset,
      hasUnsavedChanges,
      currentPosition,
      Object.hashAll(navigatorOrder),
      musicPlaying,
      musicPosition,
    );
  }
}
