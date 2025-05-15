import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../../common/font_selector.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/aspect_toggle.dart';
import '../widgets/value_slider.dart';
import '../widgets/aspect_panel_header.dart';
import '../widgets/alignment_selector.dart';
import '../widgets/animation_controls.dart';

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

// Presets management helper class
class PresetsManager {
  static const String _presetsKey = 'shader_presets';

  // Save a preset
  static Future<bool> savePreset(
    ShaderAspect aspect,
    String name,
    Map<String, dynamic> settings,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing presets
      final String? existingPresetsJson = prefs.getString(_presetsKey);
      Map<String, dynamic> presets = {};

      if (existingPresetsJson != null) {
        // Cast the decoded JSON to the correct type using Map.from
        final dynamic decodedJson = jsonDecode(existingPresetsJson);
        presets = _convertToStringDynamicMap(decodedJson);
      }

      // Create aspect key
      final String aspectKey = aspect.toString();
      if (!presets.containsKey(aspectKey)) {
        presets[aspectKey] = <String, dynamic>{};
      } else if (presets[aspectKey] is Map &&
          !(presets[aspectKey] is Map<String, dynamic>)) {
        // Ensure we have the right map type
        presets[aspectKey] = _convertToStringDynamicMap(presets[aspectKey]);
      }

      // Add the preset to the aspect map
      final aspectMap = presets[aspectKey] as Map<String, dynamic>;
      aspectMap[name] = settings;

      // Save back to SharedPreferences
      await prefs.setString(_presetsKey, jsonEncode(presets));
      return true;
    } catch (e) {
      print('Error saving preset: $e');
      return false;
    }
  }

  // Load presets for a specific aspect
  static Future<Map<String, dynamic>> getPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? presetsJson = prefs.getString(_presetsKey);

      if (presetsJson != null) {
        final dynamic allPresets = jsonDecode(presetsJson);
        final Map<String, dynamic> typedPresets = _convertToStringDynamicMap(
          allPresets,
        );
        final String aspectKey = aspect.toString();

        if (typedPresets.containsKey(aspectKey)) {
          return _convertToStringDynamicMap(typedPresets[aspectKey]);
        }
      }
      return {};
    } catch (e) {
      print('Error loading presets: $e');
      return {};
    }
  }

  // Delete a preset
  static Future<bool> deletePreset(ShaderAspect aspect, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? presetsJson = prefs.getString(_presetsKey);

      if (presetsJson != null) {
        final dynamic decodedJson = jsonDecode(presetsJson);
        final Map<String, dynamic> allPresets = _convertToStringDynamicMap(
          decodedJson,
        );
        final String aspectKey = aspect.toString();

        if (allPresets.containsKey(aspectKey)) {
          final Map<String, dynamic> aspectPresets = _convertToStringDynamicMap(
            allPresets[aspectKey],
          );

          if (aspectPresets.containsKey(name)) {
            aspectPresets.remove(name);
            allPresets[aspectKey] = aspectPresets;
            await prefs.setString(_presetsKey, jsonEncode(allPresets));
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('Error deleting preset: $e');
      return false;
    }
  }

  // Helper method to safely convert dynamic maps to Map<String, dynamic>
  static Map<String, dynamic> _convertToStringDynamicMap(dynamic input) {
    if (input is! Map) {
      return <String, dynamic>{};
    }

    final result = <String, dynamic>{};
    for (final entry in (input as Map).entries) {
      final key = entry.key.toString();
      final value = entry.value;

      // Recursively convert nested maps
      if (value is Map) {
        result[key] = _convertToStringDynamicMap(value);
      } else if (value is List) {
        // Convert lists that might contain maps
        result[key] = _convertListElements(value);
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  // Helper method to handle lists that might contain maps
  static List<dynamic> _convertListElements(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return _convertToStringDynamicMap(item);
      } else if (item is List) {
        return _convertListElements(item);
      } else {
        return item;
      }
    }).toList();
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
    // ---------------------------------------------------------------
    // Local helpers -------------------------------------------------
    // ---------------------------------------------------------------

    // Generic reset header widget reused across aspects
    Widget buildResetRow(
      VoidCallback onReset, {
      required ShaderAspect aspect,
      required Function(ShaderAspect, String) onSavePreset,
      required BuildContext context,
    }) {
      return Align(
        alignment: Alignment.centerRight,
        child: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: sliderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'save_preset',
              child: Row(
                children: [
                  Icon(Icons.save, color: sliderColor, size: 18),
                  const SizedBox(width: 8),
                  Text('Save preset', style: TextStyle(color: sliderColor)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.restore, color: sliderColor, size: 18),
                  const SizedBox(width: 8),
                  Text('Reset', style: TextStyle(color: sliderColor)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'reset') {
              onReset();
            } else if (value == 'save_preset') {
              // Show a dialog to name the preset
              final TextEditingController nameController =
                  TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Save Preset',
                    style: TextStyle(color: sliderColor),
                  ),
                  content: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter preset name',
                      hintStyle: TextStyle(color: sliderColor.withOpacity(0.6)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: sliderColor.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: sliderColor),
                      ),
                    ),
                    style: TextStyle(color: sliderColor),
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: sliderColor),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Save', style: TextStyle(color: sliderColor)),
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          onSavePreset(aspect, nameController.text);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                  backgroundColor: sliderColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
        ),
      );
    }

    // Reset helpers for each aspect – mutate the provided settings object
    void resetColor() {
      final defaults = ShaderSettings();
      settings
        ..colorEnabled = false
        ..hue = defaults.hue
        ..saturation = defaults.saturation
        ..lightness = defaults.lightness
        ..overlayHue = defaults.overlayHue
        ..overlayIntensity = defaults.overlayIntensity
        ..overlayOpacity = defaults.overlayOpacity
        ..colorAnimated = false
        ..overlayAnimated = false
        ..colorAnimOptions = AnimationOptions()
        ..overlayAnimOptions = AnimationOptions();
    }

    void resetBlur() {
      final defaults = ShaderSettings();
      settings
        ..blurEnabled = false
        ..blurAmount = defaults.blurAmount
        ..blurRadius = defaults.blurRadius
        ..blurOpacity = defaults.blurOpacity
        ..blurFacets = defaults.blurFacets
        ..blurBlendMode = defaults.blurBlendMode
        ..blurAnimated = false
        ..blurAnimOptions = AnimationOptions();
    }

    void resetImage() {
      settings.fillScreen = false;
    }

    void resetText() {
      final defaults = ShaderSettings();
      // Create a copy of the current settings and reset only text properties
      final resetSettings = ShaderSettings.fromMap(settings.toMap())
        ..textEnabled = false
        ..textTitle = defaults.textTitle
        ..textSubtitle = defaults.textSubtitle
        ..textArtist = defaults.textArtist
        ..textFont = defaults.textFont
        ..textSize = defaults.textSize
        ..textPosX = defaults.textPosX
        ..textPosY = defaults.textPosY
        ..textWeight = defaults.textWeight
        ..titleFont = defaults.titleFont
        ..titleSize = defaults.titleSize
        ..titlePosX = defaults.titlePosX
        ..titlePosY = defaults.titlePosY
        ..titleWeight = defaults.titleWeight
        ..subtitleFont = defaults.subtitleFont
        ..subtitleSize = defaults.subtitleSize
        ..subtitlePosX = defaults.subtitlePosX
        ..subtitlePosY = defaults.subtitlePosY
        ..subtitleWeight = defaults.subtitleWeight
        ..artistFont = defaults.artistFont
        ..artistSize = defaults.artistSize
        ..artistPosX = defaults.artistPosX
        ..artistPosY = defaults.artistPosY
        ..artistWeight = defaults.artistWeight
        ..textFitToWidth = defaults.textFitToWidth
        ..textHAlign = defaults.textHAlign
        ..textVAlign = defaults.textVAlign
        ..textLineHeight = defaults.textLineHeight
        ..titleFitToWidth = defaults.titleFitToWidth
        ..titleHAlign = defaults.titleHAlign
        ..titleVAlign = defaults.titleVAlign
        ..titleLineHeight = defaults.titleLineHeight
        ..subtitleFitToWidth = defaults.subtitleFitToWidth
        ..subtitleHAlign = defaults.subtitleHAlign
        ..subtitleVAlign = defaults.subtitleVAlign
        ..subtitleLineHeight = defaults.subtitleLineHeight
        ..artistFitToWidth = defaults.artistFitToWidth
        ..artistHAlign = defaults.artistHAlign
        ..artistVAlign = defaults.artistVAlign
        ..artistLineHeight = defaults.artistLineHeight;

      // Update the original settings object with the reset values
      settings.textEnabled = resetSettings.textEnabled;
      settings.textTitle = resetSettings.textTitle;
      settings.textSubtitle = resetSettings.textSubtitle;
      settings.textArtist = resetSettings.textArtist;
      settings.textFont = resetSettings.textFont;
      settings.textSize = resetSettings.textSize;
      settings.textPosX = resetSettings.textPosX;
      settings.textPosY = resetSettings.textPosY;
      settings.textWeight = resetSettings.textWeight;
      settings.titleFont = resetSettings.titleFont;
      settings.titleSize = resetSettings.titleSize;
      settings.titlePosX = resetSettings.titlePosX;
      settings.titlePosY = resetSettings.titlePosY;
      settings.titleWeight = resetSettings.titleWeight;
      settings.subtitleFont = resetSettings.subtitleFont;
      settings.subtitleSize = resetSettings.subtitleSize;
      settings.subtitlePosX = resetSettings.subtitlePosX;
      settings.subtitlePosY = resetSettings.subtitlePosY;
      settings.subtitleWeight = resetSettings.subtitleWeight;
      settings.artistFont = resetSettings.artistFont;
      settings.artistSize = resetSettings.artistSize;
      settings.artistPosX = resetSettings.artistPosX;
      settings.artistPosY = resetSettings.artistPosY;
      settings.artistWeight = resetSettings.artistWeight;
      settings.textFitToWidth = resetSettings.textFitToWidth;
      settings.textHAlign = resetSettings.textHAlign;
      settings.textVAlign = resetSettings.textVAlign;
      settings.textLineHeight = resetSettings.textLineHeight;
      settings.titleFitToWidth = resetSettings.titleFitToWidth;
      settings.titleHAlign = resetSettings.titleHAlign;
      settings.titleVAlign = resetSettings.titleVAlign;
      settings.titleLineHeight = resetSettings.titleLineHeight;
      settings.subtitleFitToWidth = resetSettings.subtitleFitToWidth;
      settings.subtitleHAlign = resetSettings.subtitleHAlign;
      settings.subtitleVAlign = resetSettings.subtitleVAlign;
      settings.subtitleLineHeight = resetSettings.subtitleLineHeight;
      settings.artistFitToWidth = resetSettings.artistFitToWidth;
      settings.artistHAlign = resetSettings.artistHAlign;
      settings.artistVAlign = resetSettings.artistVAlign;
      settings.artistLineHeight = resetSettings.artistLineHeight;
    }

    // Helper function to enable the effect if needed when slider changes
    void onSliderChanged(double value, Function(double) setter) {
      if (enableLogging) {
        print(
          "SLIDER: ${aspect.label} slider changing to ${(value * 100).round()}%",
        );
      }

      // Enable the corresponding effect if it's not already enabled
      switch (aspect) {
        case ShaderAspect.color:
          if (!settings.colorEnabled) settings.colorEnabled = true;
          break;
        case ShaderAspect.blur:
          if (!settings.blurEnabled) settings.blurEnabled = true;
          break;
        case ShaderAspect.image:
          // No enabling logic required for image aspect
          break;
        case ShaderAspect.text:
          if (!settings.textEnabled) settings.textEnabled = true;
          break;
      }

      // Update the setting value
      setter(value);
      // Notify the parent widget
      onSettingsChanged(settings);
    }

    // ---------------------------------------------------------------
    // Build UI per aspect ------------------------------------------
    // ---------------------------------------------------------------

    // Save preset implementation function
    Future<void> savePresetForAspect(ShaderAspect aspect, String name) async {
      Map<String, dynamic> presetData = {};

      switch (aspect) {
        case ShaderAspect.color:
          presetData = {
            'colorEnabled': settings.colorEnabled,
            'hue': settings.hue,
            'saturation': settings.saturation,
            'lightness': settings.lightness,
            'overlayHue': settings.overlayHue,
            'overlayIntensity': settings.overlayIntensity,
            'overlayOpacity': settings.overlayOpacity,
            'colorAnimated': settings.colorAnimated,
            'overlayAnimated': settings.overlayAnimated,
            'colorAnimOptions': settings.colorAnimOptions.toMap(),
            'overlayAnimOptions': settings.overlayAnimOptions.toMap(),
          };
          break;
        case ShaderAspect.blur:
          presetData = {
            'blurEnabled': settings.blurEnabled,
            'blurAmount': settings.blurAmount,
            'blurRadius': settings.blurRadius,
            'blurOpacity': settings.blurOpacity,
            'blurFacets': settings.blurFacets,
            'blurBlendMode': settings.blurBlendMode,
            'blurAnimated': settings.blurAnimated,
            'blurAnimOptions': settings.blurAnimOptions.toMap(),
          };
          break;
        case ShaderAspect.image:
          presetData = {'fillScreen': settings.fillScreen};
          break;
        case ShaderAspect.text:
          // Get current text line settings
          String textLine = EffectControls.selectedTextLine.toString();
          presetData = {
            'textEnabled': settings.textEnabled,
            'selectedTextLine': textLine,
            'textTitle': settings.textTitle,
            'textSubtitle': settings.textSubtitle,
            'textArtist': settings.textArtist,
            'textFont': settings.textFont,
            'textSize': settings.textSize,
            'textPosX': settings.textPosX,
            'textPosY': settings.textPosY,
            'textWeight': settings.textWeight,
            'titleFont': settings.titleFont,
            'titleSize': settings.titleSize,
            'titlePosX': settings.titlePosX,
            'titlePosY': settings.titlePosY,
            'titleWeight': settings.titleWeight,
            'subtitleFont': settings.subtitleFont,
            'subtitleSize': settings.subtitleSize,
            'subtitlePosX': settings.subtitlePosX,
            'subtitlePosY': settings.subtitlePosY,
            'subtitleWeight': settings.subtitleWeight,
            'artistFont': settings.artistFont,
            'artistSize': settings.artistSize,
            'artistPosX': settings.artistPosX,
            'artistPosY': settings.artistPosY,
            'artistWeight': settings.artistWeight,
            'textFitToWidth': settings.textFitToWidth,
            'textHAlign': settings.textHAlign,
            'textVAlign': settings.textVAlign,
            'textLineHeight': settings.textLineHeight,
            'titleFitToWidth': settings.titleFitToWidth,
            'titleHAlign': settings.titleHAlign,
            'titleVAlign': settings.titleVAlign,
            'titleLineHeight': settings.titleLineHeight,
            'subtitleFitToWidth': settings.subtitleFitToWidth,
            'subtitleHAlign': settings.subtitleHAlign,
            'subtitleVAlign': settings.subtitleVAlign,
            'subtitleLineHeight': settings.subtitleLineHeight,
            'artistFitToWidth': settings.artistFitToWidth,
            'artistHAlign': settings.artistHAlign,
            'artistVAlign': settings.artistVAlign,
            'artistLineHeight': settings.artistLineHeight,
          };
          break;
      }

      // Save the preset
      bool success = await PresetsManager.savePreset(aspect, name, presetData);

      if (success) {
        // Update cached presets
        cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(
          aspect,
        );
        // Force refresh of the UI to show the new preset immediately
        refreshPresets();
      }
    }

    // Apply preset function
    void applyPreset(Map<String, dynamic> presetData) {
      switch (aspect) {
        case ShaderAspect.color:
          settings.colorEnabled =
              presetData['colorEnabled'] ?? settings.colorEnabled;
          settings.hue = presetData['hue'] ?? settings.hue;
          settings.saturation = presetData['saturation'] ?? settings.saturation;
          settings.lightness = presetData['lightness'] ?? settings.lightness;
          settings.overlayHue = presetData['overlayHue'] ?? settings.overlayHue;
          settings.overlayIntensity =
              presetData['overlayIntensity'] ?? settings.overlayIntensity;
          settings.overlayOpacity =
              presetData['overlayOpacity'] ?? settings.overlayOpacity;
          settings.colorAnimated =
              presetData['colorAnimated'] ?? settings.colorAnimated;
          settings.overlayAnimated =
              presetData['overlayAnimated'] ?? settings.overlayAnimated;

          if (presetData['colorAnimOptions'] != null) {
            settings.colorAnimOptions = AnimationOptions.fromMap(
              Map<String, dynamic>.from(presetData['colorAnimOptions']),
            );
          }

          if (presetData['overlayAnimOptions'] != null) {
            settings.overlayAnimOptions = AnimationOptions.fromMap(
              Map<String, dynamic>.from(presetData['overlayAnimOptions']),
            );
          }
          break;

        case ShaderAspect.blur:
          settings.blurEnabled =
              presetData['blurEnabled'] ?? settings.blurEnabled;
          settings.blurAmount = presetData['blurAmount'] ?? settings.blurAmount;
          settings.blurRadius = presetData['blurRadius'] ?? settings.blurRadius;
          settings.blurOpacity =
              presetData['blurOpacity'] ?? settings.blurOpacity;
          settings.blurFacets = presetData['blurFacets'] ?? settings.blurFacets;
          settings.blurBlendMode =
              presetData['blurBlendMode'] ?? settings.blurBlendMode;
          settings.blurAnimated =
              presetData['blurAnimated'] ?? settings.blurAnimated;

          if (presetData['blurAnimOptions'] != null) {
            settings.blurAnimOptions = AnimationOptions.fromMap(
              Map<String, dynamic>.from(presetData['blurAnimOptions']),
            );
          }
          break;

        case ShaderAspect.image:
          settings.fillScreen = presetData['fillScreen'] ?? settings.fillScreen;
          break;

        case ShaderAspect.text:
          settings.textEnabled =
              presetData['textEnabled'] ?? settings.textEnabled;
          settings.textTitle = presetData['textTitle'] ?? settings.textTitle;
          settings.textSubtitle =
              presetData['textSubtitle'] ?? settings.textSubtitle;
          settings.textArtist = presetData['textArtist'] ?? settings.textArtist;
          settings.textFont = presetData['textFont'] ?? settings.textFont;
          settings.textSize = presetData['textSize'] ?? settings.textSize;
          settings.textPosX = presetData['textPosX'] ?? settings.textPosX;
          settings.textPosY = presetData['textPosY'] ?? settings.textPosY;
          settings.textWeight = presetData['textWeight'] ?? settings.textWeight;
          settings.titleFont = presetData['titleFont'] ?? settings.titleFont;
          settings.titleSize = presetData['titleSize'] ?? settings.titleSize;
          settings.titlePosX = presetData['titlePosX'] ?? settings.titlePosX;
          settings.titlePosY = presetData['titlePosY'] ?? settings.titlePosY;
          settings.titleWeight =
              presetData['titleWeight'] ?? settings.titleWeight;
          settings.subtitleFont =
              presetData['subtitleFont'] ?? settings.subtitleFont;
          settings.subtitleSize =
              presetData['subtitleSize'] ?? settings.subtitleSize;
          settings.subtitlePosX =
              presetData['subtitlePosX'] ?? settings.subtitlePosX;
          settings.subtitlePosY =
              presetData['subtitlePosY'] ?? settings.subtitlePosY;
          settings.subtitleWeight =
              presetData['subtitleWeight'] ?? settings.subtitleWeight;
          settings.artistFont = presetData['artistFont'] ?? settings.artistFont;
          settings.artistSize = presetData['artistSize'] ?? settings.artistSize;
          settings.artistPosX = presetData['artistPosX'] ?? settings.artistPosX;
          settings.artistPosY = presetData['artistPosY'] ?? settings.artistPosY;
          settings.artistWeight =
              presetData['artistWeight'] ?? settings.artistWeight;
          settings.textFitToWidth =
              presetData['textFitToWidth'] ?? settings.textFitToWidth;
          settings.textHAlign = presetData['textHAlign'] ?? settings.textHAlign;
          settings.textVAlign = presetData['textVAlign'] ?? settings.textVAlign;
          settings.textLineHeight =
              presetData['textLineHeight'] ?? settings.textLineHeight;
          settings.titleFitToWidth =
              presetData['titleFitToWidth'] ?? settings.titleFitToWidth;
          settings.titleHAlign =
              presetData['titleHAlign'] ?? settings.titleHAlign;
          settings.titleVAlign =
              presetData['titleVAlign'] ?? settings.titleVAlign;
          settings.titleLineHeight =
              presetData['titleLineHeight'] ?? settings.titleLineHeight;
          settings.subtitleFitToWidth =
              presetData['subtitleFitToWidth'] ?? settings.subtitleFitToWidth;
          settings.subtitleHAlign =
              presetData['subtitleHAlign'] ?? settings.subtitleHAlign;
          settings.subtitleVAlign =
              presetData['subtitleVAlign'] ?? settings.subtitleVAlign;
          settings.subtitleLineHeight =
              presetData['subtitleLineHeight'] ?? settings.subtitleLineHeight;
          settings.artistFitToWidth =
              presetData['artistFitToWidth'] ?? settings.artistFitToWidth;
          settings.artistHAlign =
              presetData['artistHAlign'] ?? settings.artistHAlign;
          settings.artistVAlign =
              presetData['artistVAlign'] ?? settings.artistVAlign;
          settings.artistLineHeight =
              presetData['artistLineHeight'] ?? settings.artistLineHeight;

          // If preset has a selected text line, switch to it
          if (presetData['selectedTextLine'] != null) {
            final String textLineName = presetData['selectedTextLine'];
            for (TextLine line in TextLine.values) {
              if (line.toString() == textLineName) {
                EffectControls.selectedTextLine = line;
                break;
              }
            }
          }
          break;
      }

      onSettingsChanged(settings);
    }

    switch (aspect) {
      case ShaderAspect.color:
        return [
          AspectPanelHeader(
            aspect: aspect,
            onPresetSelected: applyPreset,
            onReset: () {
              resetColor();
              onSettingsChanged(settings);
            },
            onSavePreset: savePresetForAspect,
            sliderColor: sliderColor,
            loadPresets: EffectControls.loadPresetsForAspect,
            deletePreset: deletePresetAndUpdate,
            refreshPresets: EffectControls.refreshPresets,
            refreshCounter: EffectControls.presetsRefreshCounter,
          ),
          ValueSlider(
            label: 'Hue',
            value: settings.hue,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.hue = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Saturation',
            value: settings.saturation,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.saturation = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Lightness',
            value: settings.lightness,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.lightness = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          const SizedBox(height: 16),
          // ----- Overlay group header -----
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Overlay',
              style: TextStyle(
                color: sliderColor.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ValueSlider(
            label: 'Overlay Hue',
            value: settings.overlayHue,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.overlayHue = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Overlay Intensity',
            value: settings.overlayIntensity,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.overlayIntensity = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Overlay Opacity',
            value: settings.overlayOpacity,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.overlayOpacity = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          // Toggle animation for HSL adjustments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Animate HSL',
                style: TextStyle(color: sliderColor, fontSize: 14),
              ),
              Switch(
                value: settings.colorAnimated,
                activeThumbColor: sliderColor,
                onChanged: (value) {
                  settings.colorAnimated = value;
                  if (!settings.colorEnabled) settings.colorEnabled = true;
                  onSettingsChanged(settings);
                },
              ),
            ],
          ),
          if (settings.colorAnimated)
            AnimationControls(
              animationSpeed: settings.colorAnimOptions.speed,
              onSpeedChanged: (v) {
                settings.colorAnimOptions = settings.colorAnimOptions.copyWith(
                  speed: v,
                );
                onSettingsChanged(settings);
              },
              animationMode: settings.colorAnimOptions.mode,
              onModeChanged: (m) {
                settings.colorAnimOptions = settings.colorAnimOptions.copyWith(
                  mode: m,
                );
                onSettingsChanged(settings);
              },
              animationEasing: settings.colorAnimOptions.easing,
              onEasingChanged: (e) {
                settings.colorAnimOptions = settings.colorAnimOptions.copyWith(
                  easing: e,
                );
                onSettingsChanged(settings);
              },
              sliderColor: sliderColor,
            ),

          // Toggle animation for overlay
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Animate Overlay',
                style: TextStyle(color: sliderColor, fontSize: 14),
              ),
              Switch(
                value: settings.overlayAnimated,
                activeThumbColor: sliderColor,
                onChanged: (value) {
                  settings.overlayAnimated = value;
                  if (!settings.colorEnabled) settings.colorEnabled = true;
                  onSettingsChanged(settings);
                },
              ),
            ],
          ),
          if (settings.overlayAnimated)
            AnimationControls(
              animationSpeed: settings.overlayAnimOptions.speed,
              onSpeedChanged: (v) {
                settings.overlayAnimOptions = settings.overlayAnimOptions
                    .copyWith(speed: v);
                onSettingsChanged(settings);
              },
              animationMode: settings.overlayAnimOptions.mode,
              onModeChanged: (m) {
                settings.overlayAnimOptions = settings.overlayAnimOptions
                    .copyWith(mode: m);
                onSettingsChanged(settings);
              },
              animationEasing: settings.overlayAnimOptions.easing,
              onEasingChanged: (e) {
                settings.overlayAnimOptions = settings.overlayAnimOptions
                    .copyWith(easing: e);
                onSettingsChanged(settings);
              },
              sliderColor: sliderColor,
            ),
        ];

      case ShaderAspect.blur:
        return [
          AspectPanelHeader(
            aspect: aspect,
            onPresetSelected: applyPreset,
            onReset: () {
              resetBlur();
              onSettingsChanged(settings);
            },
            onSavePreset: savePresetForAspect,
            sliderColor: sliderColor,
            loadPresets: EffectControls.loadPresetsForAspect,
            deletePreset: deletePresetAndUpdate,
            refreshPresets: EffectControls.refreshPresets,
            refreshCounter: EffectControls.presetsRefreshCounter,
          ),
          ValueSlider(
            label: 'Shatter Amount',
            value: settings.blurAmount,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.blurAmount = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Shatter Radius',
            value:
                settings.blurRadius /
                120.0, // Scale down from max 120 to 0-1 range
            onChanged: (value) => onSliderChanged(
              value,
              (v) => settings.blurRadius = v * 120.0,
            ), // Scale up to 0-120 range
            sliderColor: sliderColor,
            defaultValue: 15.0 / 120.0, // Default scaled value
          ),
          // Opacity slider
          ValueSlider(
            label: 'Shatter Opacity',
            value: settings.blurOpacity,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.blurOpacity = v),
            sliderColor: sliderColor,
            defaultValue: 1.0,
          ),
          // Facets slider (0-1 mapped to 1-150 facets)
          ValueSlider(
            label: 'Facets',
            value: settings.blurFacets / 150.0,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.blurFacets = v * 150.0),
            sliderColor: sliderColor,
            defaultValue: 1.0 / 150.0,
          ),
          // For ShaderAspect.blur case, replace the Wrap widget for blend modes with a segmented button
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Blend Mode',
                  style: TextStyle(color: sliderColor, fontSize: 14),
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 0,
                      label: Text('Normal', style: TextStyle(fontSize: 13)),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      label: Text('Multiply', style: TextStyle(fontSize: 13)),
                    ),
                    ButtonSegment<int>(
                      value: 2,
                      label: Text('Screen', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                  selected: {settings.blurBlendMode},
                  onSelectionChanged: (Set<int> selection) {
                    if (selection.isNotEmpty) {
                      settings.blurBlendMode = selection.first;
                      if (!settings.blurEnabled) settings.blurEnabled = true;
                      onSettingsChanged(settings);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.selected)) {
                        return sliderColor.withOpacity(0.3);
                      }
                      return sliderColor.withOpacity(0.1);
                    }),
                    foregroundColor: MaterialStateProperty.all(sliderColor),
                    side: MaterialStateProperty.all(
                      BorderSide(color: Colors.transparent),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Toggle animation switch moved to bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Animate',
                style: TextStyle(color: sliderColor, fontSize: 14),
              ),
              Switch(
                value: settings.blurAnimated,
                activeThumbColor: sliderColor,
                onChanged: (value) {
                  settings.blurAnimated = value;
                  if (enableLogging) {
                    print('SLIDER: Shatter animate set to \\$value');
                  }
                  // Ensure effect is enabled when animation toggled on
                  if (!settings.blurEnabled) settings.blurEnabled = true;
                  onSettingsChanged(settings);
                },
              ),
            ],
          ),
          if (settings.blurAnimated)
            AnimationControls(
              animationSpeed: settings.blurAnimOptions.speed,
              onSpeedChanged: (v) {
                settings.blurAnimOptions = settings.blurAnimOptions.copyWith(
                  speed: v,
                );
                onSettingsChanged(settings);
              },
              animationMode: settings.blurAnimOptions.mode,
              onModeChanged: (m) {
                settings.blurAnimOptions = settings.blurAnimOptions.copyWith(
                  mode: m,
                );
                onSettingsChanged(settings);
              },
              animationEasing: settings.blurAnimOptions.easing,
              onEasingChanged: (e) {
                settings.blurAnimOptions = settings.blurAnimOptions.copyWith(
                  easing: e,
                );
                onSettingsChanged(settings);
              },
              sliderColor: sliderColor,
            ),
        ];

      case ShaderAspect.image:
        return [
          AspectPanelHeader(
            aspect: aspect,
            onPresetSelected: applyPreset,
            onReset: () {
              resetImage();
              onSettingsChanged(settings);
            },
            onSavePreset: savePresetForAspect,
            sliderColor: sliderColor,
            loadPresets: EffectControls.loadPresetsForAspect,
            deletePreset: deletePresetAndUpdate,
            refreshPresets: EffectControls.refreshPresets,
            refreshCounter: EffectControls.presetsRefreshCounter,
          ),
          RadioListTile<bool>(
            value: false,
            groupValue: settings.fillScreen,
            onChanged: (value) {
              if (value != null) {
                settings.fillScreen = value;
                onSettingsChanged(settings);
              }
            },
            title: Text(
              'Fit to Screen',
              style: TextStyle(color: sliderColor, fontSize: 14),
            ),
            activeColor: sliderColor,
          ),
          RadioListTile<bool>(
            value: true,
            groupValue: settings.fillScreen,
            onChanged: (value) {
              if (value != null) {
                settings.fillScreen = value;
                onSettingsChanged(settings);
              }
            },
            title: Text(
              'Fill Screen',
              style: TextStyle(color: sliderColor, fontSize: 14),
            ),
            activeColor: sliderColor,
          ),
        ];

      case ShaderAspect.text:
        {
          List<Widget> widgets = [];

          widgets.add(
            AspectPanelHeader(
              aspect: aspect,
              onPresetSelected: applyPreset,
              onReset: () {
                resetText();
                onSettingsChanged(settings);
              },
              onSavePreset: savePresetForAspect,
              sliderColor: sliderColor,
              loadPresets: EffectControls.loadPresetsForAspect,
              deletePreset: deletePresetAndUpdate,
              refreshPresets: EffectControls.refreshPresets,
              refreshCounter: EffectControls.presetsRefreshCounter,
            ),
          );

          // Add wrap for text line selection buttons
          widgets.add(
            Wrap(
              spacing: 6,
              children: TextLine.values.map((line) {
                return ChoiceChip(
                  label: Text(line.label, style: TextStyle(color: sliderColor)),
                  selected: EffectControls.selectedTextLine == line,
                  selectedColor: sliderColor.withOpacity(0.3),
                  backgroundColor: sliderColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.transparent),
                  ),
                  onSelected: (_) {
                    EffectControls.selectedTextLine = line;
                    onSettingsChanged(settings);
                  },
                );
              }).toList(),
            ),
          );

          // Local helper for a labeled editable text field used for title / subtitle / artist.
          Widget buildTextField({
            required String label,
            required String value,
            required Function(String) setter,
          }) {
            // Use TextEditingController to properly update field when reset occurs
            final controller = TextEditingController(text: value);

            print('DEBUG: TextField initial value: "$value"');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: sliderColor, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: sliderColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: controller,
                    style: TextStyle(color: sliderColor),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (txt) {
                      print('DEBUG: onChanged received text: "$txt"');

                      // Store the text directly - the reversal will happen in setCurrentText
                      setter(txt);

                      final currentLine = EffectControls.selectedTextLine
                          .toString();
                      print('DEBUG: Current selected line: $currentLine');

                      String storedValue = "";
                      switch (EffectControls.selectedTextLine) {
                        case TextLine.title:
                          storedValue = settings.textTitle;
                          break;
                        case TextLine.subtitle:
                          storedValue = settings.textSubtitle;
                          break;
                        case TextLine.artist:
                          storedValue = settings.textArtist;
                          break;
                      }
                      print('DEBUG: Value stored in settings: "$storedValue"');

                      if (!settings.textEnabled) settings.textEnabled = true;
                      onSettingsChanged(settings);
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }

          // Mapping helpers for the currently selected text line
          String getCurrentText() {
            String rawText = "";
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                rawText = settings.textTitle;
                break;
              case TextLine.subtitle:
                rawText = settings.textSubtitle;
                break;
              case TextLine.artist:
                rawText = settings.textArtist;
                break;
            }

            // Fix for the display - we need to show the correctly ordered text
            return rawText;
          }

          void setCurrentText(String v) {
            // The text is coming from the text field in reverse order (last character first)
            // Reverse it back to normal order before storing
            final correctedText = String.fromCharCodes(
              v.runes.toList().reversed,
            );
            print(
              'DEBUG: setCurrentText received: "$v", storing: "$correctedText"',
            );

            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                settings.textTitle = correctedText;
                break;
              case TextLine.subtitle:
                settings.textSubtitle = correctedText;
                break;
              case TextLine.artist:
                settings.textArtist = correctedText;
                break;
            }
          }

          String getCurrentFont() {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                return settings.titleFont.isNotEmpty
                    ? settings.titleFont
                    : settings.textFont;
              case TextLine.subtitle:
                return settings.subtitleFont.isNotEmpty
                    ? settings.subtitleFont
                    : settings.textFont;
              case TextLine.artist:
                return settings.artistFont.isNotEmpty
                    ? settings.artistFont
                    : settings.textFont;
            }
            return settings.textFont;
          }

          void setCurrentFont(String f) {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                settings.titleFont = f;
                break;
              case TextLine.subtitle:
                settings.subtitleFont = f;
                break;
              case TextLine.artist:
                settings.artistFont = f;
                break;
            }
          }

          double getCurrentSize() {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                return settings.titleSize > 0
                    ? settings.titleSize
                    : settings.textSize;
              case TextLine.subtitle:
                return settings.subtitleSize > 0
                    ? settings.subtitleSize
                    : settings.textSize;
              case TextLine.artist:
                return settings.artistSize > 0
                    ? settings.artistSize
                    : settings.textSize;
            }
            return settings.textSize;
          }

          void setCurrentSize(double v) {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                settings.titleSize = v;
                break;
              case TextLine.subtitle:
                settings.subtitleSize = v;
                break;
              case TextLine.artist:
                settings.artistSize = v;
                break;
            }
          }

          double getCurrentPosX() {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                return settings.titlePosX;
              case TextLine.subtitle:
                return settings.subtitlePosX;
              case TextLine.artist:
                return settings.artistPosX;
            }
            return 0.0;
          }

          void setCurrentPosX(double v) {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                settings.titlePosX = v;
                break;
              case TextLine.subtitle:
                settings.subtitlePosX = v;
                break;
              case TextLine.artist:
                settings.artistPosX = v;
                break;
            }
          }

          double getCurrentPosY() {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                return settings.titlePosY;
              case TextLine.subtitle:
                return settings.subtitlePosY;
              case TextLine.artist:
                return settings.artistPosY;
            }
            return 0.0;
          }

          void setCurrentPosY(double v) {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                settings.titlePosY = v;
                break;
              case TextLine.subtitle:
                settings.subtitlePosY = v;
                break;
              case TextLine.artist:
                settings.artistPosY = v;
                break;
            }
          }

          // -------- Weight helpers ---------
          int getCurrentWeight() {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                return settings.titleWeight > 0
                    ? settings.titleWeight
                    : settings.textWeight;
              case TextLine.subtitle:
                return settings.subtitleWeight > 0
                    ? settings.subtitleWeight
                    : settings.textWeight;
              case TextLine.artist:
                return settings.artistWeight > 0
                    ? settings.artistWeight
                    : settings.textWeight;
            }
            return settings.textWeight;
          }

          void setCurrentWeight(int w) {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                settings.titleWeight = w;
                break;
              case TextLine.subtitle:
                settings.subtitleWeight = w;
                break;
              case TextLine.artist:
                settings.artistWeight = w;
                break;
            }
          }

          // -------- Fit to width helpers ---------
          bool getCurrentFitToWidth() {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                return settings.titleFitToWidth;
              case TextLine.subtitle:
                return settings.subtitleFitToWidth;
              case TextLine.artist:
                return settings.artistFitToWidth;
            }
            return false;
          }

          void setCurrentFitToWidth(bool value) {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                settings.titleFitToWidth = value;
                break;
              case TextLine.subtitle:
                settings.subtitleFitToWidth = value;
                break;
              case TextLine.artist:
                settings.artistFitToWidth = value;
                break;
            }
          }

          // -------- Horizontal alignment helpers ---------
          int getCurrentHAlign() {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                return settings.titleHAlign;
              case TextLine.subtitle:
                return settings.subtitleHAlign;
              case TextLine.artist:
                return settings.artistHAlign;
            }
            return 0; // Default to left
          }

          void setCurrentHAlign(int value) {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                settings.titleHAlign = value;
                break;
              case TextLine.subtitle:
                settings.subtitleHAlign = value;
                break;
              case TextLine.artist:
                settings.artistHAlign = value;
                break;
            }
          }

          // -------- Vertical alignment helpers ---------
          int getCurrentVAlign() {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                return settings.titleVAlign;
              case TextLine.subtitle:
                return settings.subtitleVAlign;
              case TextLine.artist:
                return settings.artistVAlign;
            }
            return 0; // Default to top
          }

          void setCurrentVAlign(int value) {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                settings.titleVAlign = value;
                break;
              case TextLine.subtitle:
                settings.subtitleVAlign = value;
                break;
              case TextLine.artist:
                settings.artistVAlign = value;
                break;
            }
          }

          // -------- Line height helpers ---------
          double getCurrentLineHeight() {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                return settings.titleLineHeight;
              case TextLine.subtitle:
                return settings.subtitleLineHeight;
              case TextLine.artist:
                return settings.artistLineHeight;
            }
            return 1.2; // Default line height
          }

          void setCurrentLineHeight(double value) {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                settings.titleLineHeight = value;
                break;
              case TextLine.subtitle:
                settings.subtitleLineHeight = value;
                break;
              case TextLine.artist:
                settings.artistLineHeight = value;
                break;
            }
          }

          // Helper to convert int weight to FontWeight
          FontWeight toFontWeight(int weight) {
            switch (weight) {
              case 100:
                return FontWeight.w100;
              case 200:
                return FontWeight.w200;
              case 300:
                return FontWeight.w300;
              case 400:
                return FontWeight.w400;
              case 500:
                return FontWeight.w500;
              case 600:
                return FontWeight.w600;
              case 700:
                return FontWeight.w700;
              case 800:
                return FontWeight.w800;
              case 900:
                return FontWeight.w900;
              default:
                return FontWeight.w400;
            }
          }

          int fromFontWeight(FontWeight fw) {
            switch (fw) {
              case FontWeight.w100:
                return 100;
              case FontWeight.w200:
                return 200;
              case FontWeight.w300:
                return 300;
              case FontWeight.w400:
                return 400;
              case FontWeight.w500:
                return 500;
              case FontWeight.w600:
                return 600;
              case FontWeight.w700:
                return 700;
              case FontWeight.w800:
                return 800;
              case FontWeight.w900:
                return 900;
              default:
                return 400;
            }
          }

          widgets.add(
            buildTextField(
              label: '${EffectControls.selectedTextLine.label} Text',
              value: getCurrentText(),
              setter: setCurrentText,
            ),
          );

          widgets.add(
            FontSelector(
              selectedFont: getCurrentFont().isEmpty
                  ? 'Default'
                  : getCurrentFont(),
              selectedWeight: toFontWeight(getCurrentWeight()),
              labelText: 'Font',
              onFontSelected: (font) {
                final selected = font == 'Default' ? '' : font;
                setCurrentFont(selected);
                if (!settings.textEnabled) settings.textEnabled = true;
                onSettingsChanged(settings);
              },
              onWeightSelected: (fw) {
                setCurrentWeight(fromFontWeight(fw));
                if (!settings.textEnabled) settings.textEnabled = true;
                onSettingsChanged(settings);
              },
            ),
          );

          widgets.add(const SizedBox(height: 12));

          widgets.add(
            ValueSlider(
              label: 'Size',
              value: getCurrentSize(),
              onChanged: (v) => onSliderChanged(v, setCurrentSize),
              sliderColor: sliderColor,
              defaultValue: 0.05,
            ),
          );

          // Add Fit to Width checkbox
          widgets.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fit to Width',
                  style: TextStyle(color: sliderColor, fontSize: 14),
                ),
                Checkbox(
                  value: getCurrentFitToWidth(),
                  checkColor: Colors.black,
                  activeColor: sliderColor,
                  side: BorderSide(color: sliderColor),
                  onChanged: (value) {
                    if (value != null) {
                      setCurrentFitToWidth(value);
                      if (!settings.textEnabled) settings.textEnabled = true;
                      onSettingsChanged(settings);
                    }
                  },
                ),
              ],
            ),
          );

          // Only show line height slider if fitToWidth is enabled
          if (getCurrentFitToWidth()) {
            widgets.add(
              ValueSlider(
                label: 'Line Height',
                value: getCurrentLineHeight() / 2.0, // Scale to 0-1 range
                onChanged: (v) => onSliderChanged(
                  v,
                  (val) => setCurrentLineHeight(val * 2.0),
                ), // Scale to 0-2 range
                sliderColor: sliderColor,
                defaultValue: 0.6, // Default 1.2 scaled to 0-1 range
              ),
            );
          }

          widgets.add(
            ValueSlider(
              label: 'Position X',
              value: getCurrentPosX(),
              onChanged: (v) => onSliderChanged(v, setCurrentPosX),
              sliderColor: sliderColor,
              defaultValue: 0.1,
            ),
          );

          widgets.add(
            ValueSlider(
              label: 'Position Y',
              value: getCurrentPosY(),
              onChanged: (v) => onSliderChanged(v, setCurrentPosY),
              sliderColor: sliderColor,
              defaultValue: 0.1,
            ),
          );

          // Add horizontal alignment controls
          widgets.add(
            AlignmentSelector(
              label: 'Horizontal Alignment',
              currentValue: getCurrentHAlign(),
              onChanged: (value) {
                setCurrentHAlign(value);
                if (!settings.textEnabled) settings.textEnabled = true;
                onSettingsChanged(settings);
              },
              sliderColor: sliderColor,
              icons: const [
                Icons.format_align_left,
                Icons.format_align_center,
                Icons.format_align_right,
              ],
              tooltips: const ['Left Align', 'Center Align', 'Right Align'],
            ),
          );

          widgets.add(const SizedBox(height: 16));

          // Add vertical alignment controls
          widgets.add(
            AlignmentSelector(
              label: 'Vertical Alignment',
              currentValue: getCurrentVAlign(),
              onChanged: (value) {
                setCurrentVAlign(value);
                if (!settings.textEnabled) settings.textEnabled = true;
                onSettingsChanged(settings);
              },
              sliderColor: sliderColor,
              icons: const [
                Icons.vertical_align_top,
                Icons.vertical_align_center,
                Icons.vertical_align_bottom,
              ],
              tooltips: const ['Top Align', 'Middle Align', 'Bottom Align'],
            ),
          );

          return widgets;
        }
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

  // Helper method removed - now using AlignmentSelector widget

  // Helper method removed - now using AnimationControls widget

  // Build a widget to display saved presets
  static Widget buildPresetsBar({
    required ShaderAspect aspect,
    required Function(Map<String, dynamic>) onPresetSelected,
    required Color sliderColor,
    required BuildContext context,
  }) {
    return FutureBuilder<Map<String, dynamic>>(
      // Add refresh counter to key to force rebuild
      key: ValueKey('presets_${aspect.toString()}_${presetsRefreshCounter}'),
      future: loadPresetsForAspect(aspect),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final presets = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Text(
                    'Presets',
                    style: TextStyle(
                      color: sliderColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: presets.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InkWell(
                      onTap: () => onPresetSelected(entry.value),
                      onLongPress: () {
                        // Show delete confirmation
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              'Delete Preset',
                              style: TextStyle(color: sliderColor),
                            ),
                            content: Text(
                              'Are you sure you want to delete the preset "${entry.key}"?',
                              style: TextStyle(color: sliderColor),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: sliderColor),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  await deletePresetAndUpdate(
                                    aspect,
                                    entry.key,
                                  );
                                  // Force refresh
                                  refreshPresets();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                            backgroundColor: sliderColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sliderColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: sliderColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          entry.key,
                          style: TextStyle(color: sliderColor, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
