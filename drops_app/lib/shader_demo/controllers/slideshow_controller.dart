import 'dart:math';
import 'package:flutter/material.dart';
import '../models/shader_preset.dart';
import '../utils/logging_utils.dart';

/// Controls the slideshow/preset navigation functionality
class SlideshowController {
  // PageController for smooth preset transitions
  late PageController pageController;
  bool isScrolling = false;

  // Constructor
  SlideshowController({int initialPage = 0}) {
    pageController = PageController(initialPage: initialPage);
  }

  // Clean up resources
  void dispose() {
    pageController.dispose();
  }

  // Navigate to previous preset in slideshow
  void navigateToPrevious(List<ShaderPreset> visiblePresets) {
    if (visiblePresets.isEmpty) return;

    // Get the current page from controller
    final int currentPage = pageController.page?.round() ?? 0;

    // Calculate the target page with proper wraparound
    int targetPage = (currentPage - 1) % visiblePresets.length;

    // Handle negative modulo properly
    if (targetPage < 0) targetPage += visiblePresets.length;

    // Use the PageController to animate to the previous page
    isScrolling = true;
    pageController
        .animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          isScrolling = false;
        });
  }

  // Navigate to next preset in slideshow
  void navigateToNext(List<ShaderPreset> visiblePresets) {
    if (visiblePresets.isEmpty) return;

    // Get the current page from controller
    final int currentPage = pageController.page?.round() ?? 0;

    // Calculate target page with proper wraparound
    int targetPage = (currentPage + 1) % visiblePresets.length;

    // Use the PageController to animate to the next page
    isScrolling = true;
    pageController
        .animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          isScrolling = false;
        });
  }

  // Reset controller to a specific page
  void resetToPage(int page) {
    if (pageController.hasClients) {
      pageController.jumpToPage(page);
    }
  }

  // Sort presets according to a given sort method
  List<ShaderPreset> sortPresets(
    List<ShaderPreset> presets,
    PresetSortMethod? sortMethod, {
    ShaderPreset? currentPreset,
  }) {
    if (sortMethod == null) return presets;

    // Create a copy of the list to avoid modifying the original
    final sortedPresets = List<ShaderPreset>.from(presets);

    switch (sortMethod) {
      case PresetSortMethod.dateNewest:
        sortedPresets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case PresetSortMethod.alphabetical:
        sortedPresets.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case PresetSortMethod.reverseAlphabetical:
        sortedPresets.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case PresetSortMethod.random:
        // For random, use a fixed seed for consistent order during swiping
        // Use the current preset's creation timestamp as the seed if available
        final int seed = currentPreset != null
            ? currentPreset.createdAt.millisecondsSinceEpoch
            : DateTime.now().millisecondsSinceEpoch;

        final random = Random(seed);

        // Fisher-Yates shuffle
        for (var i = sortedPresets.length - 1; i > 0; i--) {
          var j = random.nextInt(i + 1);
          var temp = sortedPresets[i];
          sortedPresets[i] = sortedPresets[j];
          sortedPresets[j] = temp;
        }
        break;
    }

    return sortedPresets;
  }

  // Get visible presets (those not hidden from slideshow and not duplicates)
  List<ShaderPreset> getVisiblePresets(List<ShaderPreset> allPresets) {
    // First filter out manually hidden presets
    final visiblePresets = allPresets
        .where((preset) => !preset.isHiddenFromSlideshow)
        .toList();

    // Then filter out content duplicates - only show untitled if it's unique
    return _filterContentDuplicates(visiblePresets);
  }

  // Filter out duplicate content - hide untitled if identical to any saved preset
  List<ShaderPreset> _filterContentDuplicates(List<ShaderPreset> presets) {
    if (presets.length <= 1) return presets;

    // Find untitled and saved presets
    final untitledPresets = presets.where((p) => p.name == "Untitled").toList();
    final savedPresets = presets.where((p) => p.name != "Untitled").toList();

    EffectLogger.log(
      'Slideshow filtering: ${presets.length} total, ${untitledPresets.length} untitled, ${savedPresets.length} saved',
    );

    // If no untitled presets, return all
    if (untitledPresets.isEmpty) return presets;

    // If no saved presets, return all (untitled is unique)
    if (savedPresets.isEmpty) {
      EffectLogger.log('No saved presets - showing untitled as unique');
      return presets;
    }

    // Check if any untitled preset is identical to any saved preset
    final uniqueUntitled = <ShaderPreset>[];
    for (final untitled in untitledPresets) {
      bool isDuplicate = false;
      for (final saved in savedPresets) {
        if (_arePresetsContentIdentical(untitled, saved)) {
          EffectLogger.log(
            'Found duplicate: Untitled matches "${saved.name}" - hiding untitled from slideshow',
          );
          isDuplicate = true;
          break;
        }
      }
      // Only keep untitled if it's unique
      if (!isDuplicate) {
        EffectLogger.log('Untitled is unique - including in slideshow');
        uniqueUntitled.add(untitled);
      }
    }

    final result = [...savedPresets, ...uniqueUntitled];
    EffectLogger.log(
      'Slideshow will show ${result.length} presets (${savedPresets.length} saved + ${uniqueUntitled.length} unique untitled)',
    );

    // Return saved presets + unique untitled presets
    return result;
  }

  // Compare two presets to see if their visual content is identical
  bool _arePresetsContentIdentical(ShaderPreset preset1, ShaderPreset preset2) {
    // Compare image path
    if (preset1.imagePath != preset2.imagePath) return false;

    // Compare key visual settings that affect the final appearance
    final settings1 = preset1.settings;
    final settings2 = preset2.settings;

    // Background settings
    if (settings1.backgroundEnabled != settings2.backgroundEnabled)
      return false;
    if (settings1.backgroundEnabled &&
        settings1.backgroundSettings.backgroundColor.value !=
            settings2.backgroundSettings.backgroundColor.value)
      return false;

    // Image settings
    if (settings1.imageEnabled != settings2.imageEnabled) return false;
    if (settings1.fillScreen != settings2.fillScreen) return false;

    // Effect enables (what effects are active)
    if (settings1.colorEnabled != settings2.colorEnabled) return false;
    if (settings1.blurEnabled != settings2.blurEnabled) return false;
    if (settings1.noiseEnabled != settings2.noiseEnabled) return false;
    if (settings1.chromaticEnabled != settings2.chromaticEnabled) return false;
    if (settings1.rippleEnabled != settings2.rippleEnabled) return false;
    if (settings1.rainEnabled != settings2.rainEnabled) return false;
    if (settings1.textEnabled != settings2.textEnabled) return false;
    if (settings1.textfxEnabled != settings2.textfxEnabled) return false;
    if (settings1.musicEnabled != settings2.musicEnabled) return false;
    if (settings1.cymaticsEnabled != settings2.cymaticsEnabled) return false;

    // For enabled effects, compare key visual parameters
    if (settings1.colorEnabled) {
      if (!_areColorSettingsIdentical(
        settings1.colorSettings,
        settings2.colorSettings,
      ))
        return false;
    }

    if (settings1.blurEnabled) {
      if (!_areBlurSettingsIdentical(
        settings1.blurSettings,
        settings2.blurSettings,
      ))
        return false;
    }

    if (settings1.textEnabled) {
      if (!_areTextSettingsIdentical(
        settings1.textLayoutSettings,
        settings2.textLayoutSettings,
      ))
        return false;
    }

    // Add more effect comparisons as needed for visual accuracy

    return true;
  }

  // Compare color settings for visual identity
  bool _areColorSettingsIdentical(dynamic color1, dynamic color2) {
    // Compare main color properties that affect visual appearance
    try {
      return color1.hue == color2.hue &&
          color1.saturation == color2.saturation &&
          color1.lightness == color2.lightness &&
          color1.overlayIntensity == color2.overlayIntensity;
    } catch (e) {
      return false;
    }
  }

  // Compare blur settings for visual identity
  bool _areBlurSettingsIdentical(dynamic blur1, dynamic blur2) {
    try {
      return blur1.blurAmount == blur2.blurAmount &&
          blur1.blurRadius == blur2.blurRadius;
    } catch (e) {
      return false;
    }
  }

  // Compare text settings for visual identity
  bool _areTextSettingsIdentical(dynamic text1, dynamic text2) {
    try {
      return text1.textTitle == text2.textTitle &&
          text1.textSubtitle == text2.textSubtitle &&
          text1.textArtist == text2.textArtist &&
          text1.textFont == text2.textFont &&
          text1.textSize == text2.textSize;
    } catch (e) {
      return false;
    }
  }

  // Find the index of a preset in the list by ID
  int findPresetIndex(List<ShaderPreset> presets, String presetId) {
    return presets.indexWhere((p) => p.id == presetId);
  }
}
