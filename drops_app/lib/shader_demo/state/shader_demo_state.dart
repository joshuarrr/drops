import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/shader_preset.dart';
import '../models/image_category.dart';
import '../controllers/preset_controller.dart';
import '../utils/logging_utils.dart';

/// Manages the state for the ShaderDemo screen
class ShaderDemoState {
  // State variables
  bool showControls = true;
  ShaderAspect selectedAspect = ShaderAspect.color;
  bool showAspectSliders = false;
  late ShaderSettings shaderSettings;
  List<String> coverImages = [];
  List<String> artistImages = [];
  ImageCategory imageCategory = ImageCategory.covers;
  String selectedImage = '';
  bool isPresetDialogOpen = false;
  List<ShaderPreset> availablePresets = [];
  int currentPresetIndex = -1;
  bool presetsLoaded = false;
  ShaderSettings? unsavedSettings;
  String? unsavedImage;
  ImageCategory? unsavedCategory;
  bool isScrolling = false;
  String? currentUntitledPresetId;

  // Default values that should be consistent across the app
  static const double defaultMargin = 50.0;
  static const bool defaultFillScreen = false;

  // Persistent storage key
  static const String kShaderSettingsKey = 'shader_demo_settings';

  // Constructor - initialize with default values
  ShaderDemoState() {
    shaderSettings = ShaderSettings();
    _initializeDefaultSettings();
  }

  // Initialize default settings
  void _initializeDefaultSettings() {
    shaderSettings.colorSettings.applyToImage = true;
    shaderSettings.colorSettings.applyToText = true;
    shaderSettings.blurSettings.applyToImage = true;
    shaderSettings.blurSettings.applyToText = true;
    shaderSettings.noiseSettings.applyToImage = true;
    shaderSettings.noiseSettings.applyToText = true;
    shaderSettings.rainSettings.applyToImage = true;
    shaderSettings.rainSettings.applyToText = true;
    shaderSettings.chromaticSettings.applyToImage = true;
    shaderSettings.chromaticSettings.applyToText = true;
    shaderSettings.rippleSettings.applyToImage = true;
    shaderSettings.rippleSettings.applyToText = true;

    // Set consistent default values for image display
    shaderSettings.fillScreen = defaultFillScreen;
    shaderSettings.textLayoutSettings.fitScreenMargin = defaultMargin;
  }

  // Load shader settings from SharedPreferences
  Future<void> loadShaderSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(kShaderSettingsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);

