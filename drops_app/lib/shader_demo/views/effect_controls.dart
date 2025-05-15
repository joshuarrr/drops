import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import '../../common/font_selector.dart';
import '../widgets/aspect_toggle.dart';
import '../widgets/value_slider.dart';
import '../widgets/aspect_panel_header.dart';
import '../widgets/alignment_selector.dart';
import '../widgets/animation_controls.dart';
import '../widgets/presets_bar.dart';
import '../widgets/text_input_field.dart';
import '../widgets/color_panel.dart';
import '../widgets/blur_panel.dart';
import '../widgets/image_panel.dart';
import '../widgets/text_panel.dart';

// Enum for identifying each text line (outside class for reuse)
enum TextLine { title, subtitle, artist }

extension TextLineExt on TextLine {
  String get label {
    switch (this) {
      case TextLine.title:
        return 'Title';
      case TextLine.subtitle:
        return 'Subtitle';
      case TextLine.artist:
        return 'Artist';
    }
  }
}

class EffectControls {
  // Control logging verbosity
  static bool enableLogging = false;

  // Selected text line for editing (shared across rebuilds)
  static TextLine selectedTextLine = TextLine.title;

  // Whether the font selector overlay is visible.
  static bool fontSelectorOpen = false;

  // New variable to track presets
  static Map<ShaderAspect, Map<String, dynamic>> cachedPresets = {};

  // Add a counter to force refresh of preset bar
  static int presetsRefreshCounter = 0;

  // Add a method to load presets for a specific aspect
  static Future<Map<String, dynamic>> loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    if (!cachedPresets.containsKey(aspect)) {
      cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return cachedPresets[aspect] ?? {};
  }

  // Force a refresh of preset bars
  static void refreshPresets() {
    presetsRefreshCounter++;
  }

  // Delete a preset from storage, update the in-memory cache, and report success
  static Future<bool> deletePresetAndUpdate(
    ShaderAspect aspect,
    String name,
  ) async {
    final success = await PresetsManager.deletePreset(aspect, name);
    if (success) {
      cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return success;
  }

  // Load font choices via the shared FontUtils helper so the logic is
  // centralized and can be reused by other widgets as well.
  static Future<List<String>> getFontChoices() {
    return FontUtils.loadFontFamilies();
  }

  // Build controls for toggling and configuring shader aspects
  static Widget buildAspectToggleBar({
    required ShaderSettings settings,
    required Function(ShaderAspect, bool) onAspectToggled,
    required Function(ShaderAspect) onAspectSelected,
    required bool isCurrentImageDark,
    required bool hidden,
  }) {
    return AnimatedSlide(
      offset: hidden ? const Offset(0, -1.2) : Offset.zero,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: hidden ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Image toggle first for quick access
            AspectToggle(
              aspect: ShaderAspect.image,
              isEnabled: true,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: onAspectToggled,
              onTap: onAspectSelected,
            ),
            AspectToggle(
              aspect: ShaderAspect.color,
              isEnabled: settings.colorEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: onAspectToggled,
              onTap: onAspectSelected,
            ),
            AspectToggle(
              aspect: ShaderAspect.blur,
              isEnabled: settings.blurEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: onAspectToggled,
              onTap: onAspectSelected,
            ),
            AspectToggle(
              aspect: ShaderAspect.text,
              isEnabled: settings.textEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: onAspectToggled,
              onTap: onAspectSelected,
            ),
          ],
        ),
      ),
    );
  }

  // Build sliders for a specific aspect with proper grouping
  static List<Widget> buildSlidersForAspect({
    required ShaderAspect aspect,
    required ShaderSettings settings,
    required Function(ShaderSettings) onSettingsChanged,
    required Color sliderColor,
    required BuildContext context,
  }) {
    switch (aspect) {
      case ShaderAspect.color:
        return [
          ColorPanel(
            settings: settings,
            onSettingsChanged: onSettingsChanged,
            sliderColor: sliderColor,
            context: context,
          ),
        ];

      case ShaderAspect.blur:
        return [
          BlurPanel(
            settings: settings,
            onSettingsChanged: onSettingsChanged,
            sliderColor: sliderColor,
            context: context,
          ),
        ];

      case ShaderAspect.image:
        return [
          ImagePanel(
            settings: settings,
            onSettingsChanged: onSettingsChanged,
            sliderColor: sliderColor,
            context: context,
          ),
        ];

      case ShaderAspect.text:
        return [
          TextPanel(
            settings: settings,
            onSettingsChanged: onSettingsChanged,
            sliderColor: sliderColor,
            context: context,
          ),
        ];
    }
  }

  // Utility method to build image selector dropdown
  static Widget buildImageSelector({
    required String selectedImage,
    required List<String> availableImages,
    required bool isCurrentImageDark,
    required Function(String?) onImageSelected,
  }) {
    final Color textColor = isCurrentImageDark ? Colors.white : Colors.black;

    return DropdownButton<String>(
      dropdownColor: isCurrentImageDark
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      value: selectedImage,
      icon: Icon(Icons.arrow_downward, color: textColor),
      elevation: 16,
      style: TextStyle(color: textColor),
      underline: Container(height: 2, color: textColor),
      onChanged: onImageSelected,
      items: availableImages.map<DropdownMenuItem<String>>((String value) {
        final filename = value.split('/').last.split('.').first;
        return DropdownMenuItem<String>(value: value, child: Text(filename));
      }).toList(),
    );
  }

  // Build a widget to display saved presets
  static Widget buildPresetsBar({
    required ShaderAspect aspect,
    required Function(Map<String, dynamic>) onPresetSelected,
    required Color sliderColor,
    required BuildContext context,
  }) {
    return PresetsBar(
      aspect: aspect,
      onPresetSelected: onPresetSelected,
      sliderColor: sliderColor,
      loadPresets: loadPresetsForAspect,
      deletePreset: deletePresetAndUpdate,
      refreshPresets: refreshPresets,
      refreshCounter: presetsRefreshCounter,
    );
  }
}
