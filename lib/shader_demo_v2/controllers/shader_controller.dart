import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/shader_state.dart';
import '../models/preset.dart';
import '../models/effect_settings.dart';
import '../services/preset_service.dart';
import '../services/storage_service.dart';
import '../controllers/navigation_controller.dart';
import '../services/asset_service.dart';

/// Main business logic coordinator for shader demo V2
/// Handles all user actions, auto-save, and state coordination
class ShaderController extends ChangeNotifier {
  // Core state
  ShaderState _state = ShaderState.initial();

  // Controllers
  late final NavigationController _navigationController;
  // Note: EffectController and MusicController are static/singleton classes in V1

  // Auto-save management
  Timer? _autoSaveTimer;
  static const Duration _autoSaveDelay = Duration(milliseconds: 800);
  bool _isInitializing = false;
  bool _isDisposed = false;

  // Getters for current state
  ShaderState get state => _state;
  ShaderSettings get settings => _state.settings;
  String get selectedImage => _state.selectedImage;
  bool get controlsVisible => _state.controlsVisible;
  List<Preset> get savedPresets => _state.savedPresets;
  Preset? get basePreset => _state.basePreset;
  bool get hasUnsavedChanges => _state.hasUnsavedChanges;
  int get currentPosition => _state.currentPosition;
  List<Preset> get navigatorOrder => _state.navigatorOrder;
  bool get musicPlaying => _state.musicPlaying;
  double get musicPosition => _state.musicPosition;

  // Controller getters
  NavigationController get navigationController => _navigationController;

  /// Initialize the controller with services and load initial state
  Future<void> initialize() async {
    if (_isInitializing || _isDisposed) return;

    _isInitializing = true;

    try {
      // Initialize storage
      await StorageService.initialize();

      // Initialize controllers
      _navigationController = NavigationController();

      // Load saved presets
      final savedPresets = await PresetService.loadAllPresets();

      // Load untitled state if it exists
      final untitledData = await PresetService.loadUntitledState();
      Preset? untitledPreset;
      String? basePresetId;

      if (untitledData != null) {
        try {
          final settings = ShaderSettings.fromMap(
            untitledData['settings'] as Map<String, dynamic>,
          );
          final imagePath = untitledData['imagePath'] as String;
          basePresetId = untitledData['basePresetId'] as String?;

          print(
            'DEBUG: Untitled state - base preset: $basePresetId, image: $imagePath',
          );

          // Validate image path - clear untitled state if it has invalid image
          if (imagePath.contains('album1.jpg') ||
              imagePath.contains('album2.jpg')) {
            print(
              'Found invalid image path in untitled state: $imagePath - clearing untitled state',
            );
            await PresetService.clearUntitledState();
          } else {
            untitledPreset = Preset.untitled(
              settings: settings,
              imagePath: imagePath,
            );
          }
        } catch (e) {
          print('Error loading untitled state: $e');
          // Clear corrupted untitled state
          await PresetService.clearUntitledState();
        }
      }

      // Initialize navigation controller
      await _navigationController.initialize(
        savedPresets: savedPresets,
        untitledPreset: untitledPreset,
        basePresetId: basePresetId,
      );

      // Build initial navigator order
      final navigatorOrder = PresetService.getNavigatorOrder(
        savedPresets: savedPresets,
        untitledPreset: untitledPreset,
        basePresetId: basePresetId,
      );

      print(
        'DEBUG: Navigator order length: ${navigatorOrder.length}, current position: ${_navigationController.currentPosition}',
      );

      // Determine initial settings: prioritize current preset from navigation, then untitled, then defaults
      ShaderSettings initialSettings;
      String initialImage;
      Preset? initialBasePreset;

      final currentPreset = _navigationController.currentPreset;
      if (currentPreset != null) {
        // Use the current preset from navigation (could be saved preset or untitled)
        initialSettings = currentPreset.settings;
        initialImage = currentPreset.imagePath;
        if (currentPreset.isUntitled && basePresetId != null) {
          final matchingPresets = savedPresets.where(
            (p) => p.id == basePresetId,
          );
          initialBasePreset = matchingPresets.isNotEmpty
              ? matchingPresets.first
              : (savedPresets.isNotEmpty ? savedPresets.first : null);
        } else if (!currentPreset.isUntitled) {
          initialBasePreset = currentPreset;
        } else {
          initialBasePreset = null;
        }
        print(
          'DEBUG: Using current preset from navigation: ${currentPreset.name}',
        );
      } else if (untitledPreset != null) {
        // Fallback to untitled preset
        initialSettings = untitledPreset.settings;
        initialImage = untitledPreset.imagePath;
        if (basePresetId != null) {
          final matchingPresets = savedPresets.where(
            (p) => p.id == basePresetId,
          );
          initialBasePreset = matchingPresets.isNotEmpty
              ? matchingPresets.first
              : (savedPresets.isNotEmpty ? savedPresets.first : null);
        } else {
          initialBasePreset = null;
        }
      } else if (savedPresets.isNotEmpty) {
        // If no untitled state, default to first saved preset
        final firstPreset = savedPresets.first;
        initialSettings = firstPreset.settings;
        initialImage = firstPreset.imagePath;
        initialBasePreset = firstPreset;
      } else {
        // Last resort: use defaults
        initialSettings = ShaderSettings.defaults;
        initialImage = '';
        initialBasePreset = null;
      }

      // Create initial state
      _state = ShaderState(
        settings: initialSettings,
        selectedImage: initialImage,
        controlsVisible: false,
        savedPresets: savedPresets,
        basePreset: initialBasePreset,
        hasUnsavedChanges: untitledPreset != null,
        currentPosition: _navigationController.currentPosition,
        navigatorOrder: navigatorOrder,
        musicPlaying: false,
        musicPosition: 0.0,
      );

      // Load image assets and set default image if needed
      await _loadImageAssets();

      // Listen to navigation changes
      _navigationController.addListener(_onNavigationChanged);

      _isInitializing = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing ShaderController: $e');
      _isInitializing = false;
      rethrow;
    }
  }

