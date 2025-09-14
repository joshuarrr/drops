import 'package:flutter/foundation.dart';
import '../models/shader_effect.dart';

/// Service to manage preset refresh notifications across the app
/// This allows panels to notify each other when presets are saved/deleted
class PresetRefreshService extends ChangeNotifier {
  static final PresetRefreshService _instance =
      PresetRefreshService._internal();
  factory PresetRefreshService() => _instance;
  PresetRefreshService._internal();

  // Track refresh counters for each aspect
  final Map<ShaderAspect, int> _refreshCounters = {};

  /// Get the current refresh counter for an aspect
  int getRefreshCounter(ShaderAspect aspect) {
    return _refreshCounters[aspect] ?? 0;
  }

  /// Trigger a refresh for a specific aspect
  void refreshAspect(ShaderAspect aspect) {
    _refreshCounters[aspect] = (_refreshCounters[aspect] ?? 0) + 1;
    notifyListeners();
  }

  /// Trigger a refresh for all aspects
  void refreshAll() {
    for (final aspect in ShaderAspect.values) {
      _refreshCounters[aspect] = (_refreshCounters[aspect] ?? 0) + 1;
    }
    notifyListeners();
  }

  /// Clear all refresh counters (useful for testing)
  void clearAll() {
    _refreshCounters.clear();
    notifyListeners();
  }
}
