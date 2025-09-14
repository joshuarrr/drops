import 'package:flutter/foundation.dart';
import '../models/preset.dart';
import '../services/preset_service.dart';

/// Navigation controller that manages context-aware preset ordering
/// Handles swipe navigation and untitled positioning logic
class NavigationController extends ChangeNotifier {
  List<Preset> _savedPresets = [];
  Preset? _untitledPreset;
  String? _basePresetId; // What user started editing from
  int _currentPosition = 0;
  List<Preset> _navigatorOrder = [];

  // Getters
  List<Preset> get savedPresets => _savedPresets;
  Preset? get untitledPreset => _untitledPreset;
  String? get basePresetId => _basePresetId;
  int get currentPosition => _currentPosition;
  List<Preset> get navigatorOrder => _navigatorOrder;

  /// Get current preset (could be saved or untitled)
  Preset? get currentPreset {
    if (_navigatorOrder.isEmpty) return null;
    if (_currentPosition >= _navigatorOrder.length) return null;
    return _navigatorOrder[_currentPosition];
  }

  /// Check if we're currently viewing the untitled preset
  bool get isViewingUntitled => currentPreset?.isUntitled == true;

  /// Get total number of presets in navigator
  int get totalPresets => _navigatorOrder.length;

  /// Check if we can navigate to previous preset
  bool get canNavigatePrevious => _currentPosition > 0;

  /// Check if we can navigate to next preset
  bool get canNavigateNext => _currentPosition < _navigatorOrder.length - 1;

  /// Initialize with saved presets and optional untitled state
  Future<void> initialize({
    List<Preset>? savedPresets,
    Preset? untitledPreset,
    String? basePresetId,
    int? startPosition,
  }) async {
    _savedPresets = savedPresets ?? await PresetService.loadAllPresets();
    _untitledPreset = untitledPreset;
    _basePresetId = basePresetId;

    _rebuildNavigatorOrder();

    // Set initial position
    if (startPosition != null && startPosition < _navigatorOrder.length) {
      _currentPosition = startPosition;
    } else if (_untitledPreset != null) {
      // Start at untitled if it exists
      _currentPosition = _findUntitledPosition();
    } else if (_navigatorOrder.isNotEmpty) {
      // Start at first preset
      _currentPosition = 0;
    }

    notifyListeners();
  }

  /// Update saved presets (when presets are added/deleted/modified)
  void updateSavedPresets(List<Preset> presets) {
    _savedPresets = presets;
    _rebuildNavigatorOrder();

    // Ensure current position is still valid
    if (_currentPosition >= _navigatorOrder.length) {
      _currentPosition = _navigatorOrder.isEmpty
          ? 0
          : _navigatorOrder.length - 1;
    }

    notifyListeners();
  }

  /// Update untitled preset state
  void updateUntitledPreset({Preset? untitledPreset, String? newBasePresetId}) {
    final hadUntitled = _untitledPreset != null;
    _untitledPreset = untitledPreset;

    // Update base preset if provided
    if (newBasePresetId != null) {
      _basePresetId = newBasePresetId;
    }

    _rebuildNavigatorOrder();

    // If untitled was just created, navigate to it
    if (!hadUntitled && _untitledPreset != null) {
      _currentPosition = _findUntitledPosition();
    }
    // If untitled was removed, stay at current position or adjust
    else if (hadUntitled && _untitledPreset == null) {
      if (_currentPosition >= _navigatorOrder.length) {
        _currentPosition = _navigatorOrder.isEmpty
            ? 0
            : _navigatorOrder.length - 1;
      }
    }

    notifyListeners();
  }

  /// Navigate to specific position
  void navigateToPosition(int position) {
    if (position >= 0 && position < _navigatorOrder.length) {
      _currentPosition = position;
      notifyListeners();
    }
  }

  /// Navigate to specific preset by ID
  void navigateToPreset(String presetId) {
    final index = _navigatorOrder.indexWhere((preset) => preset.id == presetId);

    if (index != -1) {
      _currentPosition = index;
      notifyListeners();
    } else {
      print(
        'ERROR: NavigationController - Preset with ID $presetId not found in navigator order!',
      );
    }
  }

  /// Navigate to next preset
  void navigateNext() {
    if (canNavigateNext) {
      _currentPosition++;
      notifyListeners();
    }
  }

