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

  // Get visible presets (those not hidden from slideshow)
  List<ShaderPreset> getVisiblePresets(List<ShaderPreset> allPresets) {
    return allPresets.where((preset) => !preset.isHiddenFromSlideshow).toList();
  }

  // Find the index of a preset in the list by ID
  int findPresetIndex(List<ShaderPreset> presets, String presetId) {
    return presets.indexWhere((p) => p.id == presetId);
  }
}
