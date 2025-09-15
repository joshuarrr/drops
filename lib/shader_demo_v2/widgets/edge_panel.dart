import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../services/preset_refresh_service.dart';
import '../controllers/animation_state_manager.dart';
import 'lockable_slider.dart';
import 'animation_controls.dart';
import 'enhanced_panel_header.dart';

class EdgePanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const EdgePanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<EdgePanel> createState() => _EdgePanelState();
}

class _EdgePanelState extends State<EdgePanel> {
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    // Ensure effect is enabled when panel is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.settings.edgeEnabled) {
        final updatedSettings = widget.settings;
        updatedSettings.edgeEnabled = true;
        widget.onSettingsChanged(updatedSettings);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnhancedPanelHeader(
          aspect: ShaderAspect.edge,
          onPresetSelected: _applyPreset,
          onReset: _resetEffect,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: true,
          applyToText: false,
          onApplyToImageChanged: (value) {
            // Edge effect only applies to images for now
          },
          onApplyToTextChanged: (value) {
            // Edge effect only applies to images for now
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Opacity slider
              LockableSlider(
                label: 'Edge Opacity',
                value: widget.settings.edgeSettings.opacity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.edgeSettings.opacity * 100).round()}%',
                onChanged: (value) => _onOpacityChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.edgeOpacity,
                animationEnabled: widget.settings.edgeSettings.edgeAnimated,
                defaultValue: 0.7,
              ),

              const SizedBox(height: 16),

              // Edge Intensity slider
              LockableSlider(
                label: 'Edge Intensity',
                value: widget.settings.edgeSettings.edgeIntensity,
                min: 0.1,
                max: 5.0,
                divisions: 49,
                displayValue: widget.settings.edgeSettings.edgeIntensity
                    .toStringAsFixed(1),
                onChanged: (value) => _onIntensityChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.edgeIntensity,
                animationEnabled: widget.settings.edgeSettings.edgeAnimated,
                defaultValue: 1.5,
              ),

              const SizedBox(height: 16),

              // Edge Thickness slider
              LockableSlider(
                label: 'Edge Thickness',
                value: widget.settings.edgeSettings.edgeThickness,
                min: 0.1,
                max: 5.0,
                divisions: 49,
                displayValue: widget.settings.edgeSettings.edgeThickness
                    .toStringAsFixed(1),
                onChanged: (value) => _onThicknessChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.edgeThickness,
                animationEnabled: widget.settings.edgeSettings.edgeAnimated,
                defaultValue: 1.0,
              ),

              const SizedBox(height: 16),

              // Edge Color slider
              LockableSlider(
                label: 'Edge Color',
                value: widget.settings.edgeSettings.edgeColor,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: _getEdgeColorLabel(
                  widget.settings.edgeSettings.edgeColor,
                ),
                onChanged: (value) => _onColorChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.edgeColor,
                animationEnabled: widget.settings.edgeSettings.edgeAnimated,
                defaultValue: 0.0,
              ),

              const SizedBox(height: 16),

              // Animation toggle
              SwitchListTile(
                title: const Text('Enable Animation'),
                value: widget.settings.edgeSettings.edgeAnimated,
                onChanged: _onAnimatedChanged,
                activeColor: widget.sliderColor,
              ),