  /// Navigate to previous preset
  void navigatePrevious() {
    if (canNavigatePrevious) {
      _currentPosition--;
      notifyListeners();
    }
  }

  /// Navigate to untitled preset (create if doesn't exist)
  void navigateToUntitled() {
    if (_untitledPreset != null) {
      final untitledIndex = _findUntitledPosition();
      if (untitledIndex != -1) {
        _currentPosition = untitledIndex;
        notifyListeners();
      }
    }
  }

  /// Set base preset for context-aware positioning
  void setBasePreset(String? presetId, {bool rebuildOrder = true}) {
    if (_basePresetId != presetId) {
      _basePresetId = presetId;
      if (rebuildOrder) {
        _rebuildNavigatorOrder();
      }
      notifyListeners();
    }
  }

  /// Calculate where untitled should be positioned relative to base preset
  int calculateUntitledPosition() {
    return PresetService.calculateUntitledPosition(
      savedPresets: _savedPresets,
      basePresetId: _basePresetId,
    );
  }

  /// Get context-aware navigator order
  List<Preset> getContextAwareOrder() {
    return PresetService.getNavigatorOrder(
      savedPresets: _savedPresets,
      untitledPreset: _untitledPreset,
      basePresetId: _basePresetId,
    );
  }

  /// Check if current state has unsaved changes
  bool get hasUnsavedChanges => _untitledPreset != null;

  /// Get navigation info for UI (current position, total, etc.)
  Map<String, dynamic> getNavigationInfo() {
    return {
      'currentPosition': _currentPosition,
      'totalPresets': _navigatorOrder.length,
      'currentPreset': currentPreset?.toJson(),
      'isUntitled': isViewingUntitled,
      'canPrevious': canNavigatePrevious,
      'canNext': canNavigateNext,
      'hasUnsaved': hasUnsavedChanges,
      'basePresetId': _basePresetId,
    };
  }

  /// Rebuild the navigator order based on current state
  void _rebuildNavigatorOrder() {
    _navigatorOrder = PresetService.getNavigatorOrder(
      savedPresets: _savedPresets,
      untitledPreset: _untitledPreset,
      basePresetId: _basePresetId,
    );
  }

  /// Find the position of untitled preset in navigator order
  int _findUntitledPosition() {
    if (_untitledPreset == null) return -1;
    return _navigatorOrder.indexWhere((preset) => preset.isUntitled);
  }

  /// Reset navigation state
  void reset() {
    _savedPresets = [];
    _untitledPreset = null;
    _basePresetId = null;
    _currentPosition = 0;
    _navigatorOrder = [];
    notifyListeners();
  }

  /// Handle preset deletion (adjust navigation if needed)
  void onPresetDeleted(String deletedPresetId) {
    // Remove from saved presets
    _savedPresets.removeWhere((preset) => preset.id == deletedPresetId);

    // Clear base preset if it was deleted
    if (_basePresetId == deletedPresetId) {
      _basePresetId = null;
    }

    _rebuildNavigatorOrder();

    // Adjust current position if needed
    if (_currentPosition >= _navigatorOrder.length) {
      _currentPosition = _navigatorOrder.isEmpty
          ? 0
          : _navigatorOrder.length - 1;
    }

    notifyListeners();
  }

  /// Handle preset creation (add to navigation)
  void onPresetCreated(Preset newPreset) {
    // The preset has already been positioned correctly by the caller
    // Just rebuild the navigator order
    _rebuildNavigatorOrder();

    // Don't automatically navigate to the new preset - let user stay where they are
    // If current position is now out of bounds due to reordering, adjust it
    if (_currentPosition >= _navigatorOrder.length) {
      _currentPosition = _navigatorOrder.isEmpty
          ? 0
          : _navigatorOrder.length - 1;
    }

    notifyListeners();
  }

  /// Get the preset at a specific position (for PageView)
  Preset? getPresetAtPosition(int position) {
    if (position >= 0 && position < _navigatorOrder.length) {
      return _navigatorOrder[position];
    }
    return null;
  }

  @override
  String toString() {
    return 'NavigationController(current: $_currentPosition/${_navigatorOrder.length}, '
        'untitled: ${_untitledPreset != null}, base: $_basePresetId)';
  }
}
