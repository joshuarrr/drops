// No imports needed
import 'color_settings.dart';

/// Simplified shader settings model for V3 demo
class ShaderSettings {
  // Basic settings
  bool colorEnabled;
  ColorSettings colorSettings;
  bool imageEnabled;
  String selectedImage;

  // Constructor with defaults
  ShaderSettings({
    this.colorEnabled = false,
    ColorSettings? colorSettings,
    this.imageEnabled = true,
    this.selectedImage = '',
  }) : colorSettings = colorSettings ?? ColorSettings();

  // Create a copy with optional new values
  ShaderSettings copyWith({
    bool? colorEnabled,
    ColorSettings? colorSettings,
    bool? imageEnabled,
    String? selectedImage,
  }) {
    return ShaderSettings(
      colorEnabled: colorEnabled ?? this.colorEnabled,
      colorSettings: colorSettings ?? this.colorSettings,
      imageEnabled: imageEnabled ?? this.imageEnabled,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'colorEnabled': colorEnabled,
      'colorSettings': colorSettings.toMap(),
      'imageEnabled': imageEnabled,
      'selectedImage': selectedImage,
    };
  }

  // Create from map for deserialization
  factory ShaderSettings.fromMap(Map<String, dynamic> map) {
    return ShaderSettings(
      colorEnabled: map['colorEnabled'] as bool? ?? false,
      colorSettings: ColorSettings.fromMap(
        map['colorSettings'] as Map<String, dynamic>? ?? {},
      ),
      imageEnabled: map['imageEnabled'] as bool? ?? true,
      selectedImage: map['selectedImage'] as String? ?? '',
    );
  }
}