  /// Load image assets and set default image if current selectedImage is empty or invalid
  Future<void> _loadImageAssets() async {
    try {
      final images = await AssetService.loadImageAssets();
      final coverImages = images['covers'] ?? [];
      final artistImages = images['artists'] ?? [];

      // Check if current image is valid
      final currentImage = _state.selectedImage;
      bool isCurrentValid =
          currentImage.isNotEmpty &&
          (coverImages.contains(currentImage) ||
              artistImages.contains(currentImage));

      if (!isCurrentValid) {
        // Set default image to first available image
        String defaultImage = '';
        if (coverImages.isNotEmpty) {
          defaultImage = coverImages.first;
        } else if (artistImages.isNotEmpty) {
          defaultImage = artistImages.first;
        }

        if (defaultImage.isNotEmpty) {
          _state = _state.copyWith(selectedImage: defaultImage);
          print('Set default image: $defaultImage (was: $currentImage)');

          // If we had to fix an invalid image path, update any saved state
          await _fixInvalidImageReferences(currentImage, defaultImage);
        }
      }
    } catch (e) {
      print('Error loading image assets: $e');
    }
  }

  /// Fix any saved presets or untitled state that have invalid image references
  Future<void> _fixInvalidImageReferences(
    String invalidPath,
    String validPath,
  ) async {
    try {
      if (invalidPath.isEmpty) return; // No need to fix empty paths

      print('Fixing invalid image reference: $invalidPath -> $validPath');

      // Check if there's untitled state with the invalid path
      final untitledData = await PresetService.loadUntitledState();
      if (untitledData != null && untitledData['imagePath'] == invalidPath) {
        print('Fixing untitled state image path');
        await PresetService.saveUntitledState(
          settings: ShaderSettings.fromMap(
            untitledData['settings'] as Map<String, dynamic>,
          ),
          imagePath: validPath,
          basePresetId: untitledData['basePresetId'] as String?,
        );
      }

      // Note: We could also fix saved presets here if needed, but they're less likely
      // to have this issue since they're usually created through the UI with valid images
    } catch (e) {
      print('Error fixing invalid image references: $e');
    }
  }

  /// Handle navigation changes from NavigationController
  void _onNavigationChanged() {
    if (_isDisposed) return;

    final currentPreset = _navigationController.currentPreset;
    if (currentPreset != null) {
      // Update state to reflect navigation change
      _state = _state.copyWith(
        settings: currentPreset.settings,
        selectedImage: currentPreset.imagePath,
        currentPosition: _navigationController.currentPosition,
        navigatorOrder: _navigationController.navigatorOrder,
        basePreset: currentPreset.isUntitled
            ? _state.basePreset
            : currentPreset,
        hasUnsavedChanges: currentPreset.isUntitled,
      );

      // Note: Effect controller updates will be handled by UI components

      notifyListeners();
    }
  }

  /// Update shader settings (triggered by control changes)
  void updateSettings(ShaderSettings newSettings) {
    if (_isDisposed) return;

    _state = _state.copyWith(settings: newSettings, hasUnsavedChanges: true);

    // Trigger auto-save
    _scheduleAutoSave();

    notifyListeners();
  }

  /// Update selected image
  void updateSelectedImage(String imagePath) {
    if (_isDisposed) return;

    _state = _state.copyWith(selectedImage: imagePath, hasUnsavedChanges: true);

    // Trigger auto-save
    _scheduleAutoSave();

    notifyListeners();
  }

