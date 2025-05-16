import 'package:flutter/material.dart';
import 'dart:math';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import 'value_slider.dart';
import 'animation_controls.dart';
import 'aspect_panel_header.dart';
import '../views/effect_controls.dart';

class ColorPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const ColorPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<ColorPanel> createState() => _ColorPanelState();
}

class _ColorPanelState extends State<ColorPanel> {
  bool _showColorControls = true;
  bool _showOverlayControls = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectPanelHeader(
          aspect: ShaderAspect.color,
          onPresetSelected: _applyPreset,
          onReset: _resetColor,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
        ),
        // Main color controls section with collapsible header
        _buildSectionHeader(
          'Color Adjustments',
          _showColorControls,
          () => setState(() => _showColorControls = !_showColorControls),
        ),
        if (_showColorControls) ...[
          ValueSlider(
            label: 'Hue',
            value: widget.settings.colorSettings.hue,
            onChanged: (value) => _onSliderChanged(
              value,
              (v) => widget.settings.colorSettings.hue = v,
            ),
            sliderColor: widget.sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Saturation',
            value: widget.settings.colorSettings.saturation,
            onChanged: (value) => _onSliderChanged(
              value,
              (v) => widget.settings.colorSettings.saturation = v,
            ),
            sliderColor: widget.sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Lightness',
            value: widget.settings.colorSettings.lightness,
            onChanged: (value) => _onSliderChanged(
              value,
              (v) => widget.settings.colorSettings.lightness = v,
            ),
            sliderColor: widget.sliderColor,
            defaultValue: 0.0,
          ),
          // Toggle animation for HSL adjustments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Animate HSL',
                style: TextStyle(color: widget.sliderColor, fontSize: 14),
              ),
              Switch(
                value: widget.settings.colorSettings.colorAnimated,
                activeThumbColor: widget.sliderColor,
                onChanged: (value) {
                  widget.settings.colorSettings.colorAnimated = value;
                  if (!widget.settings.colorEnabled)
                    widget.settings.colorEnabled = true;
                  widget.onSettingsChanged(widget.settings);
                },
              ),
            ],
          ),
          if (widget.settings.colorSettings.colorAnimated)
            AnimationControls(
              animationSpeed:
                  widget.settings.colorSettings.colorAnimOptions.speed,
              onSpeedChanged: (v) {
                widget.settings.colorSettings.colorAnimOptions = widget
                    .settings
                    .colorSettings
                    .colorAnimOptions
                    .copyWith(speed: v);
                widget.onSettingsChanged(widget.settings);
              },
              animationMode:
                  widget.settings.colorSettings.colorAnimOptions.mode,
              onModeChanged: (m) {
                widget.settings.colorSettings.colorAnimOptions = widget
                    .settings
                    .colorSettings
                    .colorAnimOptions
                    .copyWith(mode: m);
                widget.onSettingsChanged(widget.settings);
              },
              animationEasing:
                  widget.settings.colorSettings.colorAnimOptions.easing,
              onEasingChanged: (e) {
                widget.settings.colorSettings.colorAnimOptions = widget
                    .settings
                    .colorSettings
                    .colorAnimOptions
                    .copyWith(easing: e);
                widget.onSettingsChanged(widget.settings);
              },
              sliderColor: widget.sliderColor,
            ),
        ],

        const SizedBox(height: 16),

        // Overlay section with collapsible header
        _buildSectionHeader(
          'Overlay Controls',
          _showOverlayControls,
          () => setState(() => _showOverlayControls = !_showOverlayControls),
        ),
        if (_showOverlayControls) ...[
          ValueSlider(
            label: 'Overlay Hue',
            value: widget.settings.colorSettings.overlayHue,
            onChanged: (value) => _onSliderChanged(
              value,
              (v) => widget.settings.colorSettings.overlayHue = v,
            ),
            sliderColor: widget.sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Overlay Intensity',
            value: widget.settings.colorSettings.overlayIntensity,
            onChanged: (value) => _onSliderChanged(
              value,
              (v) => widget.settings.colorSettings.overlayIntensity = v,
            ),
            sliderColor: widget.sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Overlay Opacity',
            value: widget.settings.colorSettings.overlayOpacity,
            onChanged: (value) => _onSliderChanged(
              value,
              (v) => widget.settings.colorSettings.overlayOpacity = v,
            ),
            sliderColor: widget.sliderColor,
            defaultValue: 0.0,
          ),
          // Toggle animation for overlay
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Animate Overlay',
                style: TextStyle(color: widget.sliderColor, fontSize: 14),
              ),
              Switch(
                value: widget.settings.colorSettings.overlayAnimated,
                activeThumbColor: widget.sliderColor,
                onChanged: (value) {
                  widget.settings.colorSettings.overlayAnimated = value;
                  if (!widget.settings.colorEnabled)
                    widget.settings.colorEnabled = true;
                  widget.onSettingsChanged(widget.settings);
                },
              ),
            ],
          ),
          if (widget.settings.colorSettings.overlayAnimated)
            AnimationControls(
              animationSpeed:
                  widget.settings.colorSettings.overlayAnimOptions.speed,
              onSpeedChanged: (v) {
                widget.settings.colorSettings.overlayAnimOptions = widget
                    .settings
                    .colorSettings
                    .overlayAnimOptions
                    .copyWith(speed: v);
                widget.onSettingsChanged(widget.settings);
              },
              animationMode:
                  widget.settings.colorSettings.overlayAnimOptions.mode,
              onModeChanged: (m) {
                widget.settings.colorSettings.overlayAnimOptions = widget
                    .settings
                    .colorSettings
                    .overlayAnimOptions
                    .copyWith(mode: m);
                widget.onSettingsChanged(widget.settings);
              },
              animationEasing:
                  widget.settings.colorSettings.overlayAnimOptions.easing,
              onEasingChanged: (e) {
                widget.settings.colorSettings.overlayAnimOptions = widget
                    .settings
                    .colorSettings
                    .overlayAnimOptions
                    .copyWith(easing: e);
                widget.onSettingsChanged(widget.settings);
              },
              sliderColor: widget.sliderColor,
            ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: widget.sliderColor.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: widget.sliderColor.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _onSliderChanged(double value, Function(double) setter) {
    // Enable the corresponding effect if it's not already enabled
    if (!widget.settings.colorEnabled) widget.settings.colorEnabled = true;

    // Update the setting value
    setter(value);
    // Notify the parent widget
    widget.onSettingsChanged(widget.settings);
  }

  void _resetColor() {
    final defaults = ShaderSettings();
    widget.settings.colorEnabled = false;
    widget.settings.colorSettings.hue = defaults.colorSettings.hue;
    widget.settings.colorSettings.saturation =
        defaults.colorSettings.saturation;
    widget.settings.colorSettings.lightness = defaults.colorSettings.lightness;
    widget.settings.colorSettings.overlayHue =
        defaults.colorSettings.overlayHue;
    widget.settings.colorSettings.overlayIntensity =
        defaults.colorSettings.overlayIntensity;
    widget.settings.colorSettings.overlayOpacity =
        defaults.colorSettings.overlayOpacity;
    widget.settings.colorSettings.colorAnimated = false;
    widget.settings.colorSettings.overlayAnimated = false;
    widget.settings.colorSettings.colorAnimOptions = AnimationOptions();
    widget.settings.colorSettings.overlayAnimOptions = AnimationOptions();

    widget.onSettingsChanged(widget.settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    widget.settings.colorEnabled =
        presetData['colorEnabled'] ?? widget.settings.colorEnabled;
    widget.settings.colorSettings.hue =
        presetData['hue'] ?? widget.settings.colorSettings.hue;
    widget.settings.colorSettings.saturation =
        presetData['saturation'] ?? widget.settings.colorSettings.saturation;
    widget.settings.colorSettings.lightness =
        presetData['lightness'] ?? widget.settings.colorSettings.lightness;
    widget.settings.colorSettings.overlayHue =
        presetData['overlayHue'] ?? widget.settings.colorSettings.overlayHue;
    widget.settings.colorSettings.overlayIntensity =
        presetData['overlayIntensity'] ??
        widget.settings.colorSettings.overlayIntensity;
    widget.settings.colorSettings.overlayOpacity =
        presetData['overlayOpacity'] ??
        widget.settings.colorSettings.overlayOpacity;
    widget.settings.colorSettings.colorAnimated =
        presetData['colorAnimated'] ??
        widget.settings.colorSettings.colorAnimated;
    widget.settings.colorSettings.overlayAnimated =
        presetData['overlayAnimated'] ??
        widget.settings.colorSettings.overlayAnimated;

    if (presetData['colorAnimOptions'] != null) {
      widget.settings.colorSettings.colorAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['colorAnimOptions']),
      );
    }

    if (presetData['overlayAnimOptions'] != null) {
      widget.settings.colorSettings.overlayAnimOptions =
          AnimationOptions.fromMap(
            Map<String, dynamic>.from(presetData['overlayAnimOptions']),
          );
    }

    widget.onSettingsChanged(widget.settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'colorEnabled': widget.settings.colorEnabled,
      'hue': widget.settings.colorSettings.hue,
      'saturation': widget.settings.colorSettings.saturation,
      'lightness': widget.settings.colorSettings.lightness,
      'overlayHue': widget.settings.colorSettings.overlayHue,
      'overlayIntensity': widget.settings.colorSettings.overlayIntensity,
      'overlayOpacity': widget.settings.colorSettings.overlayOpacity,
      'colorAnimated': widget.settings.colorSettings.colorAnimated,
      'overlayAnimated': widget.settings.colorSettings.overlayAnimated,
      'colorAnimOptions': widget.settings.colorSettings.colorAnimOptions
          .toMap(),
      'overlayAnimOptions': widget.settings.colorSettings.overlayAnimOptions
          .toMap(),
    };

    // These methods need to be implemented to work with the global preset system
    bool success = await PresetsManager.savePreset(aspect, name, presetData);

    if (success) {
      // Update cached presets
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      // Force refresh of the UI to show the new preset immediately
      _refreshPresets();
    }
  }

  // These will need to be connected to EffectControls static methods
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  static Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    // Delegate to EffectControls
    // This will need to be implemented to connect with the global preset system
    if (!_cachedPresets.containsKey(aspect)) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return _cachedPresets[aspect] ?? {};
  }

  static void _refreshPresets() {
    _refreshCounter++;
    // Call the central refresh method for immediate UI update
    EffectControls.refreshPresets();
  }

  static Future<bool> _deletePresetAndUpdate(
    ShaderAspect aspect,
    String name,
  ) async {
    final success = await PresetsManager.deletePreset(aspect, name);
    if (success) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return success;
  }
}
