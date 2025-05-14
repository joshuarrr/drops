enum AnimationMode { pulse, randomixed }

enum AnimationEasing { linear, easeIn, easeOut, easeInOut }

// New data class bundling all animation configuration parameters together.
class AnimationOptions {
  // Normalised speed (0.0 = slowest, 1.0 = fastest). It mirrors the value fed
  // into the original speed slider so we can reuse the same 0-1 range.
  double speed;

  // Animation behaviour (pulse vs randomised).
  AnimationMode mode;

  // Easing curve to apply.
  AnimationEasing easing;

  AnimationOptions({
    this.speed = 0.5,
    this.mode = AnimationMode.pulse,
    this.easing = AnimationEasing.linear,
  });

  // ---------------------------------------------------------------------------
  // Helpers for (de)serialisation so the options can be persisted together with
  // the rest of the user settings.
  // ---------------------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {'speed': speed, 'mode': mode.index, 'easing': easing.index};
  }

  factory AnimationOptions.fromMap(Map<String, dynamic> map) {
    return AnimationOptions(
      speed: (map['speed'] as num?)?.toDouble() ?? 0.5,
      mode: AnimationMode.values[map['mode'] as int? ?? 0],
      easing: AnimationEasing.values[map['easing'] as int? ?? 0],
    );
  }

  // Support convenient copying when we only need to change a single property.
  AnimationOptions copyWith({
    double? speed,
    AnimationMode? mode,
    AnimationEasing? easing,
  }) {
    return AnimationOptions(
      speed: speed ?? this.speed,
      mode: mode ?? this.mode,
      easing: easing ?? this.easing,
    );
  }
}
