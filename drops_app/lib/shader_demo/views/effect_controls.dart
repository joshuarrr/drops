import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../../common/font_selector.dart';

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
            _buildAspectToggle(
              aspect: ShaderAspect.image,
              isEnabled: true,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: onAspectToggled,
              onTap: onAspectSelected,
            ),
            _buildAspectToggle(
              aspect: ShaderAspect.color,
              isEnabled: settings.colorEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: onAspectToggled,
              onTap: onAspectSelected,
            ),
            _buildAspectToggle(
              aspect: ShaderAspect.blur,
              isEnabled: settings.blurEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: onAspectToggled,
              onTap: onAspectSelected,
            ),
            _buildAspectToggle(
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

  // Build a toggleable button for each shader aspect
  static Widget _buildAspectToggle({
    required ShaderAspect aspect,
    required bool isEnabled,
    required bool isCurrentImageDark,
    required Function(ShaderAspect, bool) onToggled,
    required Function(ShaderAspect) onTap,
  }) {
    final Color textColor = isCurrentImageDark ? Colors.white : Colors.black;
    // Set a very subtle background for all modes: 10% opacity (inactive) or 15% (active).
    // This keeps the look consistent regardless of the underlying image brightness.
    final Color backgroundColor = Colors.white.withOpacity(
      isEnabled ? 0.15 : 0.10,
    );

    final Color borderColor = isEnabled
        ? textColor
        : textColor.withOpacity(0.5);

    return Tooltip(
      message: isEnabled
          ? "Long press to disable ${aspect.label}"
          : "Long press to enable ${aspect.label}",
      preferBelow: true,
      showDuration: const Duration(seconds: 1),
      verticalOffset: 20,
      textStyle: TextStyle(
        color: isCurrentImageDark ? Colors.black : Colors.white,
        fontSize: 11,
      ),
      decoration: BoxDecoration(
        color: isCurrentImageDark
            ? Colors.white.withOpacity(0.9)
            : Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: GestureDetector(
        // Single tap to select the aspect and show sliders
        onTap: () => onTap(aspect),
        // Long press to toggle the effect on/off
        onLongPress: () => onToggled(aspect, !isEnabled),
        child: SizedBox(
          width: 70,
          height: 78,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(aspect.icon, color: textColor, size: 20),
                const SizedBox(height: 6),
                Text(
                  aspect.label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 1),
                Container(
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEnabled
                        ? Colors.green
                        : textColor.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
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
  }) {
    // ---------------------------------------------------------------
    // Local helpers -------------------------------------------------
    // ---------------------------------------------------------------

    // Generic reset header widget reused across aspects
    Widget buildResetRow(VoidCallback onReset) {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: sliderColor,
            backgroundColor: sliderColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.transparent),
            ),
          ),
          icon: const Icon(Icons.restore, size: 18),
          label: const Text('Reset'),
          onPressed: onReset,
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
      settings
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

    switch (aspect) {
      case ShaderAspect.color:
        return [
          buildResetRow(() {
            resetColor();
            onSettingsChanged(settings);
          }),
          const SizedBox(height: 8),
          buildSlider(
            label: 'Hue',
            value: settings.hue,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.hue = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          buildSlider(
            label: 'Saturation',
            value: settings.saturation,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.saturation = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          buildSlider(
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
          buildSlider(
            label: 'Overlay Hue',
            value: settings.overlayHue,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.overlayHue = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          buildSlider(
            label: 'Overlay Intensity',
            value: settings.overlayIntensity,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.overlayIntensity = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          buildSlider(
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
            buildAnimationControls(
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
            buildAnimationControls(
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
          buildResetRow(() {
            resetBlur();
            onSettingsChanged(settings);
          }),
          const SizedBox(height: 8),
          buildSlider(
            label: 'Shatter Amount',
            value: settings.blurAmount,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.blurAmount = v),
            sliderColor: sliderColor,
            defaultValue: 0.0,
          ),
          buildSlider(
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
          buildSlider(
            label: 'Shatter Opacity',
            value: settings.blurOpacity,
            onChanged: (value) =>
                onSliderChanged(value, (v) => settings.blurOpacity = v),
            sliderColor: sliderColor,
            defaultValue: 1.0,
          ),
          // Facets slider (0-1 mapped to 1-150 facets)
          buildSlider(
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
            buildAnimationControls(
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
          buildResetRow(() {
            resetImage();
            onSettingsChanged(settings);
          }),
          const SizedBox(height: 8),
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
          // Local helper for a labeled editable text field used for title / subtitle / artist.
          Widget buildTextField({
            required String label,
            required String value,
            required Function(String) setter,
          }) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: sliderColor, fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  initialValue: value,
                  style: TextStyle(color: sliderColor),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    filled: true,
                    fillColor: sliderColor.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: sliderColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                  onChanged: (txt) {
                    setter(txt);
                    if (!settings.textEnabled) settings.textEnabled = true;
                    onSettingsChanged(settings);
                  },
                ),
                const SizedBox(height: 12),
              ],
            );
          }

          // Mapping helpers for the currently selected text line
          String getCurrentText() {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                return settings.textTitle;
              case TextLine.subtitle:
                return settings.textSubtitle;
              case TextLine.artist:
                return settings.textArtist;
            }
            return '';
          }

          void setCurrentText(String v) {
            switch (EffectControls.selectedTextLine) {
              case TextLine.title:
                settings.textTitle = v;
                break;
              case TextLine.subtitle:
                settings.textSubtitle = v;
                break;
              case TextLine.artist:
                settings.textArtist = v;
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

          // ------------------------------------------------------------------
          List<Widget> widgets = [];

          widgets.add(
            buildResetRow(() {
              resetText();
              onSettingsChanged(settings);
            }),
          );

          widgets.add(const SizedBox(height: 8));

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

          widgets.add(const SizedBox(height: 12));

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
            buildSlider(
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
              buildSlider(
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
            buildSlider(
              label: 'Position X',
              value: getCurrentPosX(),
              onChanged: (v) => onSliderChanged(v, setCurrentPosX),
              sliderColor: sliderColor,
              defaultValue: 0.1,
            ),
          );

          widgets.add(
            buildSlider(
              label: 'Position Y',
              value: getCurrentPosY(),
              onChanged: (v) => onSliderChanged(v, setCurrentPosY),
              sliderColor: sliderColor,
              defaultValue: 0.1,
            ),
          );

          // Add horizontal alignment controls
          widgets.add(
            buildAlignmentControls(
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
            buildAlignmentControls(
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

  // Builds a single slider control
  static Widget buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required Color sliderColor,
    double defaultValue = 0.0,
  }) {
    // Check if the current value is different from the default value
    final bool valueChanged = value != defaultValue;
    final bool isCurrentImageDark = sliderColor == Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isCurrentImageDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: sliderColor,
                  inactiveTrackColor: sliderColor.withOpacity(0.3),
                  thumbColor: sliderColor,
                  overlayColor: sliderColor.withOpacity(0.1),
                ),
                child: Slider(
                  value: value,
                  onChanged: (newValue) {
                    if (enableLogging) {
                      print(
                        "SLIDER: $label changing to ${(newValue * 100).round()}%",
                      );
                    }
                    onChanged(newValue);
                  },
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: isCurrentImageDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            // Reset button for this specific slider - disabled if value hasn't changed
            InkWell(
              onTap: valueChanged ? () => onChanged(defaultValue) : null,
              child: Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: valueChanged
                      ? sliderColor.withOpacity(0.1)
                      : sliderColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.refresh,
                  color: valueChanged
                      ? sliderColor
                      : sliderColor.withOpacity(0.3),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper to build a single blend mode chip
  static Widget _buildBlendChip(
    String label,
    int mode,
    ShaderSettings settings,
    Color sliderColor,
    Function(ShaderSettings) onSettingsChanged,
  ) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: sliderColor)),
      selected: settings.blurBlendMode == mode,
      selectedColor: sliderColor.withOpacity(0.3),
      backgroundColor: sliderColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.transparent),
      ),
      onSelected: (selected) {
        if (selected) {
          settings.blurBlendMode = mode;
          onSettingsChanged(settings);
        }
      },
    );
  }

  // Helper to build text alignment button group
  static Widget buildAlignmentControls({
    required String label,
    required int currentValue,
    required ValueChanged<int> onChanged,
    required Color sliderColor,
    required List<IconData> icons,
    required List<String> tooltips,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: sliderColor, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            icons.length,
            (index) => Tooltip(
              message: tooltips[index],
              child: InkWell(
                onTap: () => onChanged(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentValue == index
                        ? sliderColor.withOpacity(0.3)
                        : sliderColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Icon(icons[index], color: sliderColor, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper to build animation speed + type + easing controls so they can be reused
  static Widget buildAnimationControls({
    required double animationSpeed,
    required ValueChanged<double> onSpeedChanged,
    required AnimationMode animationMode,
    required ValueChanged<AnimationMode> onModeChanged,
    required AnimationEasing animationEasing,
    required ValueChanged<AnimationEasing> onEasingChanged,
    required Color sliderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Speed', style: TextStyle(color: sliderColor, fontSize: 14)),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: sliderColor,
            inactiveTrackColor: sliderColor.withOpacity(0.3),
            thumbColor: sliderColor,
          ),
          child: Slider(
            value: animationSpeed,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: onSpeedChanged,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Animation Type',
          style: TextStyle(color: sliderColor, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Column(
          children: AnimationMode.values.map((mode) {
            final String label = mode == AnimationMode.pulse
                ? 'Pulse'
                : 'Randomixed';
            return RadioListTile<AnimationMode>(
              value: mode,
              groupValue: animationMode,
              activeColor: sliderColor,
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: TextStyle(color: sliderColor)),
              dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) {
                if (val != null) onModeChanged(val);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text('Easing', style: TextStyle(color: sliderColor, fontSize: 14)),
        const SizedBox(height: 8),
        Column(
          children: AnimationEasing.values.map((ease) {
            final String label;
            switch (ease) {
              case AnimationEasing.linear:
                label = 'Linear';
                break;
              case AnimationEasing.easeIn:
                label = 'Ease In';
                break;
              case AnimationEasing.easeOut:
                label = 'Ease Out';
                break;
              case AnimationEasing.easeInOut:
                label = 'Ease In Out';
                break;
            }
            return RadioListTile<AnimationEasing>(
              value: ease,
              groupValue: animationEasing,
              activeColor: sliderColor,
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: TextStyle(color: sliderColor)),
              dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) {
                if (val != null) onEasingChanged(val);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
