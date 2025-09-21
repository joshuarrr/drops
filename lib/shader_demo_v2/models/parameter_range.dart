import 'dart:math' as math;

/// Stores the user-defined envelope for a lockable slider parameter.
///
/// The range clamps values to the provided hard min/max while exposing
/// mutable min/max handles that users can adjust independently of the
/// current animated value.
class ParameterRange {
  final double hardMin;
  final double hardMax;
  double userMin;
  double userMax;
  double current;

  ParameterRange({
    required this.hardMin,
    required this.hardMax,
    required double initialValue,
    double? userMin,
    double? userMax,
  })  : userMin = _clampValue(userMin ?? hardMin, hardMin, hardMax),
        userMax = _clampValue(userMax ?? initialValue, hardMin, hardMax),
        current = _clampValue(initialValue, hardMin, hardMax) {
    _normalizeOrdering();
    _clampCurrentToUserWindow();
  }

  /// Construct from persisted data, falling back to sensible defaults when
  /// min/max entries are absent (legacy payloads).
  factory ParameterRange.fromMap(
    Map<String, dynamic>? map, {
    required double hardMin,
    required double hardMax,
    required double fallbackValue,
  }) {
    if (map == null) {
      return ParameterRange(
        hardMin: hardMin,
        hardMax: hardMax,
        initialValue: fallbackValue,
        userMin: hardMin,
        userMax: fallbackValue,
      );
    }

    double _read(String key, double defaultValue) {
      final value = map[key];
      if (value is num) return value.toDouble();
      return defaultValue;
    }

    return ParameterRange(
      hardMin: hardMin,
      hardMax: hardMax,
      initialValue: _read('current', fallbackValue),
      userMin: map.containsKey('userMin')
          ? _read('userMin', hardMin)
          : _read('min', hardMin),
      userMax: map.containsKey('userMax')
          ? _read('userMax', fallbackValue)
          : _read('max', fallbackValue),
    );
  }

  ParameterRange copy() => ParameterRange(
        hardMin: hardMin,
        hardMax: hardMax,
        initialValue: current,
        userMin: userMin,
        userMax: userMax,
      );

  Map<String, dynamic> toMap() => {
        'current': current,
        'userMin': userMin,
        'userMax': userMax,
      };

  void setCurrent(double value, {bool syncUserMax = true}) {
    current = _clampValue(value, hardMin, hardMax);
    if (syncUserMax) {
      userMax = math.max(userMin, current);
    }
    _clampCurrentToUserWindow();
  }

  void setUserMin(double value) {
    userMin = _clampValue(value, hardMin, hardMax);
    if (userMin > userMax) {
      userMax = userMin;
    }
    _clampCurrentToUserWindow();
  }

  void setUserMax(double value) {
    userMax = _clampValue(value, hardMin, hardMax);
    if (userMax < userMin) {
      userMin = userMax;
    }
    _clampCurrentToUserWindow();
  }

  void resetToDefaults({double? defaultMin, double? defaultMax}) {
    userMin = _clampValue(defaultMin ?? hardMin, hardMin, hardMax);
    userMax = _clampValue(defaultMax ?? current, hardMin, hardMax);
    current = _clampValue(userMax, hardMin, hardMax);
    _normalizeOrdering();
  }

  void _normalizeOrdering() {
    if (userMin > userMax) {
      final mid = (userMin + userMax) / 2;
      userMin = mid;
      userMax = mid;
    }
  }

  void _clampCurrentToUserWindow() {
    current = current.clamp(userMin, userMax).toDouble();
  }

  static double _clampValue(double value, double min, double max) {
    if (value.isNaN) return min;
    return value.clamp(min, max).toDouble();
  }
}