  /// Toggle controls visibility
  void toggleControls() {
    if (_isDisposed) return;

    _state = _state.copyWith(controlsVisible: !_state.controlsVisible);

    notifyListeners();
  }

  /// Set controls visibility
  void setControlsVisible(bool visible) {
    if (_isDisposed) return;

    _state = _state.copyWith(controlsVisible: visible);

    notifyListeners();
  }

  /// Navigate to next preset
  void navigateNext() {
    _navigationController.navigateNext();
  }

  /// Navigate to previous preset
  void navigatePrevious() {
    _navigationController.navigatePrevious();
  }

  /// Navigate to specific preset
  void navigateToPreset(String presetId) {
    _navigationController.navigateToPreset(presetId);
  }

  /// Load a specific preset (sets it as base and navigates to it)
  Future<void> loadPreset(Preset preset) async {
    if (_isDisposed) return;

    // Clear any existing untitled changes FIRST to avoid navigator order changes
    await _clearUntitledState();

    // Navigate to the preset directly without changing base preset or reordering
    _navigationController.navigateToPreset(preset.id);

    // Set as base preset for future context-aware navigation but don't rebuild order
    _navigationController.setBasePreset(preset.id, rebuildOrder: false);

    // The _onNavigationChanged listener will handle updating the state
    // with the correct settings from the preset
  }

  /// Start editing from a preset (creates untitled based on preset)
  void startEditingFromPreset(Preset preset) {
    if (_isDisposed) return;

    // Set base preset for context
    _navigationController.setBasePreset(preset.id);

    // Create untitled preset
    final untitledPreset = Preset.untitled(
      settings: preset.settings,
      imagePath: preset.imagePath,
    );

    // Update navigation controller
    _navigationController.updateUntitledPreset(
      untitledPreset: untitledPreset,
      newBasePresetId: preset.id,
    );

    // Update state
    _state = _state.copyWith(
      settings: preset.settings,
      selectedImage: preset.imagePath,
      basePreset: preset,
      hasUnsavedChanges: true,
      navigatorOrder: _navigationController.navigatorOrder,
      currentPosition: _navigationController.currentPosition,
    );

    // Trigger auto-save
    _scheduleAutoSave();

    notifyListeners();
  }

