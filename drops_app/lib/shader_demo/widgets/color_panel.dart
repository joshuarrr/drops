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
            value: widget.settings.hue,
            onChanged: (value) =>
                _onSliderChanged(value, (v) => widget.settings.hue = v),
            sliderColor: widget.sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Saturation',
            value: widget.settings.saturation,
            onChanged: (value) =>
                _onSliderChanged(value, (v) => widget.settings.saturation = v),
            sliderColor: widget.sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Lightness',
            value: widget.settings.lightness,
            onChanged: (value) =>
                _onSliderChanged(value, (v) => widget.settings.lightness = v),
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
                value: widget.settings.colorAnimated,
                activeThumbColor: widget.sliderColor,
                onChanged: (value) {
                  widget.settings.colorAnimated = value;
                  if (!widget.settings.colorEnabled)
                    widget.settings.colorEnabled = true;
                  widget.onSettingsChanged(widget.settings);
                },
              ),
            ],
          ),
          if (widget.settings.colorAnimated)
            AnimationControls(
              animationSpeed: widget.settings.colorAnimOptions.speed,
              onSpeedChanged: (v) {
                widget.settings.colorAnimOptions = widget
                    .settings
                    .colorAnimOptions
                    .copyWith(speed: v);
                widget.onSettingsChanged(widget.settings);
              },
              animationMode: widget.settings.colorAnimOptions.mode,
              onModeChanged: (m) {
                widget.settings.colorAnimOptions = widget
                    .settings
                    .colorAnimOptions
                    .copyWith(mode: m);
                widget.onSettingsChanged(widget.settings);
              },
              animationEasing: widget.settings.colorAnimOptions.easing,
              onEasingChanged: (e) {
                widget.settings.colorAnimOptions = widget
                    .settings
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
            value: widget.settings.overlayHue,
            onChanged: (value) =>
                _onSliderChanged(value, (v) => widget.settings.overlayHue = v),
            sliderColor: widget.sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Overlay Intensity',
            value: widget.settings.overlayIntensity,
            onChanged: (value) => _onSliderChanged(
              value,
              (v) => widget.settings.overlayIntensity = v,
            ),
            sliderColor: widget.sliderColor,
            defaultValue: 0.0,
          ),
          ValueSlider(
            label: 'Overlay Opacity',
            value: widget.settings.overlayOpacity,
            onChanged: (value) => _onSliderChanged(
              value,
              (v) => widget.settings.overlayOpacity = v,
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
                value: widget.settings.overlayAnimated,
                activeThumbColor: widget.sliderColor,
                onChanged: (value) {
                  widget.settings.overlayAnimated = value;
                  if (!widget.settings.colorEnabled)
                    widget.settings.colorEnabled = true;
                  widget.onSettingsChanged(widget.settings);
                },
              ),
            ],
          ),
          if (widget.settings.overlayAnimated)
            AnimationControls(
              animationSpeed: widget.settings.overlayAnimOptions.speed,
              onSpeedChanged: (v) {
                widget.settings.overlayAnimOptions = widget
                    .settings
                    .overlayAnimOptions
                    .copyWith(speed: v);
                widget.onSettingsChanged(widget.settings);
              },
              animationMode: widget.settings.overlayAnimOptions.mode,
              onModeChanged: (m) {
                widget.settings.overlayAnimOptions = widget
                    .settings
                    .overlayAnimOptions
                    .copyWith(mode: m);
                widget.onSettingsChanged(widget.settings);
              },
              animationEasing: widget.settings.overlayAnimOptions.easing,
              onEasingChanged: (e) {
                widget.settings.overlayAnimOptions = widget
                    .settings
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
    widget.settings
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

    widget.onSettingsChanged(widget.settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    widget.settings.colorEnabled =
        presetData['colorEnabled'] ?? widget.settings.colorEnabled;
    widget.settings.hue = presetData['hue'] ?? widget.settings.hue;
    widget.settings.saturation =
        presetData['saturation'] ?? widget.settings.saturation;
    widget.settings.lightness =
        presetData['lightness'] ?? widget.settings.lightness;
    widget.settings.overlayHue =
        presetData['overlayHue'] ?? widget.settings.overlayHue;
    widget.settings.overlayIntensity =
        presetData['overlayIntensity'] ?? widget.settings.overlayIntensity;
    widget.settings.overlayOpacity =
        presetData['overlayOpacity'] ?? widget.settings.overlayOpacity;
    widget.settings.colorAnimated =
        presetData['colorAnimated'] ?? widget.settings.colorAnimated;
    widget.settings.overlayAnimated =
        presetData['overlayAnimated'] ?? widget.settings.overlayAnimated;

    if (presetData['colorAnimOptions'] != null) {
      widget.settings.colorAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['colorAnimOptions']),
      );
    }

    if (presetData['overlayAnimOptions'] != null) {
      widget.settings.overlayAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['overlayAnimOptions']),
      );
    }

    widget.onSettingsChanged(widget.settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'colorEnabled': widget.settings.colorEnabled,
      'hue': widget.settings.hue,
      'saturation': widget.settings.saturation,
      'lightness': widget.settings.lightness,
      'overlayHue': widget.settings.overlayHue,
      'overlayIntensity': widget.settings.overlayIntensity,
      'overlayOpacity': widget.settings.overlayOpacity,
      'colorAnimated': widget.settings.colorAnimated,
      'overlayAnimated': widget.settings.overlayAnimated,
      'colorAnimOptions': widget.settings.colorAnimOptions.toMap(),
      'overlayAnimOptions': widget.settings.overlayAnimOptions.toMap(),
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
