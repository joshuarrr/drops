// No imports needed

/// Simple color settings model for V3 demo
class ColorSettings {
  // HSL color properties
  double hue;
  double saturation;
  double lightness;

  // Animation control
  bool colorAnimated;

  // Constructor with defaults
  ColorSettings({
    this.hue = 0.0,
    this.saturation = 0.0,
    this.lightness = 0.0,
    this.colorAnimated = false,
  });

  // Create a copy with optional new values
  ColorSettings copyWith({
    double? hue,
    double? saturation,
    double? lightness,
    bool? colorAnimated,
  }) {
    return ColorSettings(
      hue: hue ?? this.hue,
      saturation: saturation ?? this.saturation,
      lightness: lightness ?? this.lightness,
      colorAnimated: colorAnimated ?? this.colorAnimated,
    );
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'hue': hue,
      'saturation': saturation,
      'lightness': lightness,
      'colorAnimated': colorAnimated,
    };
  }

  // Create from map for deserialization
  factory ColorSettings.fromMap(Map<String, dynamic> map) {
    return ColorSettings(
      hue: map['hue'] as double? ?? 0.0,
      saturation: map['saturation'] as double? ?? 0.0,
      lightness: map['lightness'] as double? ?? 0.0,
      colorAnimated: map['colorAnimated'] as bool? ?? false,
    );
  }
}