  /// Save current state as named preset
  Future<bool> saveNamedPreset(String name) async {
    if (_isDisposed) return false;

    try {
      // Store current state to preserve it during navigation changes
      final currentSettings = _state.settings;
      final currentImage = _state.selectedImage;

      // Generate thumbnail (simplified - in real app would capture actual render)
      // For now, just pass null and handle thumbnail generation elsewhere
      final preset = await PresetService.saveNamedPreset(
        name: name,
        settings: currentSettings,
        imagePath: currentImage,
        thumbnailBase64: null, // TODO: Generate actual thumbnail
      );

      if (preset != null) {
        // Update saved presets
        final updatedPresets = [..._state.savedPresets, preset];
        updatedPresets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Temporarily remove listener to prevent _onNavigationChanged from overriding state
        _navigationController.removeListener(_onNavigationChanged);

        // Update navigation controller
        _navigationController.onPresetCreated(preset);

        // Clear untitled state
        await _clearUntitledState();

        // Re-add the listener
        _navigationController.addListener(_onNavigationChanged);

        // Update state - explicitly preserve current settings and image
        _state = _state.copyWith(
          settings: currentSettings, // Preserve current settings
          selectedImage: currentImage, // Preserve current image
          savedPresets: updatedPresets,
          hasUnsavedChanges: false,
          basePreset: preset,
          navigatorOrder: _navigationController.navigatorOrder,
          currentPosition: _navigationController.currentPosition,
        );

        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error saving preset: $e');
    }

    return false;
  }

  /// Delete a preset
  Future<bool> deletePreset(String presetId) async {
    if (_isDisposed) return false;

    try {
      final success = await PresetService.deletePreset(presetId);

      if (success) {
        // Update navigation controller
        _navigationController.onPresetDeleted(presetId);

        // Update saved presets
        final updatedPresets = _state.savedPresets
            .where((preset) => preset.id != presetId)
            .toList();

        // Update state
        _state = _state.copyWith(
          savedPresets: updatedPresets,
          navigatorOrder: _navigationController.navigatorOrder,
          currentPosition: _navigationController.currentPosition,
        );

        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error deleting preset: $e');
    }

    return false;
  }

  /// Rename a preset
  Future<bool> renamePreset(String presetId, String newName) async {
    if (_isDisposed) return false;

    try {
      final success = await PresetService.renamePreset(presetId, newName);

      if (success) {
        // Reload presets to get updated data
        final updatedPresets = await PresetService.loadAllPresets();

        // Update navigation controller
        _navigationController.updateSavedPresets(updatedPresets);

        // Update state
        _state = _state.copyWith(
          savedPresets: updatedPresets,
          navigatorOrder: _navigationController.navigatorOrder,
        );

        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error renaming preset: $e');
    }

    return false;
  }

  /// Schedule auto-save with debouncing
  void _scheduleAutoSave() {
    if (_isDisposed) return;

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(_autoSaveDelay, _performAutoSave);
  }

  /// Perform auto-save of current state
  Future<void> _performAutoSave() async {
    if (_isDisposed || !_state.hasUnsavedChanges) return;

    try {
      await PresetService.saveUntitledState(
        settings: _state.settings,
        imagePath: _state.selectedImage,
        basePresetId: _state.basePreset?.id,
      );

      // Update navigation with untitled preset
      final untitledPreset = Preset.untitled(
        settings: _state.settings,
        imagePath: _state.selectedImage,
      );

      _navigationController.updateUntitledPreset(
        untitledPreset: untitledPreset,
        newBasePresetId: _state.basePreset?.id,
      );

      // Update state with new navigator order (smart deduplication happens in getNavigatorOrder)
      _state = _state.copyWith(
        navigatorOrder: _navigationController.navigatorOrder,
        currentPosition: _navigationController.currentPosition,
      );

      notifyListeners();
    } catch (e) {
      print('Error performing auto-save: $e');
    }
  }

  /// Clear untitled state
  Future<void> _clearUntitledState() async {
    try {
      await PresetService.clearUntitledState();

      _navigationController.updateUntitledPreset(untitledPreset: null);

      _state = _state.copyWith(
        hasUnsavedChanges: false,
        navigatorOrder: _navigationController.navigatorOrder,
        currentPosition: _navigationController.currentPosition,
      );
    } catch (e) {
      print('Error clearing untitled state: $e');
    }
  }

  /// Reset to initial state
  Future<void> reset() async {
    if (_isDisposed) return;

    _autoSaveTimer?.cancel();
    await _clearUntitledState();
    _navigationController.reset();

    _state = ShaderState.initial();

    notifyListeners();
  }

  /// Update music state
  void updateMusicState({bool? playing, double? position}) {
    if (_isDisposed) return;

    // PERFORMANCE FIX: Only trigger rebuilds if state actually changed
    bool stateChanged = false;

    if (playing != null && _state.musicPlaying != playing) {
      stateChanged = true;
    }

    // For position updates, only trigger rebuild if it's a significant change (> 1 second)
    if (position != null && (_state.musicPosition - position).abs() > 1.0) {
      stateChanged = true;
    }

    if (stateChanged) {
      _state = _state.copyWith(musicPlaying: playing, musicPosition: position);
      notifyListeners();
    } else {
      // Update state silently without triggering rebuilds
      _state = _state.copyWith(musicPlaying: playing, musicPosition: position);
    }
  }

  /// Methods for individual control panel presets
  /// Load presets for a specific effect aspect
  Future<List<Map<String, dynamic>>> loadPresetsForAspect(String aspect) async {
    // TODO: Implement individual effect presets in Phase 2
    // For now return empty list to avoid errors
    return [];
  }

  /// Delete preset for specific aspect
  Future<bool> deletePresetAndUpdate(String aspect, String name) async {
    // TODO: Implement individual effect preset deletion in Phase 2
    return false;
  }

  /// Refresh presets - triggers UI update
  Future<void> refreshPresets() async {
    if (_isDisposed) return;

    try {
      // Reload presets from storage
      final updatedPresets = await PresetService.loadAllPresets();

      // Update the main state with fresh presets
      _state = _state.copyWith(savedPresets: updatedPresets);

      // Update the navigation controller with fresh presets
      _navigationController.updateSavedPresets(updatedPresets);

      // Force UI update by notifying listeners
      notifyListeners();
    } catch (e) {
      print('Error refreshing presets: $e');
    }
  }

  /// Set music volume (called by music panel)
  void setMusicVolume(double volume) {
    if (_isDisposed) return;

    final newSettings = _copySettings(_state.settings);
    newSettings.musicSettings.volume = volume;
    updateSettings(newSettings);
  }

  /// Helper to create a copy of shader settings
  ShaderSettings _copySettings(ShaderSettings settings) {
    // PERFORMANCE FIX: Use the built-in copy method instead of expensive fromMap/toMap
    return settings.copy();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoSaveTimer?.cancel();
    _navigationController.removeListener(_onNavigationChanged);
    _navigationController.dispose();
    super.dispose();
  }

  @override
  String toString() {
    return 'ShaderController(position: ${_state.currentPosition}/${_state.navigatorOrder.length}, '
        'hasUnsaved: ${_state.hasUnsavedChanges}, controls: ${_state.controlsVisible})';
  }
}