              // Animation controls - only show when animation is enabled
              if (widget.settings.edgeSettings.edgeAnimated)
                AnimationControls(
                  animationSpeed: widget.settings.edgeSettings.animationSpeed,
                  onSpeedChanged: _onAnimationSpeedChanged,
                  animationMode:
                      widget.settings.edgeSettings.edgeAnimOptions.mode,
                  onModeChanged: _onAnimationModeChanged,
                  animationEasing:
                      widget.settings.edgeSettings.edgeAnimOptions.easing,
                  onEasingChanged: _onAnimationEasingChanged,
                  sliderColor: widget.sliderColor,
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  // Helper to get edge color label
  String _getEdgeColorLabel(double value) {
    if (value < 0.33) {
      return 'Black';
    } else if (value < 0.67) {
      return 'Original';
    } else {
      return 'White';
    }
  }

  // Handle slider changes
  void _onOpacityChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.opacity = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onIntensityChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.edgeIntensity = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onThicknessChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.edgeThickness = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onColorChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.edgeColor = value;
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation toggle
  void _onAnimatedChanged(bool isAnimated) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.edgeAnimated = isAnimated;
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation speed changes
  void _onAnimationSpeedChanged(double speed) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.animationSpeed = speed;

    // Also update the speed in animation options
    updatedSettings.edgeSettings.edgeAnimOptions = updatedSettings
        .edgeSettings
        .edgeAnimOptions
        .copyWith(speed: speed);

    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation mode changes
  void _onAnimationModeChanged(AnimationMode mode) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.edgeAnimOptions = updatedSettings
        .edgeSettings
        .edgeAnimOptions
        .copyWith(mode: mode);
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation easing changes
  void _onAnimationEasingChanged(AnimationEasing easing) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.edgeAnimOptions = updatedSettings
        .edgeSettings
        .edgeAnimOptions
        .copyWith(easing: easing);
    widget.onSettingsChanged(updatedSettings);
  }

  // Reset settings to defaults
  void _resetEffect() {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.reset();
    widget.onSettingsChanged(updatedSettings);
  }

  // Apply preset
  void _applyPreset(Map<String, dynamic> presetData) {
    final updatedSettings = widget.settings;

    // Apply preset values
    updatedSettings.edgeEnabled = presetData['edgeEnabled'] ?? true;
    updatedSettings.edgeSettings.opacity = presetData['opacity'] ?? 0.7;
    updatedSettings.edgeSettings.edgeIntensity =
        presetData['edgeIntensity'] ?? 1.5;
    updatedSettings.edgeSettings.edgeThickness =
        presetData['edgeThickness'] ?? 1.0;
    updatedSettings.edgeSettings.edgeColor = presetData['edgeColor'] ?? 0.0;
    updatedSettings.edgeSettings.edgeAnimated =
        presetData['edgeAnimated'] ?? false;
    updatedSettings.edgeSettings.animationSpeed =
        presetData['animationSpeed'] ?? 1.0;

    // Load animation options if available
    if (presetData['animOptions'] != null) {
      updatedSettings.edgeSettings.edgeAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['animOptions']),
      );
    }

    widget.onSettingsChanged(updatedSettings);
  }

  // Load presets for the current aspect
  Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    if (_cachedPresets.containsKey(aspect)) {
      return _cachedPresets[aspect]!;
    }

    // For now, return empty presets until we implement the actual loading
    _cachedPresets[aspect] = {};
    return _cachedPresets[aspect]!;
  }

  // Delete preset and update the UI
  Future<bool> _deletePresetAndUpdate(
    ShaderAspect aspect,
    String presetName,
  ) async {
    // For now, just simulate success
    _cachedPresets.remove(aspect);
    _refreshPresets();
    return true;
  }

  // Save current settings as a preset
  void _savePresetForAspect(ShaderAspect aspect, String presetName) {
    if (presetName.isEmpty) return;

    // Create preset data
    final presetData = {
      'edgeEnabled': true,
      'opacity': widget.settings.edgeSettings.opacity,
      'edgeIntensity': widget.settings.edgeSettings.edgeIntensity,
      'edgeThickness': widget.settings.edgeSettings.edgeThickness,
      'edgeColor': widget.settings.edgeSettings.edgeColor,
      'edgeAnimated': widget.settings.edgeSettings.edgeAnimated,
      'animationSpeed': widget.settings.edgeSettings.animationSpeed,
      'animOptions': widget.settings.edgeSettings.edgeAnimOptions.toMap(),
    };

    // For now, just store in our cache
    if (!_cachedPresets.containsKey(aspect)) {
      _cachedPresets[aspect] = {};
    }
    _cachedPresets[aspect]![presetName] = presetData;

    // Notify preset service
    final refreshService = PresetRefreshService();
    refreshService.refreshAspect(aspect);

    // Update refresh counter to trigger UI update
    _refreshPresets();
  }

  // Refresh presets
  void _refreshPresets() {
    setState(() {
      _refreshCounter++;
    });
  }
}