        // Support legacy format where only settings map was stored
        if (map.containsKey('settings')) {
          shaderSettings = ShaderSettings.fromMap(
            Map<String, dynamic>.from(map['settings'] as Map),
          );
          selectedImage = map['selectedImage'] as String? ?? selectedImage;
          imageCategory = ImageCategory
              .values[(map['imageCategory'] as int?) ?? imageCategory.index];
        } else {
          // Legacy: map is the settings itself
          shaderSettings = ShaderSettings.fromMap(map);
        }
      }
    } catch (e, stack) {
      debugPrint('ShaderDemoImpl: Failed to load settings → $e\n$stack');
    }
  }

  // Save shader settings to SharedPreferences
  Future<void> saveShaderSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'settings': shaderSettings.toMap(),
        'selectedImage': selectedImage,
        'imageCategory': imageCategory.index,
      };
      await prefs.setString(kShaderSettingsKey, jsonEncode(payload));
    } catch (e, stack) {
      debugPrint('ShaderDemoImpl: Failed to save settings → $e\n$stack');
    }
  }

  // Load all available presets
  Future<void> loadAvailablePresets() async {
    try {
      // Reset state to prevent stacking of presets on hot reload
      availablePresets = [];
      presetsLoaded = false;

      final presets = await PresetController.getAllPresets();

      // Sort presets by created date (newest first)
      presets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      availablePresets = presets;
      presetsLoaded = true;

      // Find the current preset index if possible
      findCurrentPresetIndex();
    } catch (e) {
      debugPrint('Error loading available presets: $e');
    }
  }

  // Find current preset in available presets list
  void findCurrentPresetIndex() {
    for (int i = 0; i < availablePresets.length; i++) {
      final preset = availablePresets[i];
      if (preset.imagePath == selectedImage) {
        currentPresetIndex = i;
        break;
      }
    }
  }

  // Apply a preset to the current state
  void applyPreset(ShaderPreset preset, {bool showControlsAfter = true}) {
    EffectLogger.log(
      "Applying preset '${preset.name}' with text enabled: ${preset.settings.textLayoutSettings.textEnabled}",
    );

    // Apply all settings from the preset
    shaderSettings = preset.settings;

    // Apply margin from specificSettings if available
    if (preset.specificSettings != null) {
      // Apply margin setting if available
      if (preset.specificSettings!.containsKey('fitScreenMargin')) {
        shaderSettings.textLayoutSettings.fitScreenMargin =
            (preset.specificSettings!['fitScreenMargin'] as num).toDouble();
      }

      // Apply fillScreen setting if available
      if (preset.specificSettings!.containsKey('fillScreen')) {
        shaderSettings.fillScreen =
            preset.specificSettings!['fillScreen'] as bool;
      }
    }

    selectedImage = preset.imagePath;

    // Update image category based on the loaded image
    if (selectedImage.contains('/covers/')) {
      imageCategory = ImageCategory.covers;
    } else if (selectedImage.contains('/artists/')) {
      imageCategory = ImageCategory.artists;
    }

    // Only show controls if explicitly requested
    showControls = showControlsAfter;

    // If aspect sliders are open, maintain current aspect but refresh its state
    if (showAspectSliders) {
      // No change to selectedAspect here, just keep what the user was looking at
    } else {
      // If no sliders were open, default to color aspect as that's most visually obvious
      selectedAspect = ShaderAspect.color;
    }

    // Clear unsaved settings when applying a preset
    unsavedSettings = null;
    unsavedImage = null;
    unsavedCategory = null;
  }

  // Check if current settings have been modified from the current preset
  bool hasUnsavedChanges() {
    // If we're not on a preset, always consider as having changes
    if (currentPresetIndex < 0 ||
        currentPresetIndex >= availablePresets.length) {
      return true;
    }

    final currentPreset = availablePresets[currentPresetIndex];

    // Compare image path - most basic check
    if (selectedImage != currentPreset.imagePath) {
      return true;
    }

    // Compare important settings that would be visually noticeable
    if (shaderSettings.colorEnabled != currentPreset.settings.colorEnabled) {
      return true;
    }

    if (shaderSettings.blurEnabled != currentPreset.settings.blurEnabled) {
      return true;
    }

    if (shaderSettings.noiseEnabled != currentPreset.settings.noiseEnabled) {
      return true;
    }

    if (shaderSettings.chromaticEnabled !=
        currentPreset.settings.chromaticEnabled) {
      return true;
    }

    if (shaderSettings.rippleEnabled != currentPreset.settings.rippleEnabled) {
      return true;
    }

    if (shaderSettings.textEnabled != currentPreset.settings.textEnabled) {
      return true;
    }

    if (shaderSettings.textEnabled) {
      // Compare text content if text is enabled
      if (shaderSettings.textLayoutSettings.textTitle !=
          currentPreset.settings.textLayoutSettings.textTitle) {
        return true;
      }

      if (shaderSettings.textLayoutSettings.textSubtitle !=
          currentPreset.settings.textLayoutSettings.textSubtitle) {
        return true;
      }

      if (shaderSettings.textLayoutSettings.textArtist !=
          currentPreset.settings.textLayoutSettings.textArtist) {
        return true;
      }
    }

    return false;
  }

  // Get current images based on selected category
  List<String> getCurrentImages() {
    return imageCategory == ImageCategory.covers ? coverImages : artistImages;
  }
}
